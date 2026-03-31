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
      appBar: AppBar(
        title: const Text('Empresas'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: 'Todas (${todas.length})'),
            Tab(text: 'Pendientes (${pendientes.length})'),
            Tab(text: 'Validadas (${validadas.length})'),
          ],
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

// ── Lista de empresas ─────────────────────────────────────────
class _ListaEmpresas extends StatelessWidget {
  final List<EmpresaModel> empresas;
  const _ListaEmpresas({required this.empresas});

  @override
  Widget build(BuildContext context) {
    if (empresas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.business_outlined, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('No hay empresas en esta categoría',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: empresas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  empresa.razonSocial,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              _BadgeEstado(validada: validada),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(Icons.tag, 'NIT: ${empresa.nit}'),
          _InfoRow(Icons.category_outlined, empresa.sector),
          _InfoRow(Icons.email_outlined, empresa.correo),
          _InfoRow(Icons.calendar_today_outlined,
              'Registrada: ${empresa.fechaRegistro.substring(0, 10)}'),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!validada)
                _ActionButton(
                  label: 'Validar empresa',
                  color: const Color(0xFF2E7D32),
                  icon: Icons.check_circle_outline,
                  onTap: () async {
                    await vm.validarEmpresa(empresa.id!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Empresa validada'),
                          backgroundColor: Color(0xFF2E7D32),
                        ),
                      );
                    }
                  },
                ),
              if (validada) ...[
                _ActionButton(
                  label: 'Revocar validación',
                  color: AppColors.error,
                  icon: Icons.cancel_outlined,
                  onTap: () async {
                    final confirm = await _confirmarRevocacion(context);
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
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmarRevocacion(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revocar validación'),
        content: Text(
            '¿Estás seguro de revocar la validación de "${empresa.razonSocial}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Revocar')),
        ],
      ),
    );
  }
}

class _BadgeEstado extends StatelessWidget {
  final bool validada;
  const _BadgeEstado({required this.validada});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: validada
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        validada ? '✓ Validada' : '⏳ Pendiente',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: validada
              ? const Color(0xFF2E7D32)
              : const Color(0xFFE65100),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _InfoRow(this.icono, this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icono, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(texto,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label,
      required this.color,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}