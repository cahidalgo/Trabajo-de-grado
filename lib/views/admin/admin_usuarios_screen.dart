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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Usuarios (${usuarios.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: vm.cargando
          ? const Center(child: CircularProgressIndicator())
          : usuarios.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.border.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.people_outline,
                            size: 40, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aún no hay usuarios registrados',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: usuarios.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, i) =>
                      _UsuarioCard(usuario: usuarios[i]),
                ),
    );
  }
}

class _UsuarioCard extends StatelessWidget {
  final Map<String, dynamic> usuario;
  const _UsuarioCard({required this.usuario});

  @override
  Widget build(BuildContext context) {
    final nombre =
        (usuario['nombreCompleto'] as String?)?.isNotEmpty == true
            ? usuario['nombreCompleto'] as String
            : 'Sin nombre';
    final contacto = usuario['correoOTelefono'] as String? ?? '';
    final raw = usuario['fechaRegistro'] as String? ?? '';
    final fecha =
        raw.length >= 10 ? raw.substring(0, 10) : raw;
    final perfilCompleto = (usuario['perfilCompleto'] as int?) == 1;
    final inicial =
        nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    // Color del avatar según inicial
    final avatarColors = [
      AppColors.primary,
      const Color(0xFF2E7D32),
      const Color(0xFF6A1B9A),
      const Color(0xFFBF360C),
      const Color(0xFF00695C),
    ];
    final colorIdx = nombre.isEmpty
        ? 0
        : nombre.codeUnitAt(0) % avatarColors.length;
    final avatarColor = avatarColors[colorIdx];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar ─────────────────────────────────────────
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: avatarColor.withOpacity(0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                inicial,
                style: TextStyle(
                  color: avatarColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // ── Info ───────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _PerfilBadge(completo: perfilCompleto),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.alternate_email,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        contacto,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (fecha.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 5),
                      Text(
                        'Registrado el $fecha',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerfilBadge extends StatelessWidget {
  final bool completo;
  const _PerfilBadge({required this.completo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: completo
            ? const Color(0xFF2E7D32).withOpacity(0.1)
            : AppColors.border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completo ? Icons.check_circle : Icons.person_outline,
            size: 12,
            color: completo
                ? const Color(0xFF2E7D32)
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            completo ? 'Perfil completo' : 'Incompleto',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: completo
                  ? const Color(0xFF2E7D32)
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
