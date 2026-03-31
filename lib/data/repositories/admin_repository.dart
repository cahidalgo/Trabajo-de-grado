import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/empresa_model.dart';

class AdminRepository {
  final DatabaseHelper _db = DatabaseHelper();

  Future<int> _count(Database db, String sql) async {
    final r = await db.rawQuery(sql);
    return (r.first.values.first as int?) ?? 0;
  }

  // ── Estadísticas ──────────────────────────────────────────
  Future<Map<String, int>> obtenerEstadisticas() async {
    final db = await _db.database;
    return {
      'usuarios': await _count(db, 'SELECT COUNT(*) FROM usuarios'),
      'empresas': await _count(db, 'SELECT COUNT(*) FROM empresas'),
      'empresasPendientes':
          await _count(db, 'SELECT COUNT(*) FROM empresas WHERE validado = 0'),
      'totalVacantes':
          await _count(db, 'SELECT COUNT(*) FROM vacantes_empresa'),
      'vacantesActivas':
          await _count(db, 'SELECT COUNT(*) FROM vacantes_empresa WHERE activa = 1'),
      'postulaciones': await _count(db, 'SELECT COUNT(*) FROM postulaciones'),
    };
  }

  // ── Empresas ──────────────────────────────────────────────
  Future<List<EmpresaModel>> listarEmpresas() async {
    final db = await _db.database;
    final result =
        await db.query('empresas', orderBy: 'fecha_registro DESC');
    return result.map(EmpresaModel.fromMap).toList();
  }

  Future<void> validarEmpresa(int id) async {
    final db = await _db.database;
    await db.update(
        'empresas', {'validado': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> revocarEmpresa(int id) async {
    final db = await _db.database;
    await db.update(
        'empresas', {'validado': 0}, where: 'id = ?', whereArgs: [id]);
  }

  // ── Usuarios ──────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listarUsuarios() async {
    final db = await _db.database;
    return db.rawQuery('''
      SELECT u.id, u.nombreCompleto, u.correoOTelefono, u.fechaRegistro,
             COALESCE(p.perfilCompleto, 0) AS perfilCompleto
      FROM usuarios u
      LEFT JOIN perfiles p ON p.usuarioId = u.id
      ORDER BY u.fechaRegistro DESC
    ''');
  }

  // ── Vacantes empresa ──────────────────────────────────────
  Future<List<Map<String, dynamic>>> listarVacantesConEmpresa() async {
    final db = await _db.database;
    return db.rawQuery('''
      SELECT ve.id, ve.titulo, ve.sector, ve.modalidad, ve.jornada,
             ve.activa, ve.fecha_publicacion, ve.fecha_cierre,
             e.razon_social AS empresa_nombre
      FROM vacantes_empresa ve
      INNER JOIN empresas e ON e.id = ve.empresa_id
      ORDER BY ve.fecha_publicacion DESC
    ''');
  }

  Future<void> desactivarVacante(int id) async {
    final db = await _db.database;
    await db.update(
        'vacantes_empresa', {'activa': 0}, where: 'id = ?', whereArgs: [id]);
    // ✅ Sincronizar espejo en vacantes para que desaparezca de la vista usuario
    final vacanteId = await _vacanteEspejoId(db, id);
    if (vacanteId != null) {
      await db.update(
          'vacantes', {'activa': 0}, where: 'id = ?', whereArgs: [vacanteId]);
    }
  }

  Future<void> activarVacante(int id) async {
    final db = await _db.database;
    await db.update(
        'vacantes_empresa', {'activa': 1}, where: 'id = ?', whereArgs: [id]);
    // ✅ Sincronizar espejo en vacantes para que vuelva a aparecer
    final vacanteId = await _vacanteEspejoId(db, id);
    if (vacanteId != null) {
      await db.update(
          'vacantes', {'activa': 1}, where: 'id = ?', whereArgs: [vacanteId]);
    }
  }

  Future<int?> _vacanteEspejoId(Database db, int vacanteEmpresaId) async {
    final result = await db.query(
      'vacantes_empresa',
      columns: ['vacante_id'],
      where: 'id = ?',
      whereArgs: [vacanteEmpresaId],
    );
    if (result.isEmpty) return null;
    return result.first['vacante_id'] as int?;
  }
}