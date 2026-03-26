import 'package:flutter/material.dart';

class EtiquetaInclusionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool seleccionado;
  final VoidCallback onTap;

  const EtiquetaInclusionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado ? color.withOpacity(0.12) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? color : Colors.grey.shade300,
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16,
              color: seleccionado ? color : Colors.grey),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                fontSize: 13,
                color: seleccionado ? color : Colors.grey.shade700,
                fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
              )),
        ]),
      ),
    );
  }
}
