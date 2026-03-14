import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

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
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 80, color: AppColors.onPrimary),
            SizedBox(height: 16),
            Text(
              AppStrings.appName,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.onPrimary),
            ),
            SizedBox(height: 8),
            Text('Tu puerta al trabajo formal', style: TextStyle(color: AppColors.onPrimary, fontSize: 14)),
            SizedBox(height: 40),
            CircularProgressIndicator(color: AppColors.onPrimary),
          ],
        ),
      ),
    );
  }
}
