import '../database/database_helper.dart';
import '../models/vacante.dart';

class VacanteRepository {
  final _db = DatabaseHelper();

  Future<List<Vacante>> obtenerTodas({
    List<String>? categorias,
    List<String>? modalidades,
    List<String>? jornadas,
  }) async {
    final db = await _db.database;
    final conditions = <String>['activa = 1'];
    final args = <dynamic>[];

    if (categorias != null && categorias.isNotEmpty) {
      final placeholders = List.filled(categorias.length, '?').join(', ');
      conditions.add('LOWER(categoria) IN ($placeholders)');
      args.addAll(categorias.map((c) => c.toLowerCase()));
    }

    if (modalidades != null && modalidades.isNotEmpty) {
      final placeholders = List.filled(modalidades.length, '?').join(', ');
      conditions.add('LOWER(modalidad) IN ($placeholders)');
      args.addAll(modalidades.map((m) => m.toLowerCase()));
    }

    if (jornadas != null && jornadas.isNotEmpty) {
      final placeholders = List.filled(jornadas.length, '?').join(', ');
      conditions.add('LOWER(jornada) IN ($placeholders)');
      args.addAll(jornadas.map((j) => j.toLowerCase()));
    }

    final result = await db.query(
      'vacantes',
      where: conditions.join(' AND '),
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'fechaCierre ASC',
    );
    return result.map(Vacante.fromMap).toList();
  }

  Future<Vacante?> obtenerPorId(int id) async {
    final db = await _db.database;
    final result =
        await db.query('vacantes', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Vacante.fromMap(result.first);
  }

  Future<bool> estaGuardada(int usuarioId, int vacanteId) async {
    final db = await _db.database;
    final result = await db.query(
      'vacantes_guardadas',
      where: 'usuarioId = ? AND vacanteId = ?',
      whereArgs: [usuarioId, vacanteId],
    );
    return result.isNotEmpty;
  }

  Future<void> guardar(int usuarioId, int vacanteId) async {
    final db = await _db.database;
    await db.insert('vacantes_guardadas', {
      'usuarioId': usuarioId,
      'vacanteId': vacanteId,
      'fechaGuardado': DateTime.now().toIso8601String(),
    });
  }

  Future<void> quitarGuardada(int usuarioId, int vacanteId) async {
    final db = await _db.database;
    await db.delete(
      'vacantes_guardadas',
      where: 'usuarioId = ? AND vacanteId = ?',
      whereArgs: [usuarioId, vacanteId],
    );
  }

  Future<List<Vacante>> obtenerGuardadas(int usuarioId) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT v.* FROM vacantes v
      INNER JOIN vacantes_guardadas vg ON v.id = vg.vacanteId
      WHERE vg.usuarioId = ?
      ORDER BY vg.fechaGuardado DESC
    ''', [usuarioId]);
    return result.map(Vacante.fromMap).toList();
  }
}
