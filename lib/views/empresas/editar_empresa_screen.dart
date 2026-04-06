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

class _EditarEmpresaScreenState
    extends State<EditarEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  bool _guardando = false;
  String? _fotoLocal;

  // ── Cambio de contraseña ────────────────────────────────────
  final _passActualCtrl = TextEditingController();
  final _passNuevaCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();
  bool _seccionPassAbierta = false;
  bool _verActual = false;
  bool _verNueva = false;
  bool _verConfirm = false;
  String _passNueva = '';

  // ── Seguridad contraseña ────────────────────────────────────
  int get _nivelSeguridad {
    int n = 0;
    if (_passNueva.length >= 8) n++;
    if (_passNueva.contains(RegExp(r'[A-Z]'))) n++;
    if (_passNueva.contains(RegExp(r'[0-9]'))) n++;
    if (_passNueva.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) n++;
    return n;
  }

  String get _textoSeguridad {
    switch (_nivelSeguridad) {
      case 0: case 1: return 'Muy débil';
      case 2: return 'Débil';
      case 3: return 'Aceptable';
      case 4: return 'Fuerte';
      default: return '';
    }
  }

  Color get _colorSeguridad {
    switch (_nivelSeguridad) {
      case 0: case 1: return AppColors.error;
      case 2: return const Color(0xFFFFA000);
      case 3: return const Color(0xFF66BB6A);
      case 4: return const Color(0xFF2E7D32);
      default: return Colors.transparent;
    }
  }

  @override
  void initState() {
    super.initState();
    final empresa = context.read<EmpresaViewModel>().empresaActual;
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
    _passActualCtrl.dispose();
    _passNuevaCtrl.dispose();
    _passConfirmCtrl.dispose();
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
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
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
    if (picked != null) setState(() => _fotoLocal = picked.path);
  }

  Future<String?> _validarCambioContrasena() async {
    if (_passNuevaCtrl.text.length < 8) {
      return 'La nueva contraseña debe tener mínimo 8 caracteres';
    }
    if (_passNuevaCtrl.text != _passConfirmCtrl.text) {
      return 'Las contraseñas no coinciden';
    }

    // Supabase Auth gestiona la autenticación — no hay contrasenaHash
    // local. Se actualiza directamente a través de la sesión activa.
    await context.read<EmpresaViewModel>()
        .actualizarContrasena(_passNuevaCtrl.text);
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    // ── 1. Cambio de contraseña (independiente) ───────────────
    if (_seccionPassAbierta &&
        (_passActualCtrl.text.isNotEmpty ||
            _passNuevaCtrl.text.isNotEmpty)) {
      final error = await _validarCambioContrasena();
      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error),
              backgroundColor: AppColors.error),
        );
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔐 Contraseña actualizada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        _passActualCtrl.clear();
        _passNuevaCtrl.clear();
        _passConfirmCtrl.clear();
        setState(() {
          _seccionPassAbierta = false;
          _passNueva = '';
        });
      }
    }

    // ── 2. Guardar datos de la empresa ────────────────────────
    setState(() => _guardando = true);
    final vm = context.read<EmpresaViewModel>();

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

    if (vm.errorMensaje == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Información actualizada correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMensaje ?? '❌ Error al guardar'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Guardar',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
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
              // ── Foto de perfil ───────────────────────────────
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
                                shape: BoxShape.circle),
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

              // ── Datos de la empresa ──────────────────────────
              const _Subtitulo('Datos de la empresa'),
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
                  labelText:
                      'Descripción de la empresa (opcional)',
                  hintText:
                      'Ej: Empresa de logística con 10 años de experiencia...',
                ),
              ),
              const SizedBox(height: 32),

              // ── Sección cambiar contraseña ───────────────────
              _SeccionContrasenaEmpresa(
                abierta: _seccionPassAbierta,
                onToggle: () => setState(() =>
                    _seccionPassAbierta = !_seccionPassAbierta),
                passActualCtrl: _passActualCtrl,
                passNuevaCtrl: _passNuevaCtrl,
                passConfirmCtrl: _passConfirmCtrl,
                verActual: _verActual,
                verNueva: _verNueva,
                verConfirm: _verConfirm,
                onToggleVerActual: () =>
                    setState(() => _verActual = !_verActual),
                onToggleVerNueva: () =>
                    setState(() => _verNueva = !_verNueva),
                onToggleVerConfirm: () =>
                    setState(() => _verConfirm = !_verConfirm),
                passNueva: _passNueva,
                nivelSeguridad: _nivelSeguridad,
                textoSeguridad: _textoSeguridad,
                colorSeguridad: _colorSeguridad,
                onPassNuevaChanged: (v) =>
                    setState(() => _passNueva = v),
              ),
              const SizedBox(height: 32),

              // ── Botón guardar ────────────────────────────────
              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18, height: 18,
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

// ── Sección colapsable contraseña empresa ────────────────────────────────────
class _SeccionContrasenaEmpresa extends StatelessWidget {
  final bool abierta;
  final VoidCallback onToggle;
  final TextEditingController passActualCtrl;
  final TextEditingController passNuevaCtrl;
  final TextEditingController passConfirmCtrl;
  final bool verActual;
  final bool verNueva;
  final bool verConfirm;
  final VoidCallback onToggleVerActual;
  final VoidCallback onToggleVerNueva;
  final VoidCallback onToggleVerConfirm;
  final String passNueva;
  final int nivelSeguridad;
  final String textoSeguridad;
  final Color colorSeguridad;
  final ValueChanged<String> onPassNuevaChanged;

  const _SeccionContrasenaEmpresa({
    required this.abierta,
    required this.onToggle,
    required this.passActualCtrl,
    required this.passNuevaCtrl,
    required this.passConfirmCtrl,
    required this.verActual,
    required this.verNueva,
    required this.verConfirm,
    required this.onToggleVerActual,
    required this.onToggleVerNueva,
    required this.onToggleVerConfirm,
    required this.passNueva,
    required this.nivelSeguridad,
    required this.textoSeguridad,
    required this.colorSeguridad,
    required this.onPassNuevaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: abierta
                  ? AppColors.primaryLight
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: abierta
                    ? AppColors.primary.withOpacity(0.4)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline,
                    color: abierta
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cambiar contraseña',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: abierta
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  abierta
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (abierta) ...[
          const SizedBox(height: 16),
          _CampoPass(
            controller: passNuevaCtrl,
            label: 'Nueva contraseña',
            hint: 'Mín. 8 caracteres, 1 mayúscula, 1 número',
            ver: verNueva,
            onToggleVer: onToggleVerNueva,
            onChanged: onPassNuevaChanged,
          ),
          if (passNueva.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: List.generate(4, (i) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i < nivelSeguridad
                        ? colorSeguridad
                        : const Color(0xFFE0E0E0),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 6),
            Text(
              'Seguridad: $textoSeguridad',
              style: TextStyle(
                  fontSize: 12,
                  color: colorSeguridad,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            _Requisito(
                cumplido: passNueva.length >= 8,
                texto: 'Mínimo 8 caracteres'),
            _Requisito(
                cumplido: passNueva.contains(RegExp(r'[A-Z]')),
                texto: 'Al menos una mayúscula'),
            _Requisito(
                cumplido: passNueva.contains(RegExp(r'[0-9]')),
                texto: 'Al menos un número'),
            _Requisito(
                cumplido: passNueva.contains(
                    RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]')),
                texto: 'Al menos un carácter especial'),
          ],
          const SizedBox(height: 12),
          _CampoPass(
            controller: passConfirmCtrl,
            label: 'Confirmar nueva contraseña',
            hint: 'Repite la nueva contraseña',
            ver: verConfirm,
            onToggleVer: onToggleVerConfirm,
          ),
        ],
      ],
    );
  }
}

class _CampoPass extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool ver;
  final VoidCallback onToggleVer;
  final ValueChanged<String>? onChanged;

  const _CampoPass({
    required this.controller,
    required this.label,
    required this.hint,
    required this.ver,
    required this.onToggleVer,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !ver,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            ver
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: onToggleVer,
        ),
      ),
    );
  }
}

class _Requisito extends StatelessWidget {
  final bool cumplido;
  final String texto;
  const _Requisito({required this.cumplido, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(
            cumplido
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked,
            size: 14,
            color: cumplido
                ? const Color(0xFF2E7D32)
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              color: cumplido
                  ? const Color(0xFF2E7D32)
                  : AppColors.textSecondary,
            ),
          ),
        ],
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
