import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../data/models/empresa_model.dart';
import '../data/repositories/empresa_repository.dart';

/// Traduce mensajes de error de Supabase Auth a español
String _traducirErrorAuth(String msg) {
  if (msg.contains('invalid') && msg.contains('mail')) {
    return 'El correo electrónico no es válido. Usa un correo real (ej: empresa@gmail.com).';
  }
  if (msg.contains('already registered')) {
    return 'Este correo ya está registrado en el sistema.';
  }
  if (msg.contains('weak_password') || msg.contains('password')) {
    return 'La contraseña no cumple los requisitos mínimos.';
  }
  return 'Error de autenticación: $msg';
}

class EmpresaViewModel extends ChangeNotifier {
  final _repo = EmpresaRepository();

  EmpresaModel? empresaActual;
  String?       errorMensaje;
  bool          cargando = false;

  // ── Restaurar sesión activa ───────────────────────────────────
  Future<void> restaurarSesion() async {
    if (empresaActual != null) return;
    cargando = true;
    notifyListeners();

    empresaActual = await _repo.obtenerActual();

    cargando = false;
    notifyListeners();
  }

  // ── Registro ──────────────────────────────────────────────────
  Future<bool> registrar({
    required String razonSocial,
    required String nit,
    required String sector,
    required String correo,
    String? telefono,
    required String contrasena,
  }) async {
    cargando      = true;
    errorMensaje  = null;
    notifyListeners();

    if (await _repo.nitExiste(nit)) {
      errorMensaje = 'Este NIT ya está registrado.';
      cargando     = false;
      notifyListeners();
      return false;
    }
    if (await _repo.correoExiste(correo)) {
      errorMensaje = 'Este correo ya está registrado.';
      cargando     = false;
      notifyListeners();
      return false;
    }

    try {
      empresaActual = await _repo.registrarEmpresa(
        razonSocial: razonSocial,
        nit:         nit,
        sector:      sector,
        correo:      correo,
        telefono:    telefono,
        contrasena:  contrasena,
      );
    } on AuthException catch (e) {
      errorMensaje = _traducirErrorAuth(e.message);
      cargando     = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMensaje = 'Error al registrar la empresa. Intenta de nuevo.';
      cargando     = false;
      notifyListeners();
      return false;
    }

    cargando = false;
    notifyListeners();
    return true;
  }

  // ── Login ─────────────────────────────────────────────────────
  Future<bool> iniciarSesion(String correo, String contrasena) async {
    cargando     = true;
    errorMensaje = null;
    notifyListeners();

    final empresa = await _repo.login(correo, contrasena);
    if (empresa == null) {
      errorMensaje = 'Correo o contraseña incorrectos.';
      cargando     = false;
      notifyListeners();
      return false;
    }

    empresaActual = empresa;
    cargando      = false;
    notifyListeners();
    return true;
  }

  // ── Actualizar perfil ─────────────────────────────────────────
  Future<bool> actualizarPerfil({
    required String razonSocial,
    required String telefono,
    required String descripcion,
  }) async {
    if (empresaActual == null) return false;
    cargando     = true;
    errorMensaje = null;
    notifyListeners();

    final actualizada = empresaActual!.copyWith(
      razonSocial: razonSocial,
      telefono:    telefono.trim().isEmpty ? null : telefono.trim(),
      descripcion: descripcion.trim().isEmpty ? null : descripcion.trim(),
    );

    await _repo.actualizarEmpresa(actualizada);
    empresaActual = actualizada;

    cargando = false;
    notifyListeners();
    return true;
  }

  Future<void> actualizarFoto(String rutaFoto) async {
    if (empresaActual == null) return;
    final actualizada = empresaActual!.copyWith(fotoPerfil: rutaFoto);
    await _repo.actualizarEmpresa(actualizada);
    empresaActual = actualizada;
    notifyListeners();
  }

  Future<void> actualizarContrasena(String nuevaContrasena) async {
    await _repo.actualizarContrasena(nuevaContrasena);
  }

  // ── Cerrar sesión ─────────────────────────────────────────────
  Future<void> cerrarSesion() async {
    await SupabaseService.client.auth.signOut();
    empresaActual = null;
    notifyListeners();
  }
}
