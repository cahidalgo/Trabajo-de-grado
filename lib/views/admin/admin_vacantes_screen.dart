import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/admin_viewmodel.dart';

class AdminVacantesScreen extends StatefulWidget {
  const AdminVacantesScreen({super.key});

  @override
  State<AdminVacantesScreen> createState() => _AdminVacantesScreenState();
}

class _AdminVacantesScreenState extends State<AdminVacantesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final todas = vm.vacantes;
    final activas = todas.where((v) => v['activa'] == 1).toList();
    final inactivas = todas.where((v) => v['activa'] == 0).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Vacantes (${todas.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 15),
                      const SizedBox(width: 5),
                      Text('Activas (${activas.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pause_circle_outline, size: 15),
                      const SizedBox(width: 5),
                      Text('Inactivas (${inactivas.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: vm.cargando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _ListaVacantes(vacantes: activas),
                _ListaVacantes(vacantes: inactivas),
              ],
            ),
    );
  }
}

// ── Lista ─────────────────────────────────────────────────────
class _ListaVacantes extends StatelessWidget {
  final List<Map<String, dynamic>> vacantes;
  const _ListaVacantes({required this.vacantes});

  @override
  Widget build(BuildContext context) {
    if (vacantes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.border.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.work_outline,
                  size: 40, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay vacantes en esta categoría',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vacantes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _VacanteCard(vacante: vacantes[i]),
    );
  }
}

// ── Card vacante ──────────────────────────────────────────────
class _VacanteCard extends StatelessWidget {
  final Map<String, dynamic> vacante;
  const _VacanteCard({required this.vacante});

  @override
  Widget build(BuildContext context) {
    final activa = vacante['activa'] == 1;
    final vm = context.read<AdminViewModel>();

    final titulo = vacante['titulo'] as String? ?? '';
    final empresa = vacante['empresa_nombre'] as String? ?? '';
    final sector = vacante['sector'] as String? ?? '';
    final modalidad = vacante['modalidad'] as String? ?? '';
    final jornada = vacante['jornada'] as String? ?? '';
    final raw1 = vacante['fecha_publicacion'] as String? ?? '';
    final fechaPub = raw1.length >= 10 ? raw1.substring(0, 10) : raw1;
    final raw2 = vacante['fecha_cierre'] as String? ?? '';
    final fechaCierre = raw2.length >= 10 ? raw2.substring(0, 10) : raw2;
    final id = vacante['id'] as int;

    final activeGreen = const Color(0xFF2E7D32);
    final inactiveGray = AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activa
              ? activeGreen.withOpacity(0.3)
              : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: activa
                  ? activeGreen.withOpacity(0.05)
                  : AppColors.background,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: activa
                        ? activeGreen.withOpacity(0.12)
                        : inactiveGray.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    Icons.work_outline,
                    size: 20,
                    color: activa ? activeGreen : inactiveGray,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.business_outlined,
                              size: 13, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              empresa,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ChipEstado(activa: activa),
              ],
            ),
          ),

          // ── Detalles ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chips de info
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(Icons.category_outlined, sector),
                    _InfoChip(Icons.laptop_outlined, modalidad),
                    _InfoChip(Icons.schedule_outlined, jornada),
                  ],
                ),
                const SizedBox(height: 12),

                // Fechas
                Row(
                  children: [
                    Expanded(
                      child: _FechaItem(
                        icono: Icons.calendar_today_outlined,
                        label: 'Publicada',
                        fecha: fechaPub,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FechaItem(
                        icono: Icons.event_outlined,
                        label: 'Cierre',
                        fecha: fechaCierre,
                        isAlert: !activa,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Botón de acción
                SizedBox(
                  width: double.infinity,
                  child: activa
                      ? OutlinedButton.icon(
                          onPressed: () async {
                            final confirmar =
                                await _confirmar(context, activa, titulo);
                            if (confirmar == true) {
                              await vm.toggleVacante(id, activa);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('⏸ Vacante desactivada'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.pause_circle_outline,
                              size: 18),
                          label: const Text('Desactivar vacante',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(
                                color: AppColors.error.withOpacity(0.4)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () async {
                            final confirmar =
                                await _confirmar(context, activa, titulo);
                            if (confirmar == true) {
                              await vm.toggleVacante(id, activa);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('▶ Vacante activada'),
                                    backgroundColor: Color(0xFF2E7D32),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.play_circle_outline,
                              size: 18),
                          label: const Text('Activar vacante',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeGreen,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmar(
      BuildContext context, bool activa, String titulo) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(activa ? 'Desactivar vacante' : 'Activar vacante',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(activa
            ? '¿Desactivar "$titulo"? Dejará de ser visible para los vendedores.'
            : '¿Activar "$titulo"? Será visible nuevamente para los vendedores.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  activa ? AppColors.error : const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(activa ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────
class _ChipEstado extends StatelessWidget {
  final bool activa;
  const _ChipEstado({required this.activa});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: activa
            ? const Color(0xFF2E7D32).withOpacity(0.1)
            : AppColors.border,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: activa
                  ? const Color(0xFF2E7D32)
                  : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            activa ? 'Activa' : 'Inactiva',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: activa
                  ? const Color(0xFF2E7D32)
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _InfoChip(this.icono, this.texto);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 13, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FechaItem extends StatelessWidget {
  final IconData icono;
  final String label;
  final String fecha;
  final bool isAlert;
  const _FechaItem({
    required this.icono,
    required this.label,
    required this.fecha,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icono,
              size: 14,
              color:
                  isAlert ? AppColors.error : AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500)),
                Text(
                  fecha.isEmpty ? '—' : fecha,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isAlert
                        ? AppColors.error
                        : AppColors.textPrimary,
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
