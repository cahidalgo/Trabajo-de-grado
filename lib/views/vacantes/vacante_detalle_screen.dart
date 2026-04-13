import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../data/models/vacante.dart';
import '../../data/models/perfil.dart';
import '../../data/repositories/vacante_repository.dart';
import '../../data/repositories/perfil_repository.dart';
import '../../viewmodels/postulacion_viewmodel.dart';

class VacanteDetalleScreen extends StatefulWidget {
  final int vacanteId;
  const VacanteDetalleScreen({super.key, required this.vacanteId});

  @override
  State<VacanteDetalleScreen> createState() => _VacanteDetalleScreenState();
}

class _VacanteDetalleScreenState extends State<VacanteDetalleScreen> {
  final _repo       = VacanteRepository();
  final _perfilRepo = PerfilRepository();

  Vacante? _vacante;
  Perfil?  _perfil;
  bool _cargando      = true;
  bool _yaPostulado   = false;
  bool _guardada      = false;
  bool _togglingGuard = false;
  int? _usuarioId;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final authId = SupabaseService.currentAuthId;
      if (authId != null) {
        final data = await SupabaseService.client
            .from('usuarios')
            .select('id')
            .eq('auth_id', authId)
            .maybeSingle();
        _usuarioId = data?['id'] as int?;
      }

      _vacante = await _repo.obtenerPorId(widget.vacanteId);

      if (_usuarioId != null && _vacante != null) {
        final vm = context.read<PostulacionViewModel>();
        _yaPostulado = await vm.verificarYaPostulado(widget.vacanteId);
        _guardada    = await _repo.estaGuardada(_usuarioId!, widget.vacanteId);
        _perfil      = await _perfilRepo.obtenerPorUsuario(_usuarioId!);
      }
    } catch (e) {
      debugPrint('Error al cargar detalle: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _toggleGuardar() async {
    if (_usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para guardar vacantes.')),
      );
      return;
    }
    if (_togglingGuard) return;
    setState(() => _togglingGuard = true);
    try {
      if (_guardada) {
        await _repo.quitarGuardada(_usuarioId!, widget.vacanteId);
        if (!mounted) return;
        setState(() => _guardada = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vacante eliminada de guardadas')),
        );
      } else {
        await _repo.guardar(_usuarioId!, widget.vacanteId);
        if (!mounted) return;
        setState(() => _guardada = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vacante guardada. Encuéntrala en "Guardadas"'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _togglingGuard = false);
    }
  }

  /// Punto de entrada del botón "Postularme".
  /// Verifica perfil completo antes de mostrar el diálogo de confirmación.
  void _intentarPostular() {
    final perfilCompleto = _perfil?.perfilCompleto ?? false;
    if (!perfilCompleto) {
      _mostrarDialogoPerfilIncompleto();
      return;
    }
    _mostrarDialogoPostulacion();
  }

  void _mostrarDialogoPerfilIncompleto() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_off_outlined,
              color: AppColors.warning, size: 30),
        ),
        title: const Text(
          'Completa tu perfil primero',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Las empresas necesitan ver tu información para evaluar tu candidatura. '
          'Añade tu nivel educativo, experiencia y habilidades antes de postularte.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/editar-perfil').then((_) => _cargar());
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Completar mi perfil'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Después'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoPostulacion() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Confirmar postulación?'),
        content: Text(
          'Te vas a postular a:\n\n${_vacante!.titulo}\n${_vacante!.empresa ?? ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _ejecutarPostulacion();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _ejecutarPostulacion() async {
    final vm = context.read<PostulacionViewModel>();
    await vm.postular(widget.vacanteId);
    if (!mounted) return;
    switch (vm.state) {
      case PostulacionState.exitosa:
        setState(() => _yaPostulado = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Te postulaste con éxito!')),
        );
        vm.resetState();
      case PostulacionState.yaPostulado:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya te postulaste a esta vacante.')),
        );
        vm.resetState();
      case PostulacionState.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMsg ?? 'Error'),
            backgroundColor: AppColors.error,
          ),
        );
        vm.resetState();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_vacante == null) return const Scaffold(body: Center(child: Text('Vacante no encontrada.')));

    final vm            = context.watch<PostulacionViewModel>();
    final cargandoPost  = vm.state == PostulacionState.loading;
    final perfilCompleto = _perfil?.perfilCompleto ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _vacante!.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          _togglingGuard
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      _guardada ? Icons.bookmark : Icons.bookmark_outline,
                      key: ValueKey(_guardada),
                      color: _guardada ? Colors.amber : AppColors.primary,
                    ),
                  ),
                  tooltip: _guardada ? 'Quitar de guardadas' : 'Guardar vacante',
                  onPressed: _toggleGuardar,
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    child: const Icon(Icons.work_outline,
                        color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _vacante!.titulo,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _vacante!.empresa ?? '',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Banner de perfil incompleto ──────────────────────
            if (!perfilCompleto && !_yaPostulado) ...[
              const SizedBox(height: 14),
              _BannerPerfilIncompleto(
                onCompletar: () =>
                    context.push('/editar-perfil').then((_) => _cargar()),
              ),
            ],

            const SizedBox(height: 20),
            _InfoRow(icon: Icons.category_outlined, label: 'Categoría', valor: _vacante!.categoria),
            _InfoRow(icon: Icons.laptop_outlined, label: 'Modalidad', valor: _vacante!.modalidad),
            _InfoRow(icon: Icons.schedule_outlined, label: 'Jornada', valor: _vacante!.jornada),
            _InfoRow(icon: Icons.attach_money, label: 'Salario', valor: _vacante!.salarioReferencial),
            _InfoRow(icon: Icons.event_outlined, label: 'Cierre', valor: _vacante!.fechaCierre),
            const Divider(height: 28),
            const Text(
              'Descripción del cargo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _vacante!.descripcion ?? '',
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'Requisitos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _vacante!.requisitos ?? '',
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_guardada) ...[
              OutlinedButton.icon(
                onPressed: _toggleGuardar,
                icon: const Icon(Icons.bookmark_border),
                label: const Text('Guardar para después'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
              const SizedBox(height: 10),
            ],
            _yaPostulado
                ? OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check_circle,
                        color: AppColors.success),
                    label: const Text(
                      'Ya te postulaste',
                      style: TextStyle(color: AppColors.success),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: AppColors.success),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: (!_vacante!.activa || cargandoPost)
                        ? null
                        : _intentarPostular, // ← usa el nuevo método guard
                    icon: cargandoPost
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            perfilCompleto
                                ? Icons.send_outlined
                                : Icons.warning_amber_rounded,
                          ),
                    label: Text(_vacante!.activa
                        ? (perfilCompleto
                            ? 'Postularme'
                            : 'Postularme (completa tu perfil)')
                        : 'Vacante cerrada'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: perfilCompleto || !_vacante!.activa
                          ? null
                          : AppColors.warning,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ── Banner de aviso de perfil incompleto ──────────────────────
class _BannerPerfilIncompleto extends StatelessWidget {
  final VoidCallback onCompletar;
  const _BannerPerfilIncompleto({required this.onCompletar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.warning.withOpacity(0.35), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              color: AppColors.warning, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu perfil está incompleto',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Las empresas evaluarán tu candidatura con la información de tu perfil. Complétalo para tener más chances.',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.warning,
                      height: 1.4),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onCompletar,
                  child: const Text(
                    'Completar perfil →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                      decoration: TextDecoration.underline,
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
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? valor;
  const _InfoRow({required this.icon, required this.label, this.valor});

  @override
  Widget build(BuildContext context) {
    if (valor == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(valor!)),
        ],
      ),
    );
  }
}
