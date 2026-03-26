import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_ui.dart';
import '../../viewmodels/postulacion_viewmodel.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostulacionViewModel>().cargarHistorial();
    });
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'enviada':
        return AppColors.primary;
      case 'vista':
        return AppColors.warning;
      case 'aceptada':
        return AppColors.success;
      case 'rechazada':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'enviada':
        return Icons.send_outlined;
      case 'vista':
        return Icons.visibility_outlined;
      case 'aceptada':
        return Icons.check_circle_outline;
      case 'rechazada':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _formatFecha(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PostulacionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis postulaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<PostulacionViewModel>().cargarHistorial(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: vm.state == PostulacionState.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.historial.isEmpty
              ? const AppEmptyState(
                  icon: Icons.list_alt_outlined,
                  title: 'Aún no te has postulado',
                  description:
                      'Explora vacantes disponibles y revisa aquí el seguimiento de cada proceso.',
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<PostulacionViewModel>().cargarHistorial(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: vm.historial.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      if (index == 0) {
                        return AppInfoBanner(
                          title: 'Seguimiento de procesos',
                          description:
                              'Consulta el estado de cada postulación y mantén contexto de fechas y empresas.',
                          icon: Icons.track_changes_outlined,
                          color: AppColors.primary,
                        );
                      }

                      final postulacion = vm.historial[index - 1];
                      final estado =
                          postulacion['estado'] as String? ?? 'Enviada';
                      final color = _colorEstado(estado);
                      final icono = _iconoEstado(estado);

                      return AppSurfaceCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: color.withOpacity(0.1),
                              child: Icon(icono, color: color, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    postulacion['titulo'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    postulacion['empresa'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      AppTag(label: estado, color: color),
                                      const Spacer(),
                                      Text(
                                        _formatFecha(
                                          postulacion['fechaPostulacion']
                                                  as String? ??
                                              '',
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
