import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_ui.dart';
import '../../core/widgets/vacante_empresa_card.dart';
import '../../data/models/vacante_empresa_model.dart';
import '../../viewmodels/vacante_empresa_viewmodel.dart';

class MisVacantesScreen extends StatelessWidget {
  const MisVacantesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VacanteEmpresaViewModel>();

    if (vm.cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.vacantes.isEmpty) {
      return const AppEmptyState(
        icon: Icons.work_off_outlined,
        title: 'Aún no has publicado vacantes',
        description:
            'Usa el botón de publicar para crear tu primera oferta y empezar a recibir postulaciones.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: vm.vacantes.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        if (index == 0) {
          return AppInfoBanner(
            title: 'Panel de vacantes',
            description:
                'Controla el estado de cada publicación, consulta postulantes y mantén visible solo lo que siga vigente.',
            icon: Icons.dashboard_customize_outlined,
            color: AppColors.primary,
          );
        }

        final vacante = vm.vacantes[index - 1];
        return VacanteEmpresaCard(
          vacante: vacante,
          onToggle: () => vm.toggleActiva(vacante),
          onEliminar: () => _confirmarEliminar(ctx, vacante, vm),
          onVerPostulantes: () =>
              context.push('/empresa/postulantes', extra: vacante),
        );
      },
    );
  }

  void _confirmarEliminar(
    BuildContext context,
    VacanteEmpresaModel vacante,
    VacanteEmpresaViewModel vm,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar vacante'),
        content: Text(
          '¿Deseas eliminar "${vacante.titulo}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              vm.eliminar(vacante);
              Navigator.pop(context);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
