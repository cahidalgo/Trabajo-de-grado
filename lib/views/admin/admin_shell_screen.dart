import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/admin_viewmodel.dart';
import 'admin_dashboard_screen.dart';
import 'admin_empresas_screen.dart';
import 'admin_usuarios_screen.dart';
import 'admin_vacantes_screen.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _currentIndex = 0;

  static const _tabs = <Widget>[
    AdminDashboardScreen(),
    AdminEmpresasScreen(),
    AdminUsuariosScreen(),
    AdminVacantesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminViewModel()..cargarTodo(),
      child: Consumer<AdminViewModel>(
        builder: (context, vm, _) => Scaffold(
          body: IndexedStack(index: _currentIndex, children: _tabs),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) =>
                  setState(() => _currentIndex = i),
              backgroundColor: Colors.white,
              elevation: 0,
              indicatorColor: AppColors.primaryLight,
              labelBehavior:
                  NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon:
                      Icon(Icons.dashboard, color: AppColors.primary),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: vm.empresasPendientes > 0,
                    label: Text('${vm.empresasPendientes}'),
                    child: const Icon(Icons.business_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: vm.empresasPendientes > 0,
                    label: Text('${vm.empresasPendientes}'),
                    child: const Icon(Icons.business,
                        color: AppColors.primary),
                  ),
                  label: 'Empresas',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon:
                      Icon(Icons.people, color: AppColors.primary),
                  label: 'Usuarios',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.work_outline),
                  selectedIcon:
                      Icon(Icons.work, color: AppColors.primary),
                  label: 'Vacantes',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
