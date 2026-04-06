import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../data/models/vacante.dart';
import '../../data/repositories/vacante_repository.dart';
import '../../viewmodels/postulacion_viewmodel.dart';

class VacanteDetalleScreen extends StatefulWidget {
  final int vacanteId;
  const VacanteDetalleScreen({super.key, required this.vacanteId});

  @override
  State<VacanteDetalleScreen> createState() => _VacanteDetalleScreenState();
}

class _VacanteDetalleScreenState extends State<VacanteDetalleScreen> {
  final _repo = VacanteRepository();
  Vacante? _vacante;
  bool _cargando = true;
  bool _yaPostulado = false;
  bool _guardada = false;
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
        _guardada = await _repo.estaGuardada(_usuarioId!, widget.vacanteId);
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

    final vm = context.watch<PostulacionViewModel>();
    final cargandoPost = vm.state == PostulacionState.loading;

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
                    child: const Icon(Icons.work_outline, color: AppColors.primary, size: 28),
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
                    icon: const Icon(Icons.check_circle, color: AppColors.success),
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
                        : _mostrarDialogoPostulacion,
                    icon: cargandoPost
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(_vacante!.activa ? 'Postularme' : 'Vacante cerrada'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
          ],
        ),
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
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(valor!)),
        ],
      ),
    );
  }
}