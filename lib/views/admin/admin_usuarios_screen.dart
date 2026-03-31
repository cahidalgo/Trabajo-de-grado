import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/admin_viewmodel.dart';

class AdminUsuariosScreen extends StatelessWidget {
  const AdminUsuariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final usuarios = vm.usuarios;

    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios (${usuarios.length})'),
        automaticallyImplyLeading: false,
      ),
      body: vm.cargando
          ? const Center(child: CircularProgressIndicator())
          : usuarios.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline,
                          size: 48, color: AppColors.textSecondary),
                      SizedBox(height: 12),
                      Text('Aún no hay usuarios registrados',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: usuarios.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => _UsuarioTile(usuario: usuarios[i]),
                ),
    );
  }
}

class _UsuarioTile extends StatelessWidget {
  final Map<String, dynamic> usuario;
  const _UsuarioTile({required this.usuario});

  @override
  Widget build(BuildContext context) {
    final nombre =
        (usuario['nombreCompleto'] as String?)?.isNotEmpty == true
            ? usuario['nombreCompleto'] as String
            : 'Sin nombre';
    final contacto = usuario['correoOTelefono'] as String? ?? '';
    final fecha = (usuario['fechaRegistro'] as String? ?? '').length >= 10
        ? (usuario['fechaRegistro'] as String).substring(0, 10)
        : '';
    final perfilCompleto = (usuario['perfilCompleto'] as int?) == 1;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.primary.withOpacity(0.12),
        child: Text(
          nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
          style: const TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(nombre,
          style:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(contacto,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          if (fecha.isNotEmpty)
            Text('Registrado: $fecha',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
      trailing: Tooltip(
        message: perfilCompleto ? 'Perfil completo' : 'Perfil incompleto',
        child: Icon(
          perfilCompleto
              ? Icons.check_circle_outline
              : Icons.radio_button_unchecked,
          color: perfilCompleto
              ? const Color(0xFF2E7D32)
              : AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}