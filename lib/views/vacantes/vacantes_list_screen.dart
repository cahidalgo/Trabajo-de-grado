import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/vacante.dart';
import '../../data/repositories/vacante_repository.dart';
import 'vacante_detalle_screen.dart';

class VacantesListScreen extends StatefulWidget {
  const VacantesListScreen({super.key});

  @override
  State<VacantesListScreen> createState() => _VacantesListScreenState();
}

class _VacantesListScreenState extends State<VacantesListScreen> {
  final _repo = VacanteRepository();
  List<Vacante> _vacantes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    _vacantes = await _repo.obtenerTodas();
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vacantes disponibles')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _vacantes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_off_outlined, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text('No hay vacantes disponibles', style: TextStyle(fontSize: 16)),
                      Text('Vuelve a revisar más tarde.', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _vacantes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _TarjetaVacante(
                      vacante: _vacantes[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => VacanteDetalleScreen(vacanteId: _vacantes[i].id!)),
                      ),
                    ),
                  ),
                ),
    );
  }
}

class _TarjetaVacante extends StatelessWidget {
  final Vacante vacante;
  final VoidCallback onTap;
  const _TarjetaVacante({required this.vacante, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(vacante.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(vacante.empresa ?? '', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (vacante.categoria != null) _Chip(vacante.categoria!),
                  if (vacante.modalidad != null) _Chip(vacante.modalidad!),
                  if (vacante.jornada != null)   _Chip(vacante.jornada!),
                ],
              ),
              if (vacante.fechaCierre != null) ...[
                const SizedBox(height: 8),
                Text('Cierre: ${vacante.fechaCierre}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(label, style: const TextStyle(fontSize: 11)),
    padding: EdgeInsets.zero,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    backgroundColor: const Color(0xFFE3F2FD),
  );
}
