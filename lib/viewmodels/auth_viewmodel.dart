import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
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

// ── Credenciales admin (hardcoded para MVP) ───────────────────
const _kAdminCorreo = 'admin@vendedorestm.com';
const _kAdminContrasena = 'Admin123*';

class AuthViewModel extends ChangeNotifier {
  final _repo       = UsuarioRepository();
  final _empresaRepo = EmpresaRepository();

  AuthState _state   = AuthState.idle;
  String?   _errorMsg;
  int?      _usuarioIdActual;

  AuthState get state     => _state;
  String?   get errorMsg  => _errorMsg;
  int?      get usuarioId => _usuarioIdActual;

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

    try {
      // 1. Admin hardcoded — also authenticate with Supabase for RLS
      if (input == _kAdminCorreo && contrasena == _kAdminContrasena) {
        // Intentar autenticar en Supabase (el admin debe existir en auth.users)
        try {
          await SupabaseService.client.auth.signInWithPassword(
            email: _kAdminCorreo,
            password: _kAdminContrasena,
          );
        } catch (_) {
          // Si no existe en Supabase Auth, continuar sin sesión
        }
        _state = AuthState.loginAdmin;
        notifyListeners();
        return;
      }

      // 2. Intentar como vendedor
      final usuario = await _repo.login(input, contrasena);
      if (usuario != null) {
        _usuarioIdActual = usuario.id;
        _state = AuthState.loginExitoso;
        notifyListeners();
        return;
      }

      // Si el login de vendedor retornó null (email autenticó pero no
      // está en tabla usuarios), cerrar la sesión antes de continuar.
      if (SupabaseService.currentUser != null) {
        await SupabaseService.client.auth.signOut();
      }

      // 3. Intentar como empresa (solo si parece email)
      if (input.contains('@')) {
        final empresa = await _empresaRepo.login(input, contrasena);
        if (empresa != null) {
          _state = AuthState.loginEmpresa;
          notifyListeners();
          return;
        }
        if (SupabaseService.currentUser != null) {
          await SupabaseService.client.auth.signOut();
        }
      }

      // 4. No encontrado
      _errorMsg = 'Correo/celular o contraseña incorrectos.';
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
  // Devuelve 'vendedor', 'empresa', 'admin' o null
  Future<String?> restaurarSesion() async {
    final user = SupabaseService.currentUser;
    if (user == null) return null;

    // Verificar si es vendedor
    final usuarioData = await SupabaseService.client
        .from('usuarios')
        .select('id')
        .eq('auth_id', user.id)
        .maybeSingle();
    if (usuarioData != null) {
      _usuarioIdActual = usuarioData['id'] as int;
      return 'vendedor';
    }

    // Verificar si es empresa
    final empresaData = await SupabaseService.client
        .from('empresas')
        .select('id')
        .eq('auth_id', user.id)
        .maybeSingle();
    if (empresaData != null) return 'empresa';

    return null;
  }

  // ── Cerrar sesión ─────────────────────────────────────────────
  Future<void> cerrarSesion() async {
    await SupabaseService.client.auth.signOut();
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
