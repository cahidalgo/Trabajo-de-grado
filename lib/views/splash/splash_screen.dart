import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirigir();
  }

  Future<void> _redirigir() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final prefs           = await SharedPreferences.getInstance();
    final usuarioId       = prefs.getInt('usuarioId');
    final onboardingHecho = prefs.getBool('onboarding_completado') ?? false;
    if (!mounted) return;
    if (usuarioId != null) {
      context.go('/home');
    } else if (!onboardingHecho) {
      context.go('/registro');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Logo de la app ──────────────────────────────
            
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08), // era 0.2
                    blurRadius: 12,                         // era 20
                    offset: const Offset(0, 4),             // era (0,8)
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Image.asset('assets/icon/icon.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 24),
            const Text(
              'Vendedores TM',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu puerta al trabajo formal',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
