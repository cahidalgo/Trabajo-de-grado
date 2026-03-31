import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/empresa_model.dart';
import '../database/database_helper.dart';

class EmpresaRepository {
  final DatabaseHelper _db = DatabaseHelper();

  String _hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<int> registrarEmpresa(EmpresaModel empresa) async {
    final db = await _db.database;
    // Hashear la contraseña y usar copyWith para no perder ningún campo
    final empresaConHash = empresa.copyWith(
      contrasenaHash: _hashPassword(empresa.contrasenaHash),
    );
    return db.insert('empresas', empresaConHash.toMap());
  }

  Future<EmpresaModel?> login(String correo, String contrasena) async {
    final db = await _db.database;
    final hash = _hashPassword(contrasena);
    final result = await db.query(
      'empresas',
      where: 'correo = ? AND contrasena_hash = ?',
      whereArgs: [correo, hash],
    );
    if (result.isEmpty) return null;
    return EmpresaModel.fromMap(result.first);
  }

  Future<EmpresaModel?> obtenerPorId(int id) async {
    final db = await _db.database;
    final result = await db.query(
      'empresas',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return EmpresaModel.fromMap(result.first);
  }

  Future<bool> nitExiste(String nit) async {
    final db = await _db.database;
    final result =
        await db.query('empresas', where: 'nit = ?', whereArgs: [nit]);
    return result.isNotEmpty;
  }

  Future<bool> correoExiste(String correo) async {
    final db = await _db.database;
    final result = await db
        .query('empresas', where: 'correo = ?', whereArgs: [correo]);
    return result.isNotEmpty;
  }

  Future<void> actualizarEmpresa(EmpresaModel empresa) async {
    final db = await _db.database;
    await db.update(
      'empresas',
      empresa.toMap(),
      where: 'id = ?',
      whereArgs: [empresa.id],
    );
  }

  Future<void> actualizarContrasena(int id, String hashContrasena) async {
    final db = await _db.database;
    await db.update(
      'empresas',
      {'contrasena': hashContrasena},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
