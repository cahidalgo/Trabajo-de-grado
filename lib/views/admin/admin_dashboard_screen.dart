import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/empresa_model.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: vm.cargarTodo,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Panel de Administración',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    Text(
                                      'Vendedores TM',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.logout_outlined,
                                  color: Colors.white70,
                                ),
                                tooltip: 'Cerrar sesión',
                                onPressed: () async {
                                  await context
                                      .read<AuthViewModel>()
                                      .cerrarSesion();
                                  if (context.mounted) {
                                    context.go('/login');
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Resumen general',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Desliza para actualizar',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 360;

                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: compact ? 1.02 : 1.16,
                          children: [
                            _KpiCard(
                              label: 'Usuarios',
                              valor: vm.totalUsuarios,
                              icono: Icons.people_rounded,
                              gradientColors: const [
                                Color(0xFF1565C0),
                                Color(0xFF1976D2),
                              ],
                            ),
                            _KpiCard(
                              label: 'Empresas',
                              valor: vm.totalEmpresas,
                              icono: Icons.business_rounded,
                              gradientColors: const [
                                Color(0xFFBF360C),
                                Color(0xFFE64A19),
                              ],
                              badge: vm.empresasPendientes > 0
                                  ? '${vm.empresasPendientes} pendiente(s)'
                                  : null,
                              badgeGreen: vm.empresasPendientes == 0,
                              badgeLabel: vm.empresasPendientes == 0
                                  ? 'Al día'
                                  : null,
                            ),
                            _KpiCard(
                              label: 'Vacantes activas',
                              valor: vm.vacantesActivas,
                              icono: Icons.work_rounded,
                              gradientColors: const [
                                Color(0xFF1B5E20),
                                Color(0xFF2E7D32),
                              ],
                              badge: 'de ${vm.totalVacantes} publicadas',
                              badgeGreen: true,
                            ),
                            _KpiCard(
                              label: 'Postulaciones',
                              valor: vm.totalPostulaciones,
                              icono: Icons.assignment_rounded,
                              gradientColors: const [
                                Color(0xFF4A148C),
                                Color(0xFF6A1B9A),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    if (vm.empresasPendientes > 0) ...[
                      _SectionHeader(
                        icono: Icons.warning_amber_rounded,
                        titulo: 'Pendientes de validación',
                        color: const Color(0xFFE65100),
                      ),
                      const SizedBox(height: 12),
                      ...vm.empresas
                          .where((e) => !e.validado)
                          .take(3)
                          .map((e) => _EmpresaPendienteTile(empresa: e)),
                      if (vm.empresas.where((e) => !e.validado).length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ver todas en la pestaña Empresas',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                    ],
                    const _SectionHeader(
                      icono: Icons.bar_chart_rounded,
                      titulo: 'Actividad global',
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    _StatRow(
                      label: 'Vacantes inactivas',
                      valor: '${vm.totalVacantes - vm.vacantesActivas}',
                      icono: Icons.pause_circle_outline,
                      color: AppColors.textSecondary,
                    ),
                    _StatRow(
                      label: 'Empresas validadas',
                      valor: '${vm.totalEmpresas - vm.empresasPendientes}',
                      icono: Icons.verified_outlined,
                      color: AppColors.success,
                    ),
                    _StatRow(
                      label: 'Postulaciones totales',
                      valor: '${vm.totalPostulaciones}',
                      icono: Icons.send_outlined,
                      color: const Color(0xFF6A1B9A),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final int valor;
  final IconData icono;
  final List<Color> gradientColors;
  final String? badge;
  final String? badgeLabel;
  final bool badgeGreen;

  const _KpiCard({
    required this.label,
    required this.valor,
    required this.icono,
    required this.gradientColors,
    this.badge,
    this.badgeLabel,
    this.badgeGreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 150;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: gradientColors.last.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(compact ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icono,
                color: Colors.white.withOpacity(0.9),
                size: compact ? 22 : 26,
              ),
              SizedBox(height: compact ? 10 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$valor',
                        style: TextStyle(
                          fontSize: compact ? 28 : 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 11 : 12,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 6),
                      _KpiBadge(
                        text: badge!,
                        compact: compact,
                        backgroundColor: badgeGreen
                            ? Colors.white.withOpacity(0.25)
                            : Colors.orange.withOpacity(0.85),
                      ),
                    ],
                    if (badgeLabel != null) ...[
                      const SizedBox(height: 6),
                      _KpiBadge(
                        text: badgeLabel!,
                        compact: compact,
                        backgroundColor: Colors.white.withOpacity(0.25),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KpiBadge extends StatelessWidget {
  final String text;
  final bool compact;
  final Color backgroundColor;

  const _KpiBadge({
    required this.text,
    required this.compact,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 7,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: compact ? 9 : 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Color color;

  const _SectionHeader({
    required this.icono,
    required this.titulo,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icono;
  final Color color;

  const _StatRow({
    required this.label,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, size: 16, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmpresaPendienteTile extends StatelessWidget {
  final EmpresaModel empresa;

  const _EmpresaPendienteTile({required this.empresa});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE65100).withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.business_outlined,
              color: Color(0xFFE65100),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  empresa.razonSocial,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${empresa.sector} · ${empresa.correo}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () =>
                context.read<AdminViewModel>().validarEmpresa(empresa.id!),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              elevation: 0,
            ),
            child: const Text('Validar'),
          ),
        ],
      ),
    );
  }
}
