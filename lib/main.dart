import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/perfil_viewmodel.dart';
import 'viewmodels/postulacion_viewmodel.dart';
import 'viewmodels/empresa_viewmodel.dart';
import 'viewmodels/vacante_empresa_viewmodel.dart';


void main() {
  runApp(const VendedoresTMApp());
}

class VendedoresTMApp extends StatelessWidget {
  const VendedoresTMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PerfilViewModel()),
        ChangeNotifierProvider(create: (_) => PostulacionViewModel()),
        ChangeNotifierProvider(create: (_) => EmpresaViewModel()),
        ChangeNotifierProvider(create: (_) => VacanteEmpresaViewModel()),
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
