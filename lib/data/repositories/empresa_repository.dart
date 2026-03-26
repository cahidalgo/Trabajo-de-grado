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
    return await db.insert('empresas', empresa.toMap());
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

  Future<bool> nitExiste(String nit) async {
    final db = await _db.database;
    final result = await db.query('empresas',
        where: 'nit = ?', whereArgs: [nit]);
    return result.isNotEmpty;
  }

  Future<bool> correoExiste(String correo) async {
    final db = await _db.database;
    final result = await db.query('empresas',
        where: 'correo = ?', whereArgs: [correo]);
    return result.isNotEmpty;
  }
}
