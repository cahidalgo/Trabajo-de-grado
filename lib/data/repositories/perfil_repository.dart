import '../database/database_helper.dart';
import '../models/perfil.dart';

class PerfilRepository {
  final _db = DatabaseHelper();

  Future<void> guardar(Perfil perfil) async {
    final db = await _db.database;
    final existe = await db.query('perfiles', where: 'usuarioId = ?', whereArgs: [perfil.usuarioId]);
    if (existe.isEmpty) {
      await db.insert('perfiles', perfil.toMap());
    } else {
      await db.update('perfiles', perfil.toMap(), where: 'usuarioId = ?', whereArgs: [perfil.usuarioId]);
    }
  }

  Future<Perfil?> obtenerPorUsuario(int usuarioId) async {
    final db = await _db.database;
    final result = await db.query('perfiles', where: 'usuarioId = ?', whereArgs: [usuarioId]);
    if (result.isEmpty) return null;
    return Perfil.fromMap(result.first);
  }

  Future<bool> estaCompleto(int usuarioId) async {
    final perfil = await obtenerPorUsuario(usuarioId);
    return perfil?.perfilCompleto ?? false;
  }
}
