import 'package:flutter/material.dart';
import '../data/repositories/empresa_repository.dart';
import '../data/models/empresa_model.dart';

class EmpresaViewModel extends ChangeNotifier {
  final EmpresaRepository _repo = EmpresaRepository();

  EmpresaModel? empresaActual;
  String? errorMensaje;
  bool cargando = false;

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

    // ✅ Asigna empresaActual con el id generado por SQLite
    empresaActual = EmpresaModel(
      id: id,
      razonSocial: razonSocial,
      nit: nit,
      sector: sector,
      correo: correo,
      telefono: telefono,
      contrasenaHash: contrasena,
      fechaRegistro: empresa.fechaRegistro,
    );

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
    cargando = false;
    notifyListeners();
    return true;
  }

  void cerrarSesion() {
    empresaActual = null;
    notifyListeners();
  }
}
