import 'package:flutter/foundation.dart';
import '../data/repositories/usuario_repository.dart';
import '../data/models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthState { idle, loading, registroExitoso, loginExitoso, error }

class AuthViewModel extends ChangeNotifier {
  final _repo = UsuarioRepository();

  AuthState _state = AuthState.idle;
  String?   _errorMsg;
  int?      _usuarioIdActual;

  AuthState get state        => _state;
  String?   get errorMsg     => _errorMsg;
  int?      get usuarioId    => _usuarioIdActual;

  Future<void> registrar({
    required String correoOTelefono,
    required String contrasena,
    required bool aceptoPolitica,
  }) async {
    if (!aceptoPolitica) {
      _errorMsg = 'Debes aceptar la política de privacidad para continuar.';
      _state = AuthState.error;
      notifyListeners();
      return;
    }

    _state = AuthState.loading;
    notifyListeners();

    try {
      final existe = await _repo.existeCorreoOTelefono(correoOTelefono.trim());
      if (existe) {
        _errorMsg = 'Este correo o celular ya está registrado.';
        _state = AuthState.error;
        notifyListeners();
        return;
      }

      final hash = _repo.hashContrasena(contrasena);
      final usuario = Usuario(
        correoOTelefono: correoOTelefono.trim(),
        contrasenaHash: hash,
        aceptoPolitica: true,
        fechaRegistro: DateTime.now().toIso8601String(),
      );

      final id = await _repo.insertar(usuario);
      await _repo.registrarConsentimiento(id);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('usuarioId', id);

      _usuarioIdActual = id;
      _state = AuthState.registroExitoso;
    } catch (e) {
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
      final usuario = await _repo.buscarPorCredenciales(correoOTelefono.trim(), hash);

      if (usuario != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('usuarioId', usuario.id!);
        _usuarioIdActual = usuario.id;
        _state = AuthState.loginExitoso;
      } else {
        // Mensaje genérico: no revela si el error es correo o contraseña (RNF05)
        _errorMsg = 'Correo/celular o contraseña incorrectos. Intenta de nuevo.';
        _state = AuthState.error;
      }
    } catch (e) {
      _errorMsg = 'Ocurrió un error. Intenta de nuevo.';
      _state = AuthState.error;
    }
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuarioId');
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
