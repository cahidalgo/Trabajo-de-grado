import '../database/database_helper.dart';
import '../models/formacion.dart';

class FormacionRepository {
  final _db = DatabaseHelper();

  Future<List<Formacion>> obtenerTodas({String? categoria}) async {
    final db = await _db.database;
    if (categoria != null) {
      final result = await db.query('formacion', where: 'categoria = ?', whereArgs: [categoria]);
      return result.map(Formacion.fromMap).toList();
    }
    final result = await db.query('formacion');
    return result.map(Formacion.fromMap).toList();
  }
}
