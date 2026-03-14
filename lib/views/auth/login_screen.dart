import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool _verPass     = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    await vm.iniciarSesion(
      correoOTelefono: _correoCtrl.text,
      contrasena: _passCtrl.text,
    );
    if (!mounted) return;
    if (vm.state == AuthState.loginExitoso) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Text('¡Hola de nuevo!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Ingresa tus datos para continuar.', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 32),

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

                TextFormField(
                  controller: _passCtrl,
                  obscureText: !_verPass,
                  decoration: InputDecoration(
                    labelText: AppStrings.passLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_verPass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _verPass = !_verPass),
                    ),
                  ),
                  validator: Validators.contrasena,
                ),

                if (vm.state == AuthState.error)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      vm.errorMsg ?? '',
                      style: const TextStyle(color: Color(0xFFB00020), fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: vm.state != AuthState.loading ? _onLogin : null,
                  child: vm.state == AuthState.loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(AppStrings.login),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => context.go('/registro'),
                  child: const Text(AppStrings.sinCuenta),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
