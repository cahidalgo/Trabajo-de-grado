import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_ui.dart';
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
      separatorBuilder: (_, __) => const SizedBox(height: 14),
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
        return _TarjetaVacanteEmpresa(
          vacante: vacante,
          onToggle: () => vm.toggleActiva(vacante),
          onEliminar: () => _confirmarEliminar(ctx, vacante, vm),
          onVerPostulantes: () =>
              context.push('/empresa/postulantes', extra: vacante),
          onEditar: () async {
            await context.push('/empresa/editar-vacante',
                extra: vacante);
            // Recargar tras editar
            final empresaId = vacante.empresaId;
            await ctx
                .read<VacanteEmpresaViewModel>()
                .cargarVacantes(empresaId);
          },
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
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta ───────────────────────────────────────────────────────────────────
class _TarjetaVacanteEmpresa extends StatelessWidget {
  final VacanteEmpresaModel vacante;
  final VoidCallback onToggle;
  final VoidCallback onEliminar;
  final VoidCallback onVerPostulantes;
  final VoidCallback onEditar;

  const _TarjetaVacanteEmpresa({
    required this.vacante,
    required this.onToggle,
    required this.onEliminar,
    required this.onVerPostulantes,
    required this.onEditar,
  });

  static const _coloresSector = <String, List<Color>>{
    'Ventas y comercio': [Color(0xFFE3F2FD), Color(0xFF1565C0)],
    'Gastronomía': [Color(0xFFFFF3E0), Color(0xFFE65100)],
    'Logística': [Color(0xFFE8F5E9), Color(0xFF2E7D32)],
    'Servicios': [Color(0xFFF3E5F5), Color(0xFF6A1B9A)],
    'Construcción': [Color(0xFFFBE9E7), Color(0xFFBF360C)],
    'Administrativo': [Color(0xFFE8EAF6), Color(0xFF283593)],
    'Tecnología': [Color(0xFFE0F7FA), Color(0xFF00695C)],
  };

  static const _iconosSector = <String, IconData>{
    'Ventas y comercio': Icons.storefront_outlined,
    'Gastronomía': Icons.restaurant_outlined,
    'Logística': Icons.local_shipping_outlined,
    'Servicios': Icons.support_agent_outlined,
    'Construcción': Icons.construction_outlined,
    'Administrativo': Icons.admin_panel_settings_outlined,
    'Tecnología': Icons.computer_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final sector = vacante.sector;
    final colores = _coloresSector[sector] ??
        [const Color(0xFFF5F5F5), AppColors.primary];
    final icono = _iconosSector[sector] ?? Icons.work_outline;
    final bgColor = colores[0];
    final acColor = colores[1];
    final activa = vacante.activa;

    return Opacity(
      opacity: activa ? 1.0 : 0.65,
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: activa ? 3 : 1,
        shadowColor: acColor.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: acColor.withOpacity(0.15),
                      child:
                          Icon(icono, color: acColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            vacante.titulo,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: acColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sector,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Chips de info ──────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(14, 12, 14, 4),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _PillChip(vacante.modalidad, acColor,
                        Icons.laptop_outlined),
                    _PillChip(vacante.jornada, acColor,
                        Icons.schedule_outlined),
                    if (vacante.zonaPortal != null)
                      _PillChip(vacante.zonaPortal!, acColor,
                          Icons.location_on_outlined),
                  ],
                ),
              ),

              // ── Salario y fecha ────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(14, 6, 14, 12),
                child: Row(
                  children: [
                    if (vacante.salarioReferencial != null) ...[
                      Icon(Icons.attach_money,
                          size: 15, color: acColor),
                      const SizedBox(width: 4),
                      Text(
                        vacante.salarioReferencial!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: acColor,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (vacante.fechaCierre.isNotEmpty)
                      Text(
                        'Cierre: ${_formatFecha(vacante.fechaCierre)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),

              // ── Etiquetas de inclusión ─────────────────────────
              if (_tieneEtiquetas)
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (vacante.aceptaExperienciaInformal)
                        _EtiquetaChip('Experiencia informal',
                            Icons.handshake_outlined),
                      if (vacante.aceptaPepPpt)
                        _EtiquetaChip(
                            'PEP / PPT',
                            Icons.assignment_ind_outlined),
                      if (vacante.horarioFlexible)
                        _EtiquetaChip('Horario flexible',
                            Icons.access_time_outlined),
                      if (vacante.incluyeFormacion)
                        _EtiquetaChip('Incluye formación',
                            Icons.school_outlined),
                    ],
                  ),
                ),

              const Divider(height: 1),

              // ── Acciones — badge integrado aquí para evitar solapamiento ──
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    // Badge estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: activa
                            ? const Color(0xFF43A047)
                            : const Color(0xFFBDBDBD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        activa ? 'Activa' : 'Inactiva',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Postulantes
                    TextButton.icon(
                      onPressed: onVerPostulantes,
                      icon: Icon(Icons.people_outline,
                          size: 16, color: acColor),
                      label: Text('Postulantes',
                          style: TextStyle(
                              fontSize: 12, color: acColor)),
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6)),
                    ),
                    const Spacer(),
                    // Editar
                    IconButton(
                      icon: Icon(Icons.edit_outlined,
                          color: acColor, size: 22),
                      tooltip: 'Editar vacante',
                      onPressed: onEditar,
                    ),
                    // Activar/desactivar
                    IconButton(
                      icon: Icon(
                        activa
                            ? Icons.toggle_on_outlined
                            : Icons.toggle_off_outlined,
                        color: activa
                            ? const Color(0xFF43A047)
                            : const Color(0xFFBDBDBD),
                        size: 28,
                      ),
                      tooltip: activa ? 'Desactivar' : 'Activar',
                      onPressed: onToggle,
                    ),
                    // Eliminar
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error, size: 22),
                      tooltip: 'Eliminar vacante',
                      onPressed: onEliminar,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _tieneEtiquetas =>
      vacante.aceptaExperienciaInformal ||
      vacante.aceptaPepPpt ||
      vacante.horarioFlexible ||
      vacante.incluyeFormacion;

  String _formatFecha(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icono;
  const _PillChip(this.label, this.color, this.icono);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 11, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
}

class _EtiquetaChip extends StatelessWidget {
  final String label;
  final IconData icono;
  const _EtiquetaChip(this.label, this.icono);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF6A1B9A).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono,
                size: 11, color: const Color(0xFF6A1B9A)),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6A1B9A),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
}
