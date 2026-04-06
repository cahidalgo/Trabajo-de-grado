import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../core/widgets/avatar_perfil.dart';
import '../../data/models/usuario.dart';
import '../../data/models/perfil.dart';
import '../../data/repositories/usuario_repository.dart';
import '../../data/repositories/perfil_repository.dart';
import '../../viewmodels/auth_viewmodel.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen>
    with AutomaticKeepAliveClientMixin {
  final _usuarioRepo = UsuarioRepository();
  final _perfilRepo = PerfilRepository();

  Usuario? _usuario;
  Perfil? _perfil;
  bool _cargando = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final authId = SupabaseService.currentAuthId;
    if (authId != null) {
      final data = await SupabaseService.client
          .from('usuarios')
          .select('id')
          .eq('auth_id', authId)
          .maybeSingle();
      final usuarioId = data?['id'] as int?;
      if (usuarioId != null) {
        _usuario = await _usuarioRepo.obtenerPorId(usuarioId);
        _perfil = await _perfilRepo.obtenerPorUsuario(usuarioId);
      }
    }
    if (mounted) setState(() => _cargando = false);
  }

  int _calcularCompletitud() {
    if (_perfil == null) return 0;
    final campos = [
      _perfil!.nivelEducativo,
      _perfil!.experienciaLaboral,
      _perfil!.habilidades,
      _perfil!.areasInteres,
      _perfil!.modalidadPreferida,
      _perfil!.jornadaPreferida,
    ];
    final llenos = campos.where((c) => c != null && c.isNotEmpty).length;
    return ((llenos / campos.length) * 100).round();
  }

  String _iniciales() {
    final nombre = _usuario?.nombreCompleto ?? '';
    if (nombre.isEmpty) return '?';
    final partes = nombre.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre[0].toUpperCase();
  }

  String _formatFecha(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '—';
    }
  }

  void _confirmarCerrarSesion() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthViewModel>().cerrarSesion();
              if (mounted) context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final completitud = _calcularCompletitud();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppColors.primary,
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        AvatarPerfil(
                          iniciales: _iniciales(),
                          radius: 44,
                          editable: true,
                          onFotoCambiada: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _usuario?.nombreCompleto ?? 'Sin nombre',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _usuario?.correoOTelefono ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            completitud == 100
                                ? '✓ Perfil completo'
                                : 'Perfil $completitud% completo',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  tooltip: 'Editar perfil',
                  onPressed: () async {
                    await context.push('/editar-perfil');
                    _cargar();
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TarjetaCompletitud(
                      completitud: completitud,
                      onCompletar: () async {
                        await context.push('/editar-perfil');
                        _cargar();
                      },
                    ),
                    const SizedBox(height: 16),
                    const _SeccionTitulo(
                      titulo: 'Información laboral',
                      icono: Icons.work_outline,
                    ),
                    _TarjetaInfo(
                      campos: [
                        _CampoInfo('Nivel educativo', _perfil?.nivelEducativo, Icons.school_outlined),
                        _CampoInfo('Experiencia laboral', _perfil?.experienciaLaboral, Icons.history_edu_outlined),
                        _CampoInfo('Habilidades', _perfil?.habilidades, Icons.star_outline),
                        _CampoInfo('Áreas de interés', _perfil?.areasInteres, Icons.category_outlined),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _SeccionTitulo(
                      titulo: 'Preferencias de trabajo',
                      icono: Icons.tune_outlined,
                    ),
                    _TarjetaInfo(
                      campos: [
                        _CampoInfo('Modalidad preferida', _perfil?.modalidadPreferida, Icons.laptop_outlined),
                        _CampoInfo('Jornada preferida', _perfil?.jornadaPreferida, Icons.schedule_outlined),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await context.push('/editar-perfil');
                        _cargar();
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar información'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _SeccionTitulo(
                      titulo: 'Cuenta',
                      icono: Icons.settings_outlined,
                    ),
                    _TarjetaOpciones(
                      opciones: [
                        _OpcionMenu(
                          icono: Icons.privacy_tip_outlined,
                          label: 'Política de privacidad',
                          color: AppColors.primary,
                          onTap: () => context.push('/politica-privacidad'),
                        ),
                        _OpcionMenu(
                          icono: Icons.calendar_today_outlined,
                          label: 'Miembro desde: ${_formatFecha(_usuario?.fechaRegistro)}',
                          color: AppColors.textSecondary,
                          onTap: null,
                        ),
                        _OpcionMenu(
                          icono: Icons.logout,
                          label: 'Cerrar sesión',
                          color: AppColors.error,
                          onTap: _confirmarCerrarSesion,
                        ),
                      ],
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

class _TarjetaCompletitud extends StatelessWidget {
  final int completitud;
  final VoidCallback onCompletar;
  const _TarjetaCompletitud({required this.completitud, required this.onCompletar});

  Color get _color {
    if (completitud >= 80) return AppColors.success;
    if (completitud >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String get _mensaje {
    if (completitud == 100) return '¡Perfil completo! Tienes más visibilidad ante empleadores.';
    if (completitud >= 60) return 'Casi listo. Completa tu perfil para mejores resultados.';
    return 'Tu perfil está incompleto. ¡Complétalo para destacar!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_outlined, color: _color),
              const SizedBox(width: 8),
              const Text(
                'Completitud del perfil',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Text(
                '$completitud%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: _color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completitud / 100,
              minHeight: 8,
              backgroundColor: AppColors.border,
              color: _color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _mensaje,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          if (completitud < 100) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onCompletar,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Completar ahora'),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
            ),
          ],
        ],
      ),
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  final IconData icono;
  const _SeccionTitulo({required this.titulo, required this.icono});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icono, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
}

class _CampoInfo {
  final String label;
  final String? valor;
  final IconData icono;
  const _CampoInfo(this.label, this.valor, this.icono);
}

class _TarjetaInfo extends StatelessWidget {
  final List<_CampoInfo> campos;
  const _TarjetaInfo({required this.campos});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: campos.asMap().entries.map((entry) {
          final i = entry.key;
          final campo = entry.value;
          final vacio = campo.valor == null || campo.valor!.isEmpty;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      campo.icono,
                      size: 20,
                      color: vacio ? AppColors.textSecondary : AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campo.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vacio ? 'No especificado' : campo.valor!,
                            style: TextStyle(
                              fontSize: 14,
                              color: vacio ? AppColors.textDisabled : AppColors.textPrimary,
                              fontStyle: vacio ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < campos.length - 1)
                const Divider(height: 1, indent: 48),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _OpcionMenu {
  final IconData icono;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _OpcionMenu({
    required this.icono,
    required this.label,
    required this.color,
    this.onTap,
  });
}

class _TarjetaOpciones extends StatelessWidget {
  final List<_OpcionMenu> opciones;
  const _TarjetaOpciones({required this.opciones});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: opciones.asMap().entries.map((entry) {
          final i = entry.key;
          final op = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(op.icono, color: op.color),
                title: Text(op.label, style: TextStyle(color: op.color, fontSize: 14)),
                trailing: op.onTap != null
                    ? Icon(Icons.chevron_right, color: op.color)
                    : null,
                onTap: op.onTap,
                dense: true,
              ),
              if (i < opciones.length - 1)
                const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}