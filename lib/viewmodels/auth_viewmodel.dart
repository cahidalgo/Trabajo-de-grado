import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/session_service.dart';
import '../data/repositories/usuario_repository.dart';
import '../data/repositories/empresa_repository.dart';

enum AuthState {
  idle,
  loading,
  registroExitoso,
  loginExitoso,
  loginEmpresa,
  loginAdmin,
  error,
}

class AuthViewModel extends ChangeNotifier {
  final _repo        = UsuarioRepository();
  final _empresaRepo = EmpresaRepository();

  AuthState _state  = AuthState.idle;
  String?   _errorMsg;
  int?      _usuarioIdActual;

  AuthState get state     => _state;
  String?   get errorMsg  => _errorMsg;
  int?      get usuarioId => _usuarioIdActual;

  // ── Helper: consultar si un auth_id es admin ──────────────────
  static Future<bool> _esAdmin(String authId) async {
    final data = await SupabaseService.client
        .from('admins')
        .select('id')
        .eq('auth_id', authId)
        .maybeSingle();
    return data != null;
  }

  // ── Registro vendedor ─────────────────────────────────────────
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
        _state    = AuthState.error;
        notifyListeners();
        return;
      }

      final usuario = await _repo.registrar(
        correoOTelefono: correoOTelefono,
        contrasena:      contrasena,
        nombreCompleto:  nombreCompleto,
        aceptoPolitica:  aceptoPolitica,
      );

      _usuarioIdActual = usuario.id;
      SessionService.setRol('vendedor');
      _state = AuthState.registroExitoso;
    } on AuthException catch (e) {
      _errorMsg = e.message;
      _state    = AuthState.error;
    } catch (_) {
      _errorMsg = 'Ocurrió un error. Intenta de nuevo.';
      _state    = AuthState.error;
    }
    notifyListeners();
  }

  // ── Login unificado (vendedor, empresa o admin) ───────────────
  Future<void> iniciarSesion({
    required String correoOTelefono,
    required String contrasena,
  }) async {
    _state = AuthState.loading;
    notifyListeners();

    final input = correoOTelefono.trim();
    final db    = SupabaseService.client;

    try {
      // ── 1. Construir el email para Supabase Auth ───────────────
      String authEmail = input;
      if (!input.contains('@')) {
        authEmail = '$input@formalia.co';
      }

      // ── 2. Autenticar UNA sola vez ─────────────────────────────
      final AuthResponse res;
      try {
        res = await db.auth.signInWithPassword(
          email:    authEmail,
          password: contrasena,
        );
      } on AuthException {
        _errorMsg = 'Correo/celular o contraseña incorrectos.';
        _state    = AuthState.error;
        notifyListeners();
        return;
      }

      if (res.user == null) {
        _errorMsg = 'Correo/celular o contraseña incorrectos.';
        _state    = AuthState.error;
        notifyListeners();
        return;
      }

      final authId = res.user!.id;

      // ── 3. Determinar el rol consultando las tablas ────────────
      if (await _esAdmin(authId)) {
        SessionService.setRol('admin');
        _state = AuthState.loginAdmin;
        notifyListeners();
        return;
      }

      final usuarioData = await db
          .from('usuarios')
          .select('id')
          .eq('auth_id', authId)
          .maybeSingle();

      if (usuarioData != null) {
        _usuarioIdActual = usuarioData['id'] as int;
        SessionService.setRol('vendedor');
        _state = AuthState.loginExitoso;
        notifyListeners();
        return;
      }

      final empresaData = await db
          .from('empresas')
          .select('id')
          .eq('auth_id', authId)
          .maybeSingle();

      if (empresaData != null) {
        SessionService.setRol('empresa');
        _state = AuthState.loginEmpresa;
        notifyListeners();
        return;
      }

      // Auth exitoso pero no está en ninguna tabla
      await db.auth.signOut();
      SessionService.limpiar();
      _errorMsg = 'Cuenta no encontrada. Contacta soporte.';
      _state    = AuthState.error;
    } on AuthException catch (e) {
      _errorMsg = e.message;
      _state    = AuthState.error;
    } catch (_) {
      _errorMsg = 'Ocurrió un error. Intenta de nuevo.';
      _state    = AuthState.error;
    }
    notifyListeners();
  }

  // ── Restaurar sesión desde Supabase Auth ──────────────────────
  Future<String?> restaurarSesion() async {
    final user = SupabaseService.currentUser;
    if (user == null) return null;

    if (await _esAdmin(user.id)) {
      SessionService.setRol('admin');
      return 'admin';
    }

    final usuarioData = await SupabaseService.client
        .from('usuarios')
        .select('id')
        .eq('auth_id', user.id)
        .maybeSingle();
    if (usuarioData != null) {
      _usuarioIdActual = usuarioData['id'] as int;
      SessionService.setRol('vendedor');
      return 'vendedor';
    }

    final empresaData = await SupabaseService.client
        .from('empresas')
        .select('id')
        .eq('auth_id', user.id)
        .maybeSingle();
    if (empresaData != null) {
      SessionService.setRol('empresa');
      return 'empresa';
    }

    return null;
  }

  // ── Cerrar sesión ─────────────────────────────────────────────
  Future<void> cerrarSesion() async {
    await SupabaseService.client.auth.signOut();
    SessionService.limpiar();
    _usuarioIdActual = null;
    _state = AuthState.idle;
    notifyListeners();
  }

  void resetState() {
    _state    = AuthState.idle;
    _errorMsg = null;
    notifyListeners();
  }
}
