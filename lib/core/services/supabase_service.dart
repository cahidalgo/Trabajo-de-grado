import 'package:supabase_flutter/supabase_flutter.dart';

/// Punto de acceso único al cliente de Supabase.
/// Reemplaza DatabaseHelper — no hay instancia ni inicialización manual:
/// Supabase.initialize() se llama en main.dart.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  /// Usuario autenticado actualmente (null si no hay sesión)
  static User? get currentUser => client.auth.currentUser;

  /// UUID del usuario autenticado
  static String? get currentAuthId => currentUser?.id;

  /// Email del usuario autenticado
  static String? get currentEmail => currentUser?.email;
}
