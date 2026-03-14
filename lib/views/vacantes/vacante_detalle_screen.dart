import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/vacante.dart';
import '../../data/repositories/vacante_repository.dart';

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

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    _vacante = await _repo.obtenerPorId(widget.vacanteId);
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_vacante == null) return const Scaffold(body: Center(child: Text('Vacante no encontrada.')));

    return Scaffold(
      appBar: AppBar(title: Text(_vacante!.titulo)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_vacante!.titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_vacante!.empresa ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
            const SizedBox(height: 16),
            _InfoRow(icon: Icons.category_outlined,    label: 'Categoría',  valor: _vacante!.categoria),
            _InfoRow(icon: Icons.location_on_outlined, label: 'Modalidad',  valor: _vacante!.modalidad),
            _InfoRow(icon: Icons.schedule_outlined,    label: 'Jornada',    valor: _vacante!.jornada),
            _InfoRow(icon: Icons.attach_money,         label: 'Salario',    valor: _vacante!.salarioReferencial),
            _InfoRow(icon: Icons.event_outlined,       label: 'Cierre',     valor: _vacante!.fechaCierre),
            const Divider(height: 32),
            const Text('Descripción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_vacante!.descripcion ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 16),
            const Text('Requisitos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_vacante!.requisitos ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _vacante!.activa ? () => _confirmarPostulacion(context) : null,
          icon: const Icon(Icons.send_outlined),
          label: Text(_vacante!.activa ? 'Postularme' : 'Vacante cerrada'),
        ),
      ),
    );
  }

  void _confirmarPostulacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Confirmar postulación?'),
        content: Text('Te vas a postular a: ${_vacante!.titulo} en ${_vacante!.empresa}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('¡Te postulaste con éxito!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Confirmar'),
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
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(valor!)),
        ],
      ),
    );
  }
}
