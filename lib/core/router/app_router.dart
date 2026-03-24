import 'package:go_router/go_router.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/registro_screen.dart';
import '../../views/onboarding/onboarding_screen.dart';
import '../../views/home/home_screen.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/perfil/completar_perfil_screen.dart';
import '../../views/perfil/editar_perfil_screen.dart';
import '../../views/legal/politica_privacidad_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',                      builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/login',                 builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/registro',              builder: (_, _) => const RegistroScreen()),
    GoRoute(path: '/completar-perfil',      builder: (_, _) => const CompletarPerfilScreen()),
    GoRoute(path: '/onboarding',            builder: (_, _) => const OnboardingScreen()),
    GoRoute(path: '/home',                  builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/editar-perfil',         builder: (_, _) => const EditarPerfilScreen()),
    GoRoute(path: '/politica-privacidad',   builder: (_, _) => const PoliticaPrivacidadScreen()),
  ],
);
