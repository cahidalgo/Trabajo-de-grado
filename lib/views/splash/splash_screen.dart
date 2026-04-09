import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/supabase_service.dart';

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
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final user = SupabaseService.currentUser;

    if (user == null) {
      context.go('/login');
      return;
    }

    final db = SupabaseService.client;

    // ¿Es admin? (consulta tabla admins)
    final adminData = await db
        .from('admins')
        .select('id')
        .eq('auth_id', user.id)
        .maybeSingle();

    if (adminData != null) {
      if (!mounted) return;
      context.go('/admin');
      return;
    }

    // ¿Es vendedor?
    final usuarioData = await db
        .from('usuarios')
        .select('id')
        .eq('auth_id', user.id)
        .maybeSingle();

    if (usuarioData != null) {
      if (!mounted) return;
      context.go('/home');
      return;
    }

    // ¿Es empresa?
    final empresaData = await db
        .from('empresas')
        .select('id')
        .eq('auth_id', user.id)
        .maybeSingle();

    if (!mounted) return;
    if (empresaData != null) {
      context.go('/empresa/dashboard');
    } else {
      await SupabaseService.client.auth.signOut();
      if (mounted) context.go('/login');
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
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Image.asset('assets/icon/icon.png',
                  fit: BoxFit.contain),
            ),
            const SizedBox(height: 24),
            const Text(
              AppStrings.appName,
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
                color: Colors.white, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
