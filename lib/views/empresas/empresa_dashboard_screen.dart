import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/empresa_viewmodel.dart';
import '../../viewmodels/vacante_empresa_viewmodel.dart';
import '../../data/models/empresa_model.dart';
import 'mis_vacantes_screen.dart';

class EmpresaDashboardScreen extends StatefulWidget {
  const EmpresaDashboardScreen({super.key});
  @override
  State<EmpresaDashboardScreen> createState() => _EmpresaDashboardScreenState();
}

class _EmpresaDashboardScreenState extends State<EmpresaDashboardScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    final empresaId = context.read<EmpresaViewModel>().empresaActual?.id;
    if (empresaId != null) {
      context.read<VacanteEmpresaViewModel>().cargarVacantes(empresaId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final empresa = context.watch<EmpresaViewModel>().empresaActual;

    if (empresa == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(empresa.razonSocial),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              context.read<EmpresaViewModel>().cerrarSesion();
              context.go('/login');
            },
          ),
        ],
      ),
      body: _tab == 0
          ? const MisVacantesScreen()
          : _PerfilEmpresaResumen(empresa: empresa),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/empresa/publicar'),
              icon: const Icon(Icons.add),
              label: const Text('Publicar vacante'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.work_outline), label: 'Mis vacantes'),
          NavigationDestination(
              icon: Icon(Icons.business), label: 'Mi empresa'),
        ],
      ),
    );
  }
}

class _PerfilEmpresaResumen extends StatelessWidget {
  final EmpresaModel empresa;
  const _PerfilEmpresaResumen({required this.empresa});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            empresa.razonSocial,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('NIT: ${empresa.nit}'),
          Text('Sector: ${empresa.sector}'),
          Text('Correo: ${empresa.correo}'),
          if (empresa.telefono != null) Text('Teléfono: ${empresa.telefono}'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tu cuenta está en proceso de validación. '
                    'Las vacantes publicadas serán visibles una vez confirmadas.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
