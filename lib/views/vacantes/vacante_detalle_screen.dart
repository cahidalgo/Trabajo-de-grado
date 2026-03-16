import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
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
  final _repo   = VacanteRepository();
  Vacante? _vacante;
  bool _cargando       = true;
  bool _yaPostulado    = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    _vacante = await _repo.obtenerPorId(widget.vacanteId);
    final vm = context.read<PostulacionViewModel>();
    _yaPostulado = await vm.verificarYaPostulado(widget.vacanteId);
    setState(() => _cargando = false);
  }

  void _mostrarDialogoPostulacion() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Confirmar postulación?'),
        content: Text(
          'Te vas a postular a:\n\n'
          '${_vacante!.titulo}\n${_vacante!.empresa ?? ''}',
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
          const SnackBar(
            content: Text('¡Te postulaste con éxito! Revisa tus postulaciones.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        vm.resetState();
      case PostulacionState.yaPostulado:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya te postulaste a esta vacante anteriormente.'),
            backgroundColor: Colors.orange,
          ),
        );
        vm.resetState();
      case PostulacionState.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMsg ?? 'Error al postularse.'),
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
    final cargandoPostulacion = vm.state == PostulacionState.loading;

    return Scaffold(
      appBar: AppBar(title: Text(_vacante!.titulo)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_vacante!.titulo,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_vacante!.empresa ?? '',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
            const SizedBox(height: 16),
            _InfoRow(icon: Icons.category_outlined,    label: 'Categoría', valor: _vacante!.categoria),
            _InfoRow(icon: Icons.location_on_outlined, label: 'Modalidad', valor: _vacante!.modalidad),
            _InfoRow(icon: Icons.schedule_outlined,    label: 'Jornada',   valor: _vacante!.jornada),
            _InfoRow(icon: Icons.attach_money,         label: 'Salario',   valor: _vacante!.salarioReferencial),
            _InfoRow(icon: Icons.event_outlined,       label: 'Cierre',    valor: _vacante!.fechaCierre),
            const Divider(height: 32),
            const Text('Descripción',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_vacante!.descripcion ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 16),
            const Text('Requisitos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_vacante!.requisitos ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 100), // espacio para el botón flotante
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: _yaPostulado
            ? OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check_circle, color: Colors.green),
                label: const Text('Ya te postulaste',
                    style: TextStyle(color: Colors.green)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: Colors.green),
                ),
              )
            : ElevatedButton.icon(
                onPressed: (!_vacante!.activa || cargandoPostulacion)
                    ? null
                    : _mostrarDialogoPostulacion,
                icon: cargandoPostulacion
                    ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_outlined),
                label: Text(_vacante!.activa ? 'Postularme' : 'Vacante cerrada'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String?  valor;
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
