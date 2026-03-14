import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../vacantes/vacantes_list_screen.dart';
import '../postulaciones/historial_screen.dart';
import '../perfil/perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabActual = 0;

  final _tabs = const [
    VacantesListScreen(),
    // GuardadasScreen() — próximo sprint
    Center(child: Text('Guardadas\n(próximamente)', textAlign: TextAlign.center)),
    HistorialScreen(),
    // FormacionScreen() — próximo sprint
    Center(child: Text('Formación\n(próximamente)', textAlign: TextAlign.center)),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tabActual, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabActual,
        onTap: (i) => setState(() => _tabActual = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work_outline),       label: AppStrings.vacantes),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline),   label: AppStrings.guardadas),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined),  label: 'Postulaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined),    label: AppStrings.formacion),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),     label: AppStrings.perfil),
        ],
      ),
    );
  }
}
