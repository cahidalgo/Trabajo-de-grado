import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/usuario.dart';

class UsuarioRepository {
  final _db = SupabaseService.client;

  // ── Helpers de auth ───────────────────────────────────────────
  // Los números de teléfono colombianos se convierten a un email
  // sintético para Supabase Auth, que sólo admite formato email.
  String _toAuthEmail(String correoOTelefono) {
    final limpio = correoOTelefono.trim();
    if (limpio.contains('@')) return limpio;
    // Es número de teléfono → email sintético
    return '$limpio@formalia.co';
  }

  // ── Registro ──────────────────────────────────────────────────
  Future<Usuario> registrar({
    required String correoOTelefono,
    required String contrasena,
    required String? nombreCompleto,
    required bool aceptoPolitica,
  }) async {
    final authEmail = _toAuthEmail(correoOTelefono);

    // 1. Crear usuario en Supabase Auth
    final res = await _db.auth.signUp(
      email: authEmail,
      password: contrasena,
    );
    final authId = res.user!.id;

    // 2. Insertar perfil en tabla usuarios
    final ahora = DateTime.now().toIso8601String();
    final data = await _db.from('usuarios').insert({
      'auth_id':           authId,
      'nombre_completo':   nombreCompleto,
      'correo_o_telefono': correoOTelefono,
      'acepto_politica':   aceptoPolitica,
      'fecha_registro':    ahora,
    }).select().single();

    // 3. Consentimiento
    await _db.from('consentimientos_privacidad').insert({
      'usuario_id':      data['id'],
      'version_politica': '1.0',
    });

    return Usuario.fromMap(data);
  }

  // ── Login ─────────────────────────────────────────────────────
  Future<Usuario?> login(String correoOTelefono, String contrasena) async {
    final authEmail = _toAuthEmail(correoOTelefono);
    try {
      final res = await _db.auth.signInWithPassword(
        email: authEmail,
        password: contrasena,
      );
      if (res.user == null) return null;

      final data = await _db
          .from('usuarios')
          .select()
          .eq('auth_id', res.user!.id)
          .maybeSingle();

      if (data == null) return null;
      return Usuario.fromMap(data);
    } on AuthException {
      return null;
    }
  }

  // ── Obtener usuario autenticado actual ────────────────────────
  Future<Usuario?> obtenerActual() async {
    final authId = SupabaseService.currentAuthId;
    if (authId == null) return null;
    final data = await _db
        .from('usuarios')
        .select()
        .eq('auth_id', authId)
        .maybeSingle();
    if (data == null) return null;
    return Usuario.fromMap(data);
  }

  Future<Usuario?> obtenerPorId(int id) async {
    final data = await _db
        .from('usuarios')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return Usuario.fromMap(data);
  }

  Future<bool> existeCorreoOTelefono(String correoOTelefono) async {
    final data = await _db
        .from('usuarios')
        .select('id')
        .eq('correo_o_telefono', correoOTelefono)
        .maybeSingle();
    return data != null;
  }

  Future<void> actualizarNombre(int id, String nuevoNombre) async {
    await _db
        .from('usuarios')
        .update({'nombre_completo': nuevoNombre})
        .eq('id', id);
  }

  Future<void> actualizarContrasena(String nuevaContrasena) async {
    await _db.auth.updateUser(UserAttributes(password: nuevaContrasena));
  }

  Future<void> cerrarSesion() async {
    await _db.auth.signOut();
  }
}
