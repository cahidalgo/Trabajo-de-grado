import '../database/database_helper.dart';

class PostulacionRepository {
  final _db = DatabaseHelper();

  Future<bool> yaSePostulo(int usuarioId, int vacanteId) async {
    final db     = await _db.database;
    final result = await db.query(
      'postulaciones',
      where: 'usuarioId = ? AND vacanteId = ?',
      whereArgs: [usuarioId, vacanteId],
    );
    return result.isNotEmpty;
  }

  Future<void> registrar(int usuarioId, int vacanteId) async {
    final db = await _db.database;
    await db.insert('postulaciones', {
      'usuarioId':        usuarioId,
      'vacanteId':        vacanteId,
      'fechaPostulacion': DateTime.now().toIso8601String(),
      'estado':           'Enviada',
    });
  }

  // Devuelve las postulaciones junto con el título y empresa de la vacante
  Future<List<Map<String, dynamic>>> obtenerHistorial(int usuarioId) async {
    final db = await _db.database;
    return await db.rawQuery('''
      SELECT p.id, p.fechaPostulacion, p.estado,
             v.titulo, v.empresa, v.categoria, v.modalidad
      FROM postulaciones p
      INNER JOIN vacantes v ON p.vacanteId = v.id
      WHERE p.usuarioId = ?
      ORDER BY p.fechaPostulacion DESC
    ''', [usuarioId]);
  }
}
