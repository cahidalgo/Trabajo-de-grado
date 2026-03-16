import 'package:go_router/go_router.dart';
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/registro_screen.dart';
import '../../views/onboarding/onboarding_screen.dart';
import '../../views/home/home_screen.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/perfil/completar_perfil_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',                 builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/login',            builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/registro',         builder: (_, _) => const RegistroScreen()),
    GoRoute(path: '/completar-perfil', builder: (_, _) => const CompletarPerfilScreen()),
    GoRoute(path: '/onboarding',       builder: (_, _) => const OnboardingScreen()),
    GoRoute(path: '/home',             builder: (_, _) => const HomeScreen()),
  ],
);
