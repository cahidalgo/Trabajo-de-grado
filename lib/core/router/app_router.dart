import 'package:go_router/go_router.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/session_service.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/registro_screen.dart';
import '../../views/onboarding/onboarding_screen.dart';
import '../../views/home/home_screen.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/perfil/completar_perfil_screen.dart';
import '../../views/perfil/editar_perfil_screen.dart';
import '../../views/legal/politica_privacidad_screen.dart';
import '../../views/empresas/empresa_registro_screen.dart';
import '../../views/empresas/empresa_dashboard_screen.dart';
import '../../views/empresas/editar_empresa_screen.dart';
import '../../views/empresas/publicar_vacante_screen.dart';
import '../../views/empresas/postulantes_screen.dart';
import '../../views/empresas/editar_vacante_screen.dart';
import '../../views/admin/admin_shell_screen.dart';
import '../../data/models/vacante_empresa_model.dart';

// ── Rutas que NO requieren sesión ────────────────────────────
const _rutasPublicas = {
  '/',
  '/login',
  '/registro',
  '/empresa/registro',
  '/politica-privacidad',
};

// ── Prefijos / rutas exclusivas por rol ──────────────────────
const _prefijoEmpresa = '/empresa/';
const _rutasEmpresaExactas = {
  '/empresa/dashboard',
  '/empresa/editar',
  '/empresa/publicar',
  '/empresa/publicar-confirmacion',
  '/empresa/editar-vacante',
  '/empresa/postulantes',
};

const _rutasAdmin = {'/admin'};

// Rutas que solo puede ver un vendedor (no empresa ni admin)
const _rutasVendedor = {
  '/home',
  '/editar-perfil',
  '/completar-perfil',
  '/onboarding',
};

String? _guardRol(String ruta, String? rol) {
  final esEmpresaRuta = ruta.startsWith(_prefijoEmpresa) ||
      _rutasEmpresaExactas.contains(ruta);
  final esAdminRuta   = _rutasAdmin.any((r) => ruta.startsWith(r));
  final esVendedorRuta = _rutasVendedor.contains(ruta);

  // Empresa intentando ir a rutas de vendedor o admin
  if (rol == 'empresa' && (esVendedorRuta || esAdminRuta)) {
    return '/empresa/dashboard';
  }

  // Admin intentando ir a rutas de vendedor o empresa
  if (rol == 'admin' && (esVendedorRuta || esEmpresaRuta)) {
    return '/admin';
  }

  // Vendedor intentando ir a rutas de empresa o admin
  if (rol == 'vendedor' && (esEmpresaRuta || esAdminRuta)) {
    return '/home';
  }

  // Usuario logueado intentando acceder a ruta protegida sin rol cargado
  // (raro, pero posible en race conditions — dejamos pasar; splash resuelve)

  return null; // sin redirección
}

final appRouter = GoRouter(
  initialLocation: '/',

  // ── Route guard global ──────────────────────────────────────
  redirect: (context, state) {
    final loggedIn = SupabaseService.currentUser != null;
    final ruta     = state.matchedLocation;
    final rol      = SessionService.rolActual;

    // 1. Sin sesión → solo rutas públicas
    if (!loggedIn && !_rutasPublicas.contains(ruta)) {
      return '/login';
    }

    // 2. Con sesión → no dejar volver a login/registro
    if (loggedIn && (ruta == '/login' || ruta == '/registro')) {
      return SessionService.homeParaRol();
    }

    // 3. Con sesión + rol conocido → protección por rol
    if (loggedIn && rol != null) {
      final redireccion = _guardRol(ruta, rol);
      if (redireccion != null) return redireccion;
    }

    return null;
  },

  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/registro', builder: (_, __) => const RegistroScreen()),
    GoRoute(path: '/completar-perfil', builder: (_, __) => const CompletarPerfilScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/editar-perfil', builder: (_, __) => const EditarPerfilScreen()),
    GoRoute(path: '/politica-privacidad', builder: (_, __) => const PoliticaPrivacidadScreen()),

    // ── Módulo empresa ────────────────────────────────────────
    GoRoute(path: '/empresa/registro', builder: (_, __) => const EmpresaRegistroScreen()),
    GoRoute(path: '/empresa/dashboard', builder: (_, __) => const EmpresaDashboardScreen()),
    GoRoute(path: '/empresa/editar', builder: (_, __) => const EditarEmpresaScreen()),
    GoRoute(path: '/empresa/publicar', builder: (_, __) => const PublicarVacanteScreen()),
    GoRoute(
      path: '/empresa/publicar-confirmacion',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>;
        return VacantePublicadaScreen(
          titulo: extra['titulo'] as String,
          empresaValidada: extra['validada'] as bool,
        );
      },
    ),
    GoRoute(
      path: '/empresa/editar-vacante',
      builder: (_, state) {
        final vacante = state.extra as VacanteEmpresaModel;
        return EditarVacanteScreen(vacante: vacante);
      },
    ),
    GoRoute(
      path: '/empresa/postulantes',
      builder: (_, state) {
        final vacante = state.extra as VacanteEmpresaModel;
        return PostulantesScreen(vacante: vacante);
      },
    ),

    // ── Módulo admin ──────────────────────────────────────────
    GoRoute(path: '/admin', builder: (_, __) => const AdminShellScreen()),
  ],
);
