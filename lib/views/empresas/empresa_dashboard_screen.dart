import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_ui.dart';
import '../../core/widgets/avatar_perfil.dart';
import '../../data/models/empresa_model.dart';
import '../../viewmodels/empresa_viewmodel.dart';
import '../../viewmodels/vacante_empresa_viewmodel.dart';
import 'mis_vacantes_screen.dart';

class EmpresaDashboardScreen extends StatefulWidget {
  const EmpresaDashboardScreen({super.key});

  @override
  State<EmpresaDashboardScreen> createState() =>
      _EmpresaDashboardScreenState();
}

class _EmpresaDashboardScreenState extends State<EmpresaDashboardScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    final empresaVm = context.read<EmpresaViewModel>();
    await empresaVm.restaurarSesion();

    final empresaId = empresaVm.empresaActual?.id;
    if (!mounted || empresaId == null) return;

    await context
        .read<VacanteEmpresaViewModel>()
        .cargarVacantes(empresaId);
  }

  @override
  Widget build(BuildContext context) {
    final empresaVm = context.watch<EmpresaViewModel>();
    final empresa = empresaVm.empresaActual;

    if (empresaVm.cargando && empresa == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (empresa == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Panel de empresa')),
        body: AppEmptyState(
          icon: Icons.business_center_outlined,
          title: 'No encontramos tu sesión',
          description:
              'Inicia sesión nuevamente para administrar vacantes y revisar postulantes.',
          action: ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Ir a iniciar sesión'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(empresa.razonSocial),
        automaticallyImplyLeading: false,
        actions: [
          if (_tab == 1)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar empresa',
              onPressed: () async {
                await context.push('/empresa/editar');
                setState(() {});
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await context.read<EmpresaViewModel>().cerrarSesion();
              if (!mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
      body: _tab == 0
          ? const MisVacantesScreen()
          : _PerfilEmpresaResumen(empresa: empresa),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/empresa/publicar'),
              icon: const Icon(Icons.add),
              label: const Text('Publicar vacante'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) =>
            setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            label: 'Mis vacantes',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            label: 'Mi empresa',
          ),
        ],
      ),
    );
  }
}

// ── Pestaña "Mi empresa" ──────────────────────────────────────────────────────
class _PerfilEmpresaResumen extends StatelessWidget {
  final EmpresaModel empresa;
  const _PerfilEmpresaResumen({required this.empresa});

  String _iniciales() {
    final partes = empresa.razonSocial.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return empresa.razonSocial[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<EmpresaViewModel>().restaurarSesion(),
      child: CustomScrollView(
        slivers: [
          // ── Header con foto ──────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                ),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: 28, horizontal: 20),
              child: Column(
                children: [
                  // Avatar empresa con foto editable
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor:
                            Colors.white.withOpacity(0.2),
                        backgroundImage: empresa.fotoPerfil != null
                            ? FileImage(File(empresa.fotoPerfil!))
                            : null,
                        child: empresa.fotoPerfil == null
                            ? Text(
                                _iniciales(),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await context.push('/empresa/editar');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 16,
                              color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    empresa.razonSocial,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    empresa.sector,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: empresa.validado
                          ? const Color(0xFF43A047)
                          : const Color(0xFFFFA000),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          empresa.validado
                              ? Icons.verified_outlined
                              : Icons.access_time_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          empresa.validado
                              ? 'Empresa validada'
                              : 'En validación',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Contenido ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción si existe
                  if ((empresa.descripcion ?? '').isNotEmpty) ...[
                    _SeccionTitulo(
                        titulo: 'Sobre la empresa',
                        icono: Icons.info_outline),
                    _TarjetaTexto(empresa.descripcion!),
                    const SizedBox(height: 16),
                  ],

                  // Datos registrados
                  _SeccionTitulo(
                    titulo: 'Información registrada',
                    icono: Icons.badge_outlined,
                  ),
                  _TarjetaDatos(empresa: empresa),
                  const SizedBox(height: 16),

                  // Banner validación
                  AppInfoBanner(
                    title: empresa.validado
                        ? 'Cuenta validada'
                        : 'Validación pendiente',
                    description: empresa.validado
                        ? 'Tus vacantes están visibles para los candidatos en la plataforma.'
                        : 'Las vacantes registradas quedarán visibles cuando el equipo de Formalia confirme la empresa.',
                    icon: empresa.validado
                        ? Icons.verified_outlined
                        : Icons.info_outline,
                    color: empresa.validado
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  const SizedBox(height: 16),

                  // Botón editar
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.push('/empresa/editar'),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar información'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────
class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  final IconData icono;
  const _SeccionTitulo({required this.titulo, required this.icono});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icono, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
}

class _TarjetaTexto extends StatelessWidget {
  final String texto;
  const _TarjetaTexto(this.texto);

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Text(
          texto,
          style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5),
        ),
      );
}

class _TarjetaDatos extends StatelessWidget {
  final EmpresaModel empresa;
  const _TarjetaDatos({required this.empresa});

  @override
  Widget build(BuildContext context) {
    final datos = <_Dato>[
      _Dato('NIT', empresa.nit, Icons.numbers_outlined),
      _Dato('Sector', empresa.sector, Icons.category_outlined),
      _Dato('Correo', empresa.correo, Icons.email_outlined),
      if ((empresa.telefono ?? '').trim().isNotEmpty)
        _Dato('Teléfono', empresa.telefono!, Icons.phone_outlined),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: datos.asMap().entries.map((e) {
          final dato = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(dato.icono,
                        size: 18,
                        color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(dato.label,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(dato.valor,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (e.key < datos.length - 1)
                const Divider(height: 1, indent: 46),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _Dato {
  final String label;
  final String valor;
  final IconData icono;
  const _Dato(this.label, this.valor, this.icono);
}
