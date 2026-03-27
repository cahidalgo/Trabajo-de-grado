import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../viewmodels/empresa_viewmodel.dart';

class EditarEmpresaScreen extends StatefulWidget {
  const EditarEmpresaScreen({super.key});

  @override
  State<EditarEmpresaScreen> createState() =>
      _EditarEmpresaScreenState();
}

class _EditarEmpresaScreenState extends State<EditarEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  bool _guardando = false;
  String? _fotoLocal;

  @override
  void initState() {
    super.initState();
    final empresa =
        context.read<EmpresaViewModel>().empresaActual;
    if (empresa != null) {
      _nombreCtrl.text = empresa.razonSocial;
      _telefonoCtrl.text = empresa.telefono ?? '';
      _descripcionCtrl.text = empresa.descripcion ?? '';
      _fotoLocal = empresa.fotoPerfil;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  String _iniciales() {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) return '?';
    final partes = nombre.split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre[0].toUpperCase();
  }

  Future<void> _seleccionarFoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(ctx);
                _tomarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(ctx);
                _tomarFoto(ImageSource.gallery);
              },
            ),
            if (_fotoLocal != null)
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: AppColors.error),
                title: const Text('Eliminar foto',
                    style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _fotoLocal = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _tomarFoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _fotoLocal = picked.path);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final vm = context.read<EmpresaViewModel>();

    // Guardar foto si cambió
    if (_fotoLocal != vm.empresaActual?.fotoPerfil) {
      await vm.actualizarFoto(_fotoLocal ?? '');
    }

    await vm.actualizarPerfil(
      razonSocial: _nombreCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
    );

    setState(() => _guardando = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Información actualizada correctamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar empresa'),
        actions: [
          TextButton(
            onPressed: _guardando ? null : _guardar,
            child: _guardando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Guardar',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Foto de perfil ─────────────────────────────
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _seleccionarFoto,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                AppColors.primary.withOpacity(0.15),
                            backgroundImage: _fotoLocal != null
                                ? FileImage(File(_fotoLocal!))
                                : null,
                            child: _fotoLocal == null
                                ? Text(
                                    _iniciales(),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toca para cambiar la foto',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Datos de la empresa ────────────────────────
              _Subtitulo('Datos de la empresa'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                    labelText: 'Razón social'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v!.trim().isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _telefonoCtrl,
                decoration: const InputDecoration(
                    labelText: 'Teléfono (opcional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción de la empresa (opcional)',
                  hintText:
                      'Ej: Empresa de logística con 10 años de experiencia...',
                ),
              ),
              const SizedBox(height: 32),

              // ── Botón guardar ──────────────────────────────
              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined),
                label: const Text('Guardar cambios'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Subtitulo extends StatelessWidget {
  final String texto;
  const _Subtitulo(this.texto);

  @override
  Widget build(BuildContext context) => Text(
        texto,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      );
}
