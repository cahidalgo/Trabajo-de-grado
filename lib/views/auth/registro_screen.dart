import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool _aceptoPolitica = false;
  bool _verPass        = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegistrar() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    await vm.registrar(
      correoOTelefono: _correoCtrl.text,
      contrasena: _passCtrl.text,
      aceptoPolitica: _aceptoPolitica,
    );
    if (!mounted) return;
    if (vm.state == AuthState.registroExitoso) {
      context.go('/onboarding');
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
                const SizedBox(height: 16),
                const Text('¡Bienvenido/a!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Crea tu cuenta para encontrar trabajo.', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 32),

                // Campo correo/celular
                TextFormField(
                  controller: _correoCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: AppStrings.correoLabel,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: Validators.correoOTelefono,
                ),
                const SizedBox(height: 16),

                // Campo contraseña
                TextFormField(
                  controller: _passCtrl,
                  obscureText: !_verPass,
                  decoration: InputDecoration(
                    labelText: AppStrings.passLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_verPass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _verPass = !_verPass),
                      tooltip: _verPass ? 'Ocultar contraseña' : 'Ver contraseña',
                    ),
                  ),
                  validator: Validators.contrasena,
                ),
                const SizedBox(height: 24),

                // Checkbox política de privacidad (RF12 — OBLIGATORIO)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _aceptoPolitica,
                      onChanged: (v) => setState(() => _aceptoPolitica = v ?? false),
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

                // Mensaje error
                if (vm.state == AuthState.error)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      vm.errorMsg ?? '',
                      style: const TextStyle(color: Color(0xFFB00020), fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 24),

                // Botón crear cuenta (deshabilitado si no acepta política)
                ElevatedButton(
                  onPressed: (_aceptoPolitica && vm.state != AuthState.loading) ? _onRegistrar : null,
                  child: vm.state == AuthState.loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(AppStrings.registro),
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
