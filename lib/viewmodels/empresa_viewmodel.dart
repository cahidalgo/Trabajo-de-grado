import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/empresa_model.dart';
import '../data/repositories/empresa_repository.dart';

class EmpresaViewModel extends ChangeNotifier {
  final EmpresaRepository _repo = EmpresaRepository();

  EmpresaModel? empresaActual;
  String? errorMensaje;
  bool cargando = false;

  Future<void> _persistirSesion(int empresaId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuarioId');
    await prefs.setInt('empresaId', empresaId);
    await prefs.setString('rolUsuario', 'empresa');
  }

  Future<void> restaurarSesion() async {
    if (empresaActual != null) return;

    cargando = true;
    errorMensaje = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final empresaId = prefs.getInt('empresaId');

    if (empresaId != null) {
      empresaActual = await _repo.obtenerPorId(empresaId);
      if (empresaActual == null) {
        await prefs.remove('empresaId');
        await prefs.remove('rolUsuario');
      }
    }

    cargando = false;
    notifyListeners();
  }

  Future<bool> registrar({
    required String razonSocial,
    required String nit,
    required String sector,
    required String correo,
    String? telefono,
    required String contrasena,
  }) async {
    cargando = true;
    errorMensaje = null;
    notifyListeners();

    if (await _repo.nitExiste(nit)) {
      errorMensaje = 'Este NIT ya está registrado.';
      cargando = false;
      notifyListeners();
      return false;
    }
    if (await _repo.correoExiste(correo)) {
      errorMensaje = 'Este correo ya está registrado.';
      cargando = false;
      notifyListeners();
      return false;
    }

    final empresa = EmpresaModel(
      razonSocial: razonSocial,
      nit: nit,
      sector: sector,
      correo: correo,
      telefono: telefono,
      contrasenaHash: contrasena,
      fechaRegistro: DateTime.now().toIso8601String(),
    );

    final id = await _repo.registrarEmpresa(empresa);

    empresaActual = empresa.copyWith(id: id);
    await _persistirSesion(id);

    cargando = false;
    notifyListeners();
    return true;
  }

  Future<bool> iniciarSesion(String correo, String contrasena) async {
    cargando = true;
    errorMensaje = null;
    notifyListeners();

    final empresa = await _repo.login(correo, contrasena);
    if (empresa == null) {
      errorMensaje = 'Correo o contraseña incorrectos.';
      cargando = false;
      notifyListeners();
      return false;
    }

    empresaActual = empresa;
    await _persistirSesion(empresa.id!);

    cargando = false;
    notifyListeners();
    return true;
  }

  /// Actualiza los datos editables de la empresa
  Future<bool> actualizarPerfil({
    required String razonSocial,
    required String telefono,
    required String descripcion,
  }) async {
    if (empresaActual == null) return false;
    cargando = true;
    errorMensaje = null;
    notifyListeners();

    final actualizada = empresaActual!.copyWith(
      razonSocial: razonSocial,
      telefono: telefono.trim().isEmpty ? null : telefono.trim(),
      descripcion: descripcion.trim().isEmpty ? null : descripcion.trim(),
    );

    await _repo.actualizarEmpresa(actualizada);
    empresaActual = actualizada;

    cargando = false;
    notifyListeners();
    return true;
  }

  /// Guarda ruta de foto de perfil de la empresa
  Future<void> actualizarFoto(String rutaFoto) async {
    if (empresaActual == null) return;
    final actualizada = empresaActual!.copyWith(fotoPerfil: rutaFoto);
    await _repo.actualizarEmpresa(actualizada);
    empresaActual = actualizada;
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuarioId');
    await prefs.remove('empresaId');
    await prefs.remove('rolUsuario');
    empresaActual = null;
    notifyListeners();
  }
}
