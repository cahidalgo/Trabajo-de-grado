import 'package:flutter/material.dart';
import '../utils/validators.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final score = Validators.fuerzaContrasena(password);
    final labels = ['Débil', 'Regular', 'Fuerte'];
    final colors = [Colors.red, Colors.orange, Colors.green];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(3, (i) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i < score ? colors[score - 1] : const Color(0xFFE0E0E0),
              ),
            ),
          )),
        ),
        if (score > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Contraseña: ${labels[score - 1]}',
            style: TextStyle(fontSize: 12, color: colors[score - 1]),
          ),
        ],
      ],
    );
  }
}
