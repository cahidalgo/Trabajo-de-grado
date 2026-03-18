import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../vacantes/vacantes_list_screen.dart';
import '../guardadas/guardadas_screen.dart';
import '../postulaciones/historial_screen.dart';
import '../formacion/formacion_screen.dart';
import '../perfil/perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabActual = 0;

  void _irATab(int index) => setState(() => _tabActual = index);

  @override
  Widget build(BuildContext context) {
    // Los tabs que necesitan callbacks los construimos aquí
    final tabs = [
      const VacantesListScreen(),
      GuardadasScreen(onIrAVacantes: () => _irATab(0)),  // ← callback real
      const HistorialScreen(),
      const FormacionScreen(),
      const PerfilScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabActual, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabActual,
        onTap: _irATab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work_outline),      label: AppStrings.vacantes),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline),  label: AppStrings.guardadas),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Postulaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined),   label: AppStrings.formacion),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),    label: AppStrings.perfil),
        ],
      ),
    );
  }
}