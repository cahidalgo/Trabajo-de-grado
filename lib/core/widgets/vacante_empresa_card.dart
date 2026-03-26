import 'package:flutter/material.dart';

import '../../data/models/vacante_empresa_model.dart';
import '../constants/app_colors.dart';
import 'app_ui.dart';

class VacanteEmpresaCard extends StatelessWidget {
  final VacanteEmpresaModel vacante;
  final VoidCallback onToggle;
  final VoidCallback onEliminar;
  final VoidCallback onVerPostulantes;

  const VacanteEmpresaCard({
    super.key,
    required this.vacante,
    required this.onToggle,
    required this.onEliminar,
    required this.onVerPostulantes,
  });

  @override
  Widget build(BuildContext context) {
    final estadoColor =
        vacante.activa ? AppColors.success : AppColors.textSecondary;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vacante.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      vacante.sector,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppTag(
                label: vacante.activa ? 'Activa' : 'Pausada',
                color: estadoColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppTag(label: vacante.modalidad, color: AppColors.primary),
              AppTag(label: vacante.jornada, color: AppColors.primary),
              if ((vacante.salarioReferencial ?? '').trim().isNotEmpty)
                AppTag(
                  label: vacante.salarioReferencial!,
                  color: AppColors.success,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              TextButton.icon(
                onPressed: onVerPostulantes,
                icon: const Icon(Icons.people_outline, size: 18),
                label: const Text('Postulantes'),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  vacante.activa
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  color: AppColors.warning,
                ),
                tooltip: vacante.activa ? 'Pausar' : 'Activar',
                onPressed: onToggle,
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                tooltip: 'Eliminar',
                onPressed: onEliminar,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
