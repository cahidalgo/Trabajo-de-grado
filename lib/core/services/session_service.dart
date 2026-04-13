/// Guarda el rol del usuario autenticado en memoria durante la sesión.
/// Se popula desde SplashScreen y AuthViewModel, y se limpia al cerrar sesión.
/// El router lo lee de forma síncrona para el guard de rutas.
class SessionService {
  SessionService._();

  /// Valores posibles: 'vendedor' | 'empresa' | 'admin' | null
  static String? rolActual;

  static void setRol(String? rol) => rolActual = rol;
  static void limpiar()           => rolActual = null;

  /// Ruta home según el rol. Usado en el guard del router.
  static String homeParaRol() {
    switch (rolActual) {
      case 'empresa': return '/empresa/dashboard';
      case 'admin':   return '/admin';
      default:        return '/home';
    }
  }
}
