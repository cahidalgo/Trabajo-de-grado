import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_ui.dart';
import '../../data/models/empresa_model.dart';
import '../../viewmodels/empresa_viewmodel.dart';
import '../../viewmodels/vacante_empresa_viewmodel.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    final empresaVm = context.read<EmpresaViewModel>();
    await empresaVm.restaurarSesion();

    final empresaId = empresaVm.empresaActual?.id;
    if (!mounted || empresaId == null) return;

    await context.read<VacanteEmpresaViewModel>().cargarVacantes(empresaId);
  }

  @override
  Widget build(BuildContext context) {
    final empresaVm = context.watch<EmpresaViewModel>();
    final empresa = empresaVm.empresaActual;

    if (empresaVm.cargando && empresa == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (empresa == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Panel de empresa')),
        body: AppEmptyState(
          icon: Icons.business_center_outlined,
          title: 'No encontramos tu sesión',
          description:
              'Inicia sesión nuevamente para administrar vacantes y revisar postulantes.',
          action: ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Ir a iniciar sesión'),
          ),
        ),
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
            onPressed: () async {
              await context.read<EmpresaViewModel>().cerrarSesion();
              if (!mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
      body:
          _tab == 0 ? const MisVacantesScreen() : _PerfilEmpresaResumen(empresa: empresa),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/empresa/publicar'),
              icon: const Icon(Icons.add),
              label: const Text('Publicar vacante'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            label: 'Mis vacantes',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            label: 'Mi empresa',
          ),
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppPageIntro(
          title: empresa.razonSocial,
          subtitle:
              'Administra la información principal de tu empresa y el estado de publicación de tus vacantes.',
          icon: Icons.business_outlined,
          trailing: AppTag(
            label: empresa.validado ? 'Validada' : 'En validación',
            color: empresa.validado ? AppColors.success : AppColors.warning,
          ),
        ),
        const SizedBox(height: 16),
        const AppSectionTitle(
          title: 'Información registrada',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 10),
        AppSurfaceCard(
          child: Column(
            children: [
              _DatoEmpresa(label: 'NIT', value: empresa.nit),
              const Divider(height: 24),
              _DatoEmpresa(label: 'Sector', value: empresa.sector),
              const Divider(height: 24),
              _DatoEmpresa(label: 'Correo', value: empresa.correo),
              if ((empresa.telefono ?? '').trim().isNotEmpty) ...[
                const Divider(height: 24),
                _DatoEmpresa(label: 'Teléfono', value: empresa.telefono!),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppInfoBanner(
          title: empresa.validado ? 'Cuenta validada' : 'Validación pendiente',
          description: empresa.validado
              ? 'Tus vacantes pueden publicarse normalmente dentro de la plataforma.'
              : 'Las vacantes registradas quedarán visibles para candidatos cuando el equipo confirme la empresa.',
          icon: empresa.validado ? Icons.verified_outlined : Icons.info_outline,
          color: empresa.validado ? AppColors.success : AppColors.warning,
        ),
      ],
    );
  }
}

class _DatoEmpresa extends StatelessWidget {
  final String label;
  final String value;

  const _DatoEmpresa({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
