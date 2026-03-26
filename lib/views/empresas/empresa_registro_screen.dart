import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/empresa_viewmodel.dart';

class EmpresaRegistroScreen extends StatefulWidget {
  const EmpresaRegistroScreen({super.key});
  @override
  State<EmpresaRegistroScreen> createState() => _EmpresaRegistroScreenState();
}

class _EmpresaRegistroScreenState extends State<EmpresaRegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _razonSocialCtrl = TextEditingController();
  final _nitCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  String _sectorSeleccionado = 'Ventas y comercio';

  final List<String> _sectores = [
    'Ventas y comercio', 'Logística', 'Gastronomía',
    'Servicios', 'Administrativo', 'Tecnología', 'Otro'
  ];

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
          child: Column(children: [
            const Text('Datos de la empresa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _campo(_razonSocialCtrl, 'Razón social', 'Ingresa la razón social'),
            const SizedBox(height: 12),
            _campo(_nitCtrl, 'NIT', 'Ej: 900123456-1',
                teclado: TextInputType.number),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _sectorSeleccionado,
              decoration: const InputDecoration(labelText: 'Sector'),
              items: _sectores
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _sectorSeleccionado = v!),
            ),
            const SizedBox(height: 12),
            _campo(_correoCtrl, 'Correo electrónico', 'empresa@correo.com',
                teclado: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _campo(_telefonoCtrl, 'Teléfono (opcional)', '',
                requerido: false, teclado: TextInputType.phone),
            const SizedBox(height: 12),
            _campo(_contrasenaCtrl, 'Contraseña', 'Mínimo 6 caracteres',
                obscure: true, minLen: 6),
            const SizedBox(height: 8),
            if (vm.errorMensaje != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(vm.errorMensaje!,
                    style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.cargando ? null : _registrar,
                child: vm.cargando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Crear cuenta'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('¿Ya tienes cuenta? ',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Text(
                    'Inicia sesión',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController ctrl, String label, String hint, {
    bool obscure = false,
    bool requerido = true,
    TextInputType teclado = TextInputType.text,
    int minLen = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: teclado,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: requerido
          ? (v) {
              if (v == null || v.trim().isEmpty) return 'Este campo es obligatorio';
              if (v.trim().length < minLen) return 'Mínimo $minLen caracteres';
              return null;
            }
          : null,
    );
  }

  Future<void> _registrar() async {
  if (!_formKey.currentState!.validate()) return;
  final vm = context.read<EmpresaViewModel>();
  try {
    final ok = await vm.registrar(
      razonSocial: _razonSocialCtrl.text.trim(),
      nit: _nitCtrl.text.trim(),
      sector: _sectorSeleccionado,
      correo: _correoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      contrasena: _contrasenaCtrl.text,
    );
    if (ok && mounted) {
      context.go('/empresa/dashboard');
    }
  } catch (e, stack) {
    debugPrint('ERROR REGISTRO EMPRESA: $e');
    debugPrint('STACK: $stack');
  }
}

}
