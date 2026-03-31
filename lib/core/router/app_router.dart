import 'package:go_router/go_router.dart';
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
import '../../views/empresas/publicar_vacante_screen.dart';
import '../../views/empresas/postulantes_screen.dart';
import '../../views/admin/admin_shell_screen.dart';
import '../../data/models/vacante_empresa_model.dart';

final appRouter = GoRouter(
  initialLocation: '/',
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
    GoRoute(path: '/empresa/publicar', builder: (_, __) => const PublicarVacanteScreen()),
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