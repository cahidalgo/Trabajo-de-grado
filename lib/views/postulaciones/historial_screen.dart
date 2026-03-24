import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
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
      case 'enviada':   return Colors.blue;
      case 'vista':     return Colors.orange;
      case 'aceptada':  return AppColors.success;
      case 'rechazada': return AppColors.error;
      default:          return AppColors.textSecondary;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'enviada':   return Icons.send_outlined;
      case 'vista':     return Icons.visibility_outlined;
      case 'aceptada':  return Icons.check_circle_outline;
      case 'rechazada': return Icons.cancel_outlined;
      default:          return Icons.help_outline;
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
            onPressed: () => context.read<PostulacionViewModel>().cargarHistorial(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: vm.state == PostulacionState.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.historial.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt_outlined, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'Aún no te has postulado a ninguna vacante',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Explora las vacantes disponibles y postúlate.',
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => context.read<PostulacionViewModel>().cargarHistorial(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.historial.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final p = vm.historial[i];
                      final estado = p['estado'] as String? ?? 'Enviada';
                      final color = _colorEstado(estado);
                      final icono = _iconoEstado(estado);

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
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
                                      p['titulo'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p['empresa'] ?? '',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: color.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Text(
                                            estado,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: color,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _formatFecha(p['fechaPostulacion'] as String? ?? ''),
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
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}