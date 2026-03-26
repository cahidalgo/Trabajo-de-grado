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
import '../../data/models/vacante_empresa_model.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Rutas existentes ───────────────────────────────────────
    GoRoute(path: '/',                   builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/login',              builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/registro',           builder: (_, _) => const RegistroScreen()),
    GoRoute(path: '/completar-perfil',   builder: (_, _) => const CompletarPerfilScreen()),
    GoRoute(path: '/onboarding',         builder: (_, _) => const OnboardingScreen()),
    GoRoute(path: '/home',               builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/editar-perfil',      builder: (_, _) => const EditarPerfilScreen()),
    GoRoute(path: '/politica-privacidad',builder: (_, _) => const PoliticaPrivacidadScreen()),

    // ── Módulo empresa ─────────────────────────────────────────
    GoRoute(path: '/empresa/registro',   builder: (_, _) => const EmpresaRegistroScreen()),
    GoRoute(path: '/empresa/dashboard',  builder: (_, _) => const EmpresaDashboardScreen()),
    GoRoute(path: '/empresa/publicar',   builder: (_, _) => const PublicarVacanteScreen()),
    GoRoute(
      path: '/empresa/publicar-confirmacion',
      builder: (_, state) => VacantePublicadaScreen(
        titulo: state.extra as String,
      ),
    ),
    GoRoute(
      path: '/empresa/postulantes',
      builder: (_, state) {
        final vacante = state.extra as VacanteEmpresaModel;
        return PostulantesScreen(vacante: vacante);
      },
    ),
  ],
);
