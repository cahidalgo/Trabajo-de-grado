import 'package:flutter/material.dart';
import '../../data/models/vacante_empresa_model.dart';

class VacanteEmpresaCard extends StatelessWidget {
  final VacanteEmpresaModel vacante;
  final VoidCallback onToggle;
  final VoidCallback onEliminar;
  final VoidCallback onVerPostulantes;

  const VacanteEmpresaCard({
    super.key,
    required this.vacante,
    required this.onToggle,
    required this.onEliminar,
    required this.onVerPostulantes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(vacante.titulo,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: vacante.activa ? Colors.green.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                vacante.activa ? 'Activa' : 'Pausada',
                style: TextStyle(
                  fontSize: 12,
                  color: vacante.activa ? Colors.green.shade800 : Colors.grey,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Text('${vacante.modalidad} · ${vacante.jornada}',
              style: const TextStyle(color: Colors.grey)),
          if (vacante.salarioReferencial != null)
            Text(vacante.salarioReferencial!,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(children: [
            TextButton.icon(
              onPressed: onVerPostulantes,
              icon: const Icon(Icons.people_outline, size: 18),
              label: const Text('Postulantes'),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                vacante.activa ? Icons.pause_circle_outline : Icons.play_circle_outline,
                color: Colors.amber,
              ),
              tooltip: vacante.activa ? 'Pausar' : 'Activar',
              onPressed: onToggle,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Eliminar',
              onPressed: onEliminar,
            ),
          ]),
        ]),
      ),
    );
  }
}
