import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/empresa_viewmodel.dart';
import '../../viewmodels/vacante_empresa_viewmodel.dart';
import '../../data/models/vacante_empresa_model.dart';
import '../../core/widgets/vacante_empresa_card.dart';

class MisVacantesScreen extends StatelessWidget {
  const MisVacantesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VacanteEmpresaViewModel>();

    if (vm.cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.vacantes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.work_off_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Aún no has publicado vacantes.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Toca el botón "Publicar vacante" para comenzar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
          ]),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vm.vacantes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final v = vm.vacantes[i];
        return VacanteEmpresaCard(
          vacante: v,
          onToggle: () => vm.toggleActiva(v),
          onEliminar: () => _confirmarEliminar(ctx, v, vm),
          onVerPostulantes: () => Navigator.pushNamed(
            ctx, '/empresa/postulantes',
            arguments: v,
          ),
        );
      },
    );
  }

  void _confirmarEliminar(
      BuildContext context, VacanteEmpresaModel v, VacanteEmpresaViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar vacante'),
        content: Text('¿Deseas eliminar "${v.titulo}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              vm.eliminar(v);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
