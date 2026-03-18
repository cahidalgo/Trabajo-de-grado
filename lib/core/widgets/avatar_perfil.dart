import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';
import '../services/foto_perfil_service.dart';

class AvatarPerfil extends StatefulWidget {
  final String iniciales;
  final double radius;
  final bool   editable;
  final void Function(String ruta)? onFotoCambiada;

  const AvatarPerfil({
    super.key,
    required this.iniciales,
    this.radius    = 44,
    this.editable  = false,
    this.onFotoCambiada,
  });

  @override
  State<AvatarPerfil> createState() => _AvatarPerfilState();
}

class _AvatarPerfilState extends State<AvatarPerfil> {
  String? _fotoPath;

  @override
  void initState() {
    super.initState();
    _cargarFoto();
  }

  Future<void> _cargarFoto() async {
    final ruta = await FotoPerfilService.obtenerRuta();
    if (mounted) setState(() => _fotoPath = ruta);
  }

  void _mostrarOpciones() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
              const Text('Cambiar foto de perfil',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                ),
                title: const Text('Tomar foto'),
                onTap: () async {
                  Navigator.pop(context);
                  await _seleccionar(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.photo_library_outlined, color: AppColors.primary),
                ),
                title: const Text('Elegir de la galería'),
                onTap: () async {
                  Navigator.pop(context);
                  await _seleccionar(ImageSource.gallery);
                },
              ),
              if (_fotoPath != null)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.delete_outline, color: AppColors.error),
                  ),
                  title: const Text('Eliminar foto',
                      style: TextStyle(color: AppColors.error)),
                  onTap: () async {
                    Navigator.pop(context);
                    await FotoPerfilService.eliminarFoto();
                    if (mounted) setState(() => _fotoPath = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionar(ImageSource fuente) async {
    try {
      final ruta = await FotoPerfilService.seleccionarFoto(fuente);
      if (ruta != null && mounted) {
        setState(() => _fotoPath = ruta);
        widget.onFotoCambiada?.call(ruta);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo acceder a la cámara o galería. Revisa los permisos.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tienefoto = _fotoPath != null && File(_fotoPath!).existsSync();

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // ── Avatar ──────────────────────────────────────────────────
        CircleAvatar(
          radius: widget.radius,
          backgroundColor: Colors.white.withOpacity(0.2),
          backgroundImage: tienefoto
              ? FileImage(File(_fotoPath!)) as ImageProvider
              : null,
          child: tienefoto
              ? null
              : Text(
                  widget.iniciales,
                  style: TextStyle(
                    fontSize: widget.radius * 0.65,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),

        // ── Botón editar (solo si es editable) ─────────────────────
        if (widget.editable)
          GestureDetector(
            onTap: _mostrarOpciones,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                tienefoto ? Icons.edit : Icons.add_a_photo_outlined,
                size: widget.radius * 0.35,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
