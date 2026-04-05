import '../models/vacante_empresa_model.dart';
import '../database/database_helper.dart';

class VacanteEmpresaRepository {
  final DatabaseHelper _db = DatabaseHelper();

  // ── Bug 1 fix: dual-write ─────────────────────────────────────────────────
  // Inserta en vacantes_empresa Y crea un espejo en vacantes para que los
  // usuarios puedan verla en la lista principal.
  Future<int> publicarVacante(VacanteEmpresaModel vacante) async {
    final db = await _db.database;

    // 1. Obtener nombre de la empresa para el campo `empresa` de vacantes
    final empResult = await db.query(
      'empresas',
      columns: ['razon_social'],
      where: 'id = ?',
      whereArgs: [vacante.empresaId],
    );
    final empresaNombre = empResult.isNotEmpty
        ? empResult.first['razon_social'] as String
        : 'Empresa';

    // 2. Insertar en vacantes_empresa
    final veId = await db.insert('vacantes_empresa', vacante.toMap());

    // 3. Insertar espejo en vacantes (tabla que leen los usuarios)
    final vacanteEspejoId = await db.insert('vacantes', {
      'titulo': vacante.titulo,
      'descripcion': vacante.descripcion,
      'empresa': empresaNombre,
      'categoria': vacante.sector,  // sector → categoria
      'modalidad': vacante.modalidad,
      'jornada': vacante.jornada,
      'salarioReferencial': vacante.salarioReferencial,
      'requisitos': null,
      'fechaCierre': vacante.fechaCierre,
      'activa': vacante.activa ? 1 : 0,
    });

    // 4. Guardar el ID espejo en vacantes_empresa para sincronización futura
    await db.update(
      'vacantes_empresa',
      {'vacante_id': vacanteEspejoId},
      where: 'id = ?',
      whereArgs: [veId],
    );

    return veId;
  }

  Future<List<VacanteEmpresaModel>> obtenerVacantesPorEmpresa(int empresaId) async {
    final db = await _db.database;
    final result = await db.query(
      'vacantes_empresa',
      where: 'empresa_id = ?',
      whereArgs: [empresaId],
      orderBy: 'fecha_publicacion DESC',
    );
    return result.map((e) => VacanteEmpresaModel.fromMap(e)).toList();
  }

  // ── Bug 1 fix: sincronizar estado activa en ambas tablas ──────────────────
  Future<void> pausarVacante(int id) async {
    final db = await _db.database;
    await db.update('vacantes_empresa', {'activa': 0},
        where: 'id = ?', whereArgs: [id]);
    await _sincronizarActiva(db, id, 0);
  }

  Future<void> activarVacante(int id) async {
    final db = await _db.database;
    await db.update('vacantes_empresa', {'activa': 1},
        where: 'id = ?', whereArgs: [id]);
    await _sincronizarActiva(db, id, 1);
  }

  // ── Bug 1 fix: eliminar de ambas tablas ───────────────────────────────────
  Future<void> eliminarVacante(int id) async {
    final db = await _db.database;
    final vacanteId = await _obtenerVacanteEspejoId(db, id);
    await db.delete('vacantes_empresa', where: 'id = ?', whereArgs: [id]);
    if (vacanteId != null) {
      await db.delete('vacantes', where: 'id = ?', whereArgs: [vacanteId]);
    }
  }

  // ── Bug 1 fix: actualizar ambas tablas ────────────────────────────────────
  Future<void> actualizarVacante(VacanteEmpresaModel vacante) async {
    final db = await _db.database;
    await db.update(
      'vacantes_empresa',
      vacante.toMap(),
      where: 'id = ?',
      whereArgs: [vacante.id],
    );
    // Sincronizar campos relevantes en el espejo de vacantes
    if (vacante.vacanteId != null) {
      await db.update(
        'vacantes',
        {
          'titulo': vacante.titulo,
          'descripcion': vacante.descripcion,
          'categoria': vacante.sector,
          'modalidad': vacante.modalidad,
          'jornada': vacante.jornada,
          'salarioReferencial': vacante.salarioReferencial,
          'fechaCierre': vacante.fechaCierre,
          'activa': vacante.activa ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [vacante.vacanteId],
      );
    }
  }

  // ── Bug 2 fix: columnas y join corregidos ─────────────────────────────────
  // La query anterior usaba nombres de columna inexistentes (u.nombre,
  // u.correo_o_celular, p.usuario_id, p.vacante_id, p.fecha_postulacion).
  // nivel_educativo está en `perfiles`, no en `usuarios`.
  Future<List<Map<String, dynamic>>> obtenerPostulantesPorVacante(
      int vacanteEmpresaId) async {
    final db = await _db.database;
    final vacanteId = await _obtenerVacanteEspejoId(db, vacanteEmpresaId);
    if (vacanteId == null) return [];

    return await db.rawQuery('''
      SELECT
        p.id                                AS postulacion_id,
        u.nombreCompleto                    AS nombre,
        u.correoOTelefono                   AS correo_o_celular,
        COALESCE(pf.nivelEducativo, '-')    AS nivel_educativo,
        COALESCE(pf.habilidades, '')        AS habilidades,
        COALESCE(pf.experienciaLaboral, '') AS experiencia,
        p.fechaPostulacion                  AS fecha_postulacion,
        p.estado
      FROM postulaciones p
      INNER JOIN usuarios u   ON p.usuarioId  = u.id
      LEFT  JOIN perfiles  pf ON pf.usuarioId = u.id
      WHERE p.vacanteId = ?
      ORDER BY p.fechaPostulacion DESC
    ''', [vacanteId]);
  }

  Future<void> actualizarEstadoPostulacion(
      int postulacionId, String estado) async {
    final db = await _db.database;
    await db.update(
      'postulaciones',
      {'estado': estado},
      where: 'id = ?',
      whereArgs: [postulacionId],
    );
  }

  // ── Helpers privados ──────────────────────────────────────────────────────
  Future<int?> _obtenerVacanteEspejoId(dynamic db, int vacanteEmpresaId) async {
    final result = await db.query(
      'vacantes_empresa',
      columns: ['vacante_id'],
      where: 'id = ?',
      whereArgs: [vacanteEmpresaId],
    );
    if (result.isEmpty) return null;
    return result.first['vacante_id'] as int?;
  }

  Future<void> _sincronizarActiva(dynamic db, int vacanteEmpresaId, int activa) async {
    final vacanteId = await _obtenerVacanteEspejoId(db, vacanteEmpresaId);
    if (vacanteId != null) {
      await db.update(
        'vacantes',
        {'activa': activa},
        where: 'id = ?',
        whereArgs: [vacanteId],
      );
    }
  }
}
