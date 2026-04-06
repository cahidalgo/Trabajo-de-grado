import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/empresa_model.dart';

class EmpresaRepository {
  final _db = SupabaseService.client;

  // ── Registro ──────────────────────────────────────────────────
  Future<EmpresaModel> registrarEmpresa({
    required String razonSocial,
    required String nit,
    required String sector,
    required String correo,
    String? telefono,
    required String contrasena,
  }) async {
    // 1. Crear usuario en Supabase Auth
    final res = await _db.auth.signUp(
      email: correo,
      password: contrasena,
    );
    final authId = res.user!.id;

    // 2. Insertar en tabla empresas
    final data = await _db.from('empresas').insert({
      'auth_id':        authId,
      'razon_social':   razonSocial,
      'nit':            nit,
      'sector':         sector,
      'correo':         correo,
      'telefono':       telefono,
      'validado':       false,
      'fecha_registro': DateTime.now().toIso8601String(),
    }).select().single();

    return EmpresaModel.fromMap(data);
  }

  // ── Login ─────────────────────────────────────────────────────
  Future<EmpresaModel?> login(String correo, String contrasena) async {
    try {
      final res = await _db.auth.signInWithPassword(
        email: correo,
        password: contrasena,
      );
      if (res.user == null) return null;

      final data = await _db
          .from('empresas')
          .select()
          .eq('auth_id', res.user!.id)
          .maybeSingle();

      if (data == null) return null;
      return EmpresaModel.fromMap(data);
    } on AuthException {
      return null;
    }
  }

  // ── Obtener empresa del usuario autenticado ───────────────────
  Future<EmpresaModel?> obtenerActual() async {
    final authId = SupabaseService.currentAuthId;
    if (authId == null) return null;
    final data = await _db
        .from('empresas')
        .select()
        .eq('auth_id', authId)
        .maybeSingle();
    if (data == null) return null;
    return EmpresaModel.fromMap(data);
  }

  Future<EmpresaModel?> obtenerPorId(int id) async {
    final data = await _db
        .from('empresas')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return EmpresaModel.fromMap(data);
  }

  Future<bool> nitExiste(String nit) async {
    final data = await _db
        .from('empresas')
        .select('id')
        .eq('nit', nit)
        .maybeSingle();
    return data != null;
  }

  Future<bool> correoExiste(String correo) async {
    final data = await _db
        .from('empresas')
        .select('id')
        .eq('correo', correo)
        .maybeSingle();
    return data != null;
  }

  Future<void> actualizarEmpresa(EmpresaModel empresa) async {
    await _db
        .from('empresas')
        .update(empresa.toUpdateMap())
        .eq('id', empresa.id!);
  }

  Future<void> actualizarContrasena(String nuevaContrasena) async {
    await _db.auth.updateUser(UserAttributes(password: nuevaContrasena));
  }

  Future<void> cerrarSesion() async {
    await _db.auth.signOut();
  }
}
