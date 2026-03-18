import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/password_strength_indicator.dart';
import '../../core/widgets/voice_input_field.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _nombreCtrl    = TextEditingController();
  final _correoCtrl    = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  bool  _aceptoPolitica = false;
  bool  _verPass        = false;
  bool  _verConfirm     = false;
  String _passActual    = '';

  // Modo de entrada: correo o celular
  bool _usandoCelular = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegistrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_aceptoPolitica) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar la política de privacidad.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final vm = context.read<AuthViewModel>();
    await vm.registrar(
      nombreCompleto: _nombreCtrl.text.trim(),
      correoOTelefono: _correoCtrl.text.trim(),
      contrasena: _passCtrl.text,
      aceptoPolitica: _aceptoPolitica,
    );
    if (!mounted) return;
    if (vm.state == AuthState.registroExitoso) {
      context.go('/completar-perfil');
    }
  }

  void _mostrarPolitica() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Política de privacidad'),
        content: const SingleChildScrollView(
          child: Text(
            'Tus datos personales serán tratados conforme a la Ley 1581 de 2012 '
            'y el Decreto 1377 de 2013. Solo se usarán para conectarte con '
            'oportunidades laborales. Puedes consultarlos, actualizarlos o '
            'eliminarlos desde tu perfil en cualquier momento.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text('¡Bienvenido/a!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  'Crea tu cuenta para encontrar trabajo.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 28),

                // ── Nombre completo — CON VOZ ──────────────────────────
                VoiceInputField(
                  controller: _nombreCtrl,
                  labelText: 'Nombre completo',
                  hintText: 'Di tu nombre o escríbelo',
                  validator: Validators.nombreCompleto,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // ── Selector: correo o celular ─────────────────────────
                Row(
                  children: [
                    const Text('Ingresa con:',
                        style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Correo'),
                      selected: !_usandoCelular,
                      onSelected: (_) {
                        setState(() { _usandoCelular = false; _correoCtrl.clear(); });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Celular'),
                      selected: _usandoCelular,
                      onSelected: (_) {
                        setState(() { _usandoCelular = true; _correoCtrl.clear(); });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Correo (sin voz — texto técnico) ─────────────────────
                if (!_usandoCelular)
                  TextFormField(
                    controller: _correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'Ej: tucorreo@gmail.com',
                    ),
                    validator: Validators.correoOTelefono,
                  ),

                // ── Celular — CON VOZ (dictar números es natural) ────────
                if (_usandoCelular)
                  VoiceInputField(
                    controller: _correoCtrl,
                    labelText: 'Número de celular',
                    hintText: 'Di tu número o escríbelo',
                    keyboardType: TextInputType.phone,
                    validator: Validators.correoOTelefono,
                    textCapitalization: TextCapitalization.none,
                  ),

                const SizedBox(height: 16),

                // ── Contraseña — SIN VOZ (seguridad) ─────────────────────
                TextFormField(
                  controller: _passCtrl,
                  obscureText: !_verPass,
                  onChanged: (v) => setState(() => _passActual = v),
                  decoration: InputDecoration(
                    labelText: AppStrings.passLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: 'Mín. 8 caracteres, 1 mayúscula, 1 número',
                    suffixIcon: IconButton(
                      icon: Icon(_verPass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _verPass = !_verPass),
                      tooltip: _verPass ? 'Ocultar' : 'Ver contraseña',
                    ),
                  ),
                  validator: Validators.contrasena,
                ),
                PasswordStrengthIndicator(password: _passActual),
                const SizedBox(height: 16),

                // ── Confirmar contraseña — SIN VOZ (seguridad) ───────────
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: !_verConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_verConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _verConfirm = !_verConfirm),
                    ),
                  ),
                  validator: Validators.confirmarContrasena(_passCtrl.text),
                ),
                const SizedBox(height: 24),

                // ── Política de privacidad ────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _aceptoPolitica,
                      onChanged: (v) =>
                          setState(() => _aceptoPolitica = v ?? false),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _mostrarPolitica,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: RichText(
                            text: TextSpan(
                              text: 'He leído y acepto la ',
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: const [
                                TextSpan(
                                  text: 'política de privacidad',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Color(0xFF1565C0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Error del ViewModel ───────────────────────────────────
                if (vm.state == AuthState.error)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFFB00020), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vm.errorMsg ?? '',
                            style: const TextStyle(
                                color: Color(0xFFB00020), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // ── Botón crear cuenta ────────────────────────────────────
                ElevatedButton(
                  onPressed: (_aceptoPolitica &&
                          vm.state != AuthState.loading)
                      ? _onRegistrar
                      : null,
                  child: vm.state == AuthState.loading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Crear cuenta'),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(AppStrings.yaRegistrado),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
