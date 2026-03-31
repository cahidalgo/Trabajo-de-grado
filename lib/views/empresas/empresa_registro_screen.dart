import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_ui.dart';
import '../../viewmodels/empresa_viewmodel.dart';

class EmpresaRegistroScreen extends StatefulWidget {
  const EmpresaRegistroScreen({super.key});

  @override
  State<EmpresaRegistroScreen> createState() =>
      _EmpresaRegistroScreenState();
}

class _EmpresaRegistroScreenState extends State<EmpresaRegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _razonSocialCtrl = TextEditingController();
  final _nitCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();

  String _sectorSeleccionado = 'Ventas y comercio';
  bool _verContrasena = false;
  String _contrasena = '';

  final List<String> _sectores = [
    'Ventas y comercio',
    'Logística',
    'Gastronomía',
    'Servicios',
    'Administrativo',
    'Tecnología',
    'Otro',
  ];

  // ── Evaluación de seguridad ──────────────────────────────────
  int get _nivelSeguridad {
    int nivel = 0;
    if (_contrasena.length >= 8) nivel++;
    if (_contrasena.contains(RegExp(r'[A-Z]'))) nivel++;
    if (_contrasena.contains(RegExp(r'[0-9]'))) nivel++;
    if (_contrasena.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) nivel++;
    return nivel;
  }

  String get _textoSeguridad {
    switch (_nivelSeguridad) {
      case 0:
      case 1:
        return 'Muy débil';
      case 2:
        return 'Débil';
      case 3:
        return 'Aceptable';
      case 4:
        return 'Fuerte';
      default:
        return '';
    }
  }

  Color get _colorSeguridad {
    switch (_nivelSeguridad) {
      case 0:
      case 1:
        return AppColors.error;
      case 2:
        return const Color(0xFFFFA000);
      case 3:
        return const Color(0xFF66BB6A);
      case 4:
        return const Color(0xFF2E7D32);
      default:
        return Colors.transparent;
    }
  }

  @override
  void dispose() {
    _razonSocialCtrl.dispose();
    _nitCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmpresaViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/login'),
        ),
        title: const Text('Registro de empresa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageIntro(
                title: 'Crea tu cuenta empresarial',
                subtitle:
                    'Registra los datos básicos de la empresa para publicar vacantes y gestionar postulaciones desde un mismo panel.',
                icon: Icons.business_center_outlined,
              ),
              const SizedBox(height: 16),
              const AppSectionTitle(
                title: 'Datos de la empresa',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 10),
              AppSurfaceCard(
                child: Column(
                  children: [
                    _campo(_razonSocialCtrl, 'Razón social',
                        'Ingresa la razón social'),
                    const SizedBox(height: 12),
                    _campo(_nitCtrl, 'NIT', 'Ej: 900123456-1',
                        teclado: TextInputType.number),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _sectorSeleccionado,
                      decoration:
                          const InputDecoration(labelText: 'Sector'),
                      items: _sectores
                          .map((s) => DropdownMenuItem(
                              value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _sectorSeleccionado = v!),
                    ),
                    const SizedBox(height: 12),
                    _campo(_correoCtrl, 'Correo electrónico',
                        'empresa@correo.com',
                        teclado: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    _campo(_telefonoCtrl, 'Teléfono (opcional)', '',
                        requerido: false,
                        teclado: TextInputType.phone),
                    const SizedBox(height: 12),

                    // ── Campo contraseña con ojo ─────────────────
                    TextFormField(
                      controller: _contrasenaCtrl,
                      obscureText: !_verContrasena,
                      onChanged: (v) =>
                          setState(() => _contrasena = v),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Mínimo 8 caracteres',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _verContrasena
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(
                              () => _verContrasena = !_verContrasena),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        if (v.length < 8) {
                          return 'Mínimo 8 caracteres';
                        }
                        if (!v.contains(RegExp(r'[A-Z]'))) {
                          return 'Debe tener al menos una mayúscula';
                        }
                        if (!v.contains(RegExp(r'[0-9]'))) {
                          return 'Debe tener al menos un número';
                        }
                        if (!v.contains(RegExp(
                            r'[!@#\$%^&*(),.?":{}|<>_\-]'))) {
                          return 'Debe tener al menos un carácter especial';
                        }
                        return null;
                      },
                    ),

                    // ── Barra de seguridad ───────────────────────
                    if (_contrasena.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(4, (i) {
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                  right: i < 3 ? 4 : 0),
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(4),
                                color: i < _nivelSeguridad
                                    ? _colorSeguridad
                                    : const Color(0xFFE0E0E0),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'Seguridad: $_textoSeguridad',
                            style: TextStyle(
                              fontSize: 12,
                              color: _colorSeguridad,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Requisitos
                      _RequisitoContrasena(
                        cumplido: _contrasena.length >= 8,
                        texto: 'Mínimo 8 caracteres',
                      ),
                      _RequisitoContrasena(
                        cumplido: _contrasena
                            .contains(RegExp(r'[A-Z]')),
                        texto: 'Al menos una mayúscula',
                      ),
                      _RequisitoContrasena(
                        cumplido: _contrasena
                            .contains(RegExp(r'[0-9]')),
                        texto: 'Al menos un número',
                      ),
                      _RequisitoContrasena(
                        cumplido: _contrasena.contains(RegExp(
                            r'[!@#\$%^&*(),.?":{}|<>_\-]')),
                        texto: 'Al menos un carácter especial',
                      ),
                    ],
                  ],
                ),
              ),

              if (vm.errorMensaje != null) ...[
                const SizedBox(height: 16),
                AppInfoBanner(
                  title: 'No pudimos crear la cuenta',
                  description: vm.errorMensaje!,
                  icon: Icons.error_outline,
                  color: AppColors.error,
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.cargando ? null : _registrar,
                  child: vm.cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Crear cuenta'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      '¿Ya tienes cuenta? ',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String label,
    String hint, {
    bool requerido = true,
    TextInputType teclado = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: requerido
          ? (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            }
          : null,
    );
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<EmpresaViewModel>();
    final ok = await vm.registrar(
      razonSocial: _razonSocialCtrl.text.trim(),
      nit: _nitCtrl.text.trim(),
      sector: _sectorSeleccionado,
      correo: _correoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      contrasena: _contrasenaCtrl.text,
    );
    if (ok && mounted) context.go('/empresa/dashboard');
  }
}

// ── Widget requisito ──────────────────────────────────────────────────────────
class _RequisitoContrasena extends StatelessWidget {
  final bool cumplido;
  final String texto;
  const _RequisitoContrasena(
      {required this.cumplido, required this.texto});

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
