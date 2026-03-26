import '../models/vacante_empresa_model.dart';
import '../database/database_helper.dart';

class VacanteEmpresaRepository {
  final DatabaseHelper _db = DatabaseHelper();

  Future<int> publicarVacante(VacanteEmpresaModel vacante) async {
    final db = await _db.database;
    return await db.insert('vacantes_empresa', vacante.toMap());
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

  Future<void> pausarVacante(int id) async {
    final db = await _db.database;
    await db.update('vacantes_empresa', {'activa': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> activarVacante(int id) async {
    final db = await _db.database;
    await db.update('vacantes_empresa', {'activa': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> eliminarVacante(int id) async {
    final db = await _db.database;
    await db.delete('vacantes_empresa', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> obtenerPostulantesPorVacante(int vacanteId) async {
    final db = await _db.database;
    return await db.rawQuery('''
      SELECT u.nombre, u.correo_o_celular, u.nivel_educativo,
             u.experiencia, p.fecha_postulacion, p.estado
      FROM postulaciones p
      INNER JOIN usuarios u ON p.usuario_id = u.id
      WHERE p.vacante_id = ?
      ORDER BY p.fecha_postulacion DESC
    ''', [vacanteId]);
  }
}
