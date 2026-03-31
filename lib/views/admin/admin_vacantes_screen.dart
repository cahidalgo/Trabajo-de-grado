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
      appBar: AppBar(
        title: Text('Vacantes (${todas.length})'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: 'Activas (${activas.length})'),
            Tab(text: 'Inactivas (${inactivas.length})'),
          ],
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
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.work_outline, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('No hay vacantes en esta categoría',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vacantes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
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
    final fechaPub =
        (vacante['fecha_publicacion'] as String? ?? '').length >= 10
            ? (vacante['fecha_publicacion'] as String).substring(0, 10)
            : '';
    final fechaCierre =
        (vacante['fecha_cierre'] as String? ?? '').length >= 10
            ? (vacante['fecha_cierre'] as String).substring(0, 10)
            : '';
    final id = vacante['id'] as int;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activa
              ? const Color(0xFFA5D6A7)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(empresa,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ChipEstado(activa: activa),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // ── Info ────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _Chip(Icons.category_outlined, sector),
              _Chip(Icons.laptop_outlined, modalidad),
              _Chip(Icons.schedule_outlined, jornada),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoText('Publicada: $fechaPub'),
              const SizedBox(width: 16),
              _InfoText('Cierre: $fechaCierre'),
            ],
          ),
          const SizedBox(height: 12),

          // ── Acción ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmar = await _confirmar(context, activa, titulo);
                if (confirmar == true) {
                  await vm.toggleVacante(id, activa);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(activa
                            ? '⏸ Vacante desactivada'
                            : '▶ Vacante activada'),
                        backgroundColor: activa
                            ? AppColors.error
                            : const Color(0xFF2E7D32),
                      ),
                    );
                  }
                }
              },
              icon: Icon(
                activa ? Icons.pause_circle_outline : Icons.play_circle_outline,
                size: 16,
              ),
              label: Text(activa ? 'Desactivar vacante' : 'Activar vacante'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    activa ? AppColors.error : const Color(0xFF2E7D32),
                side: BorderSide(
                  color: activa
                      ? AppColors.error.withOpacity(0.4)
                      : const Color(0xFF2E7D32).withOpacity(0.4),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
              ),
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
        title: Text(activa ? 'Desactivar vacante' : 'Activar vacante'),
        content: Text(activa
            ? '¿Desactivar "$titulo"? Dejará de ser visible para los vendedores.'
            : '¿Activar "$titulo"? Será visible nuevamente para los vendedores.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor:
                    activa ? AppColors.error : const Color(0xFF2E7D32)),
            child: Text(activa ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }
}

class _ChipEstado extends StatelessWidget {
  final bool activa;
  const _ChipEstado({required this.activa});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: activa
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        activa ? '● Activa' : '○ Inactiva',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: activa
              ? const Color(0xFF2E7D32)
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _Chip(this.icono, this.texto);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(texto,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _InfoText extends StatelessWidget {
  final String texto;
  const _InfoText(this.texto);

  @override
  Widget build(BuildContext context) => Text(
        texto,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      );
}