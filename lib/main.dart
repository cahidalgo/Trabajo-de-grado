import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/perfil_viewmodel.dart';
import 'viewmodels/postulacion_viewmodel.dart';
import 'viewmodels/empresa_viewmodel.dart';
import 'viewmodels/vacante_empresa_viewmodel.dart';
import 'viewmodels/admin_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Inicializar Supabase ──────────────────────────────────────
  // Reemplaza estos valores con los de tu proyecto en:
  // https://app.supabase.com → Settings → API
  await Supabase.initialize(
    url:     'https://uanaoidkagzvxijiznhg.supabase.co',
    anonKey: 'sb_publishable_Vea3wBv7264hgzDuQqjWrw_72JoDvR3',
  );

  runApp(const FormaliaApp());
}

class FormaliaApp extends StatelessWidget {
  const FormaliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PerfilViewModel()),
        ChangeNotifierProvider(create: (_) => PostulacionViewModel()),
        ChangeNotifierProvider(create: (_) => EmpresaViewModel()),
        ChangeNotifierProvider(create: (_) => VacanteEmpresaViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
      ],
      child: MaterialApp.router(
        title: 'Formalia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
