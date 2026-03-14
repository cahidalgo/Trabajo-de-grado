import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database/database_helper.dart';
import '../models/usuario.dart';

class UsuarioRepository {
  final _db = DatabaseHelper();

  String hashContrasena(String pass) {
    final bytes = utf8.encode(pass);
    return sha256.convert(bytes).toString();
  }

  Future<int> insertar(Usuario usuario) async {
    final db = await _db.database;
    return await db.insert('usuarios', usuario.toMap());
  }

  Future<bool> existeCorreoOTelefono(String correoOTelefono) async {
    final db = await _db.database;
    final result = await db.query(
      'usuarios',
      where: 'correoOTelefono = ?',
      whereArgs: [correoOTelefono],
    );
    return result.isNotEmpty;
  }

  Future<Usuario?> buscarPorCredenciales(String correoOTelefono, String contrasenaHash) async {
    final db = await _db.database;
    final result = await db.query(
      'usuarios',
      where: 'correoOTelefono = ? AND contrasenaHash = ?',
      whereArgs: [correoOTelefono, contrasenaHash],
    );
    if (result.isEmpty) return null;
    return Usuario.fromMap(result.first);
  }

  Future<void> registrarConsentimiento(int usuarioId) async {
    final db = await _db.database;
    await db.insert('consentimientos_privacidad', {
      'usuarioId': usuarioId,
      'fechaAceptacion': DateTime.now().toIso8601String(),
      'versionPolitica': '1.0',
    });
  }
}
