import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis postulaciones')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt_outlined, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('Aún no te has postulado', style: TextStyle(fontSize: 16)),
            Text('Explora las vacantes y postúlate.', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
