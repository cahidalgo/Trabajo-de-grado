import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/usuario_repository.dart';
import '../data/repositories/empresa_repository.dart';
import '../data/models/usuario.dart';

enum AuthState {
  idle,
  loading,
  registroExitoso,
  loginExitoso,
  loginEmpresa,
  loginAdmin, // ✅ nuevo
  error,
}

// ── Credenciales admin (hardcoded para MVP) ────────────────────
const _kAdminCorreo = 'admin@vendedorestm.com';
const _kAdminContrasena = 'Admin123*';

class AuthViewModel extends ChangeNotifier {
  final _repo = UsuarioRepository();
  final _empresaRepo = EmpresaRepository();

  AuthState _state = AuthState.idle;
  String? _errorMsg;
  int? _usuarioIdActual;

  AuthState get state => _state;
  String? get errorMsg => _errorMsg;
  int? get usuarioId => _usuarioIdActual;

  Future<void> registrar({
    required String nombreCompleto,
    required String correoOTelefono,
    required String contrasena,
    required bool aceptoPolitica,
  }) async {
    _state = AuthState.loading;
    notifyListeners();
    try {
      final existe = await _repo.existeCorreoOTelefono(correoOTelefono);
      if (existe) {
        _errorMsg = 'Este correo o celular ya está registrado.';
        _state = AuthState.error;
        notifyListeners();
        return;
      }
      final hash = _repo.hashContrasena(contrasena);
      final usuario = Usuario(
        nombreCompleto: nombreCompleto,
        correoOTelefono: correoOTelefono,
        contrasenaHash: hash,
        aceptoPolitica: true,
        fechaRegistro: DateTime.now().toIso8601String(),
      );
      final id = await _repo.insertar(usuario);
      await _repo.registrarConsentimiento(id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('empresaId');
      await prefs.setInt('usuarioId', id);
      await prefs.setString('rolUsuario', 'vendedor');
      _usuarioIdActual = id;
      _state = AuthState.registroExitoso;
    } catch (_) {
      _errorMsg = 'Ocurrió un error. Intenta de nuevo.';
      _state = AuthState.error;
    }
    notifyListeners();
  }

  Future<void> iniciarSesion({
    required String correoOTelefono,
    required String contrasena,
  }) async {
    _state = AuthState.loading;
    notifyListeners();
    try {
      final hash = _repo.hashContrasena(contrasena);

      // 1. Vendedor
      final usuario = await _repo.buscarPorCredenciales(
          correoOTelefono.trim(), hash);
      if (usuario != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('empresaId');
        await prefs.setInt('usuarioId', usuario.id!);
        await prefs.setString('rolUsuario', 'vendedor');
        _usuarioIdActual = usuario.id;
        _state = AuthState.loginExitoso;
        notifyListeners();
        return;
      }

      // 2. Empresa
      final empresa =
          await _empresaRepo.login(correoOTelefono.trim(), contrasena);
      if (empresa != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('usuarioId');
        await prefs.setInt('empresaId', empresa.id!);
        await prefs.setString('rolUsuario', 'empresa');
        _state = AuthState.loginEmpresa;
        notifyListeners();
        return;
      }

      // 3. ✅ Administrador (credenciales fijas)
      if (correoOTelefono.trim() == _kAdminCorreo &&
          contrasena == _kAdminContrasena) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('usuarioId');
        await prefs.remove('empresaId');
        await prefs.setString('rolUsuario', 'admin');
        _state = AuthState.loginAdmin;
        notifyListeners();
        return;
      }

      // 4. No encontrado
      _errorMsg =
          'Correo/celular o contraseña incorrectos. Intenta de nuevo.';
      _state = AuthState.error;
    } catch (_) {
      _errorMsg = 'Ocurrió un error. Intenta de nuevo.';
      _state = AuthState.error;
    }
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuarioId');
    await prefs.remove('empresaId');
    await prefs.remove('rolUsuario');
    _usuarioIdActual = null;
    _state = AuthState.idle;
    notifyListeners();
  }

  void resetState() {
    _state = AuthState.idle;
    _errorMsg = null;
    notifyListeners();
  }
}