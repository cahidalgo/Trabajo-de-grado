import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../data/models/empresa_model.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await context.read<AuthViewModel>().cerrarSesion();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: vm.cargarTodo,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Resumen general',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Desliza hacia abajo para actualizar',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // ── KPI Grid ─────────────────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _KpiCard(
                  label: 'Usuarios',
                  valor: vm.totalUsuarios,
                  icono: Icons.people_outline,
                  color: AppColors.primary,
                ),
                _KpiCard(
                  label: 'Empresas',
                  valor: vm.totalEmpresas,
                  icono: Icons.business_outlined,
                  color: const Color(0xFFE65100),
                  subtitulo: vm.empresasPendientes > 0
                      ? '${vm.empresasPendientes} pendiente(s)'
                      : 'Todas validadas',
                  subtituloColor: vm.empresasPendientes > 0
                      ? const Color(0xFFE65100)
                      : const Color(0xFF2E7D32),
                ),
                _KpiCard(
                  label: 'Vacantes activas',
                  valor: vm.vacantesActivas,
                  icono: Icons.work_outline,
                  color: const Color(0xFF2E7D32),
                  subtitulo: 'de ${vm.totalVacantes} publicadas',
                ),
                _KpiCard(
                  label: 'Postulaciones',
                  valor: vm.totalPostulaciones,
                  icono: Icons.assignment_outlined,
                  color: const Color(0xFF1565C0),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Empresas pendientes ──────────────────────────────
            if (vm.empresasPendientes > 0) ...[
              Row(
                children: const [
                  Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFE65100), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Pendientes de validación',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...vm.empresas
                  .where((e) => !e.validado)
                  .take(3)
                  .map((e) => _EmpresaPendienteTile(empresa: e)),
              if (vm.empresas.where((e) => !e.validado).length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Ir a Empresas para ver todas →',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── KPI Card ──────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String label;
  final int valor;
  final IconData icono;
  final Color color;
  final String? subtitulo;
  final Color? subtituloColor;

  const _KpiCard({
    required this.label,
    required this.valor,
    required this.icono,
    required this.color,
    this.subtitulo,
    this.subtituloColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icono, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$valor',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              if (subtitulo != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitulo!,
                  style: TextStyle(
                      fontSize: 11,
                      color: subtituloColor ?? AppColors.textSecondary,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empresa pendiente (tile compacto) ─────────────────────────
class _EmpresaPendienteTile extends StatelessWidget {
  final EmpresaModel empresa;
  const _EmpresaPendienteTile({required this.empresa});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(empresa.razonSocial,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(empresa.sector,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                context.read<AdminViewModel>().validarEmpresa(empresa.id!),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(horizontal: 10)),
            child: const Text('Validar',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}