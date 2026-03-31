import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../data/models/empresa_model.dart';

class AdminEmpresasScreen extends StatefulWidget {
  const AdminEmpresasScreen({super.key});

  @override
  State<AdminEmpresasScreen> createState() => _AdminEmpresasScreenState();
}

class _AdminEmpresasScreenState extends State<AdminEmpresasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final todas = vm.empresas;
    final pendientes = todas.where((e) => !e.validado).toList();
    final validadas = todas.where((e) => e.validado).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Empresas',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                Tab(text: 'Todas (${todas.length})'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Pendientes (${pendientes.length})'),
                      if (pendientes.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE65100),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                Tab(text: 'Validadas (${validadas.length})'),
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
                _ListaEmpresas(empresas: todas),
                _ListaEmpresas(empresas: pendientes),
                _ListaEmpresas(empresas: validadas),
              ],
            ),
    );
  }
}

// ── Lista ─────────────────────────────────────────────────────
class _ListaEmpresas extends StatelessWidget {
  final List<EmpresaModel> empresas;
  const _ListaEmpresas({required this.empresas});

  @override
  Widget build(BuildContext context) {
    if (empresas.isEmpty) {
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
              child: const Icon(Icons.business_outlined,
                  size: 40, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay empresas en esta categoría',
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
      itemCount: empresas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _EmpresaCard(empresa: empresas[i]),
    );
  }
}

// ── Card empresa ──────────────────────────────────────────────
class _EmpresaCard extends StatelessWidget {
  final EmpresaModel empresa;
  const _EmpresaCard({required this.empresa});

  @override
  Widget build(BuildContext context) {
    final validada = empresa.validado;
    final vm = context.read<AdminViewModel>();
    final inicial = empresa.razonSocial.isNotEmpty
        ? empresa.razonSocial[0].toUpperCase()
        : '?';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: validada
              ? const Color(0xFFA5D6A7).withOpacity(0.6)
              : const Color(0xFFFFCC80).withOpacity(0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado coloreado ──────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: validada
                  ? const Color(0xFFF1F8E9)
                  : const Color(0xFFFFF8F0),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: validada
                        ? const Color(0xFF2E7D32).withOpacity(0.15)
                        : const Color(0xFFE65100).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      inicial,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: validada
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFE65100),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        empresa.razonSocial,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        empresa.sector,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                _BadgeEstado(validada: validada),
              ],
            ),
          ),

          // ── Info ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(Icons.tag_rounded, 'NIT', empresa.nit),
                const SizedBox(height: 8),
                _InfoRow(
                    Icons.email_outlined, 'Correo', empresa.correo),
                if (empresa.telefono != null &&
                    empresa.telefono!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(Icons.phone_outlined, 'Teléfono',
                      empresa.telefono!),
                ],
                const SizedBox(height: 8),
                _InfoRow(
                  Icons.calendar_today_outlined,
                  'Registro',
                  empresa.fechaRegistro.length >= 10
                      ? empresa.fechaRegistro.substring(0, 10)
                      : empresa.fechaRegistro,
                ),
                if (empresa.descripcion != null &&
                    empresa.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Text(
                    empresa.descripcion!,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // ── Acciones ──────────────────────────────────────
                if (!validada)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await vm.validarEmpresa(empresa.id!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Empresa validada correctamente'),
                              backgroundColor: Color(0xFF2E7D32),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Validar empresa',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
                if (validada)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm =
                            await _confirmarRevocacion(context);
                        if (confirm == true) {
                          await vm.revocarEmpresa(empresa.id!);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⚠️ Validación revocada'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Revocar validación',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                            color: AppColors.error.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
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

  Future<bool?> _confirmarRevocacion(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Revocar validación',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            '¿Estás seguro de revocar la validación de "${empresa.razonSocial}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0),
            child: const Text('Revocar'),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────
class _BadgeEstado extends StatelessWidget {
  final bool validada;
  const _BadgeEstado({required this.validada});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: validada
            ? const Color(0xFF2E7D32).withOpacity(0.12)
            : const Color(0xFFE65100).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            validada ? Icons.check_circle : Icons.hourglass_top,
            size: 12,
            color: validada
                ? const Color(0xFF2E7D32)
                : const Color(0xFFE65100),
          ),
          const SizedBox(width: 4),
          Text(
            validada ? 'Validada' : 'Pendiente',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: validada
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFE65100),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  const _InfoRow(this.icono, this.etiqueta, this.valor);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 15, color: AppColors.primary.withOpacity(0.6)),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: Text(
            etiqueta,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
