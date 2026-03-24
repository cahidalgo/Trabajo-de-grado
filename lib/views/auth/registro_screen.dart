import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/password_strength_indicator.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _aceptoPolitica = false;
  bool _politicaError = false;
  bool _verPass = false;
  bool _verConfirm = false;
  String _passActual = '';
  bool _usandoCelular = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegistrar() async {
    final formValido = _formKey.currentState!.validate();
    if (!_aceptoPolitica) setState(() => _politicaError = true);
    if (!formValido || !_aceptoPolitica) return;

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
        title: const Row(
          children: [
            Icon(Icons.privacy_tip_outlined,
                color: AppColors.primary, size: 22),
            SizedBox(width: 10),
            Text(
              'Política de privacidad',
              style: TextStyle(fontSize: 17),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Aviso de privacidad: Al registrarte, autorizas el tratamiento '
            'de tus datos personales para crear tu perfil, permitir '
            'postulaciones a vacantes, hacer seguimiento de oportunidades '
            'laborales y mejorar el funcionamiento de la aplicación ',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _aceptoPolitica = true;
                _politicaError = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final cargando = vm.state == AuthState.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/login'),
        ),
        title: const Text('Crear cuenta'),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Subtítulo ─────────────────────────────────────────
                const Text(
                  'Crea tu cuenta para encontrar trabajo.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Error global ──────────────────────────────────────
                if (vm.state == AuthState.error) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vm.errorMsg ?? 'Error al crear la cuenta',
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Nombre completo ───────────────────────────────────
                const _FieldLabel('Nombre completo'),
                const SizedBox(height: 8),
                _VoiceField(
                  controller: _nombreCtrl,
                  hintText: 'Di tu nombre o escríbelo',
                  prefixIcon: Icons.badge_outlined,
                  validator: Validators.nombreCompleto,
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 20),

                // ── Toggle correo / celular ────────────────────────────
                _ContactToggle(
                  usandoCelular: _usandoCelular,
                  onChanged: (v) => setState(() {
                    _usandoCelular = v;
                    _correoCtrl.clear();
                  }),
                ),
                const SizedBox(height: 12),

                // ── Campo dinámico correo / celular ───────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _usandoCelular
                      ? _VoiceField(
                          key: const ValueKey('cel'),
                          controller: _correoCtrl,
                          hintText: 'Ej: 3001234567',
                          prefixIcon: Icons.phone_android_outlined,
                          keyboardType: TextInputType.phone,
                          validator: Validators.correoOTelefono,
                        )
                      : TextFormField(
                          key: const ValueKey('mail'),
                          controller: _correoCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Ej: tucorreo@gmail.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: Validators.correoOTelefono,
                        ),
                ),

                const SizedBox(height: 20),

                // ── Contraseña ────────────────────────────────────────
                const _FieldLabel(AppStrings.passLabel),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: !_verPass,
                  onChanged: (v) => setState(() => _passActual = v),
                  decoration: InputDecoration(
                    hintText: 'Mín. 8 caracteres, 1 mayúscula, 1 número',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _verPass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _verPass = !_verPass),
                    ),
                  ),
                  validator: Validators.contrasena,
                ),
                const SizedBox(height: 8),
                PasswordStrengthIndicator(password: _passActual),

                const SizedBox(height: 20),

                // ── Confirmar contraseña ──────────────────────────────
                const _FieldLabel('Confirmar contraseña'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: !_verConfirm,
                  decoration: InputDecoration(
                    hintText: 'Repite tu contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _verConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _verConfirm = !_verConfirm),
                    ),
                  ),
                  validator:
                      Validators.confirmarContrasena(_passCtrl.text),
                ),

                const SizedBox(height: 24),

                // ── Política de privacidad ────────────────────────────
                _PrivacyCheckbox(
                  value: _aceptoPolitica,
                  mostrarError: _politicaError,
                  onChanged: (v) => setState(() {
                    _aceptoPolitica = v ?? false;
                    if (_aceptoPolitica) _politicaError = false;
                  }),
                  onTapPolicy: _mostrarPolitica,
                ),

                const SizedBox(height: 28),

                // ── Botón crear cuenta ────────────────────────────────
                ElevatedButton(
                  onPressed: cargando ? null : _onRegistrar,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: cargando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Crear cuenta'),
                ),

                const SizedBox(height: 24),

                // ── Link a login ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Ya tienes cuenta? ',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
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

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Label de campo ───────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );
}

// ── Campo con voz (estilo de la app) ─────────────────────────────────────────
class _VoiceField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final TextCapitalization textCapitalization;

  const _VoiceField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<_VoiceField> createState() => _VoiceFieldState();
}

class _VoiceFieldState extends State<_VoiceField> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _escuchando = false;

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  Future<void> _toggleVoz() async {
    if (_escuchando) {
      await _speech.stop();
      setState(() => _escuchando = false);
      return;
    }
    final disponible = await _speech.initialize(
      onError: (_) => setState(() => _escuchando = false),
    );
    if (!disponible) return;
    setState(() => _escuchando = true);
    _speech.listen(
      localeId: 'es_CO',
      onResult: (result) {
        widget.controller.text = result.recognizedWords;
        if (result.finalResult) {
          setState(() => _escuchando = false);
          _speech.stop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      textCapitalization: widget.textCapitalization,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: Icon(widget.prefixIcon),
        suffixIcon: IconButton(
          tooltip: _escuchando ? 'Detener' : 'Dictar con voz',
          icon: Icon(
            _escuchando ? Icons.mic_rounded : Icons.mic_none_rounded,
            color:
                _escuchando ? AppColors.primary : AppColors.textSecondary,
            size: 22,
          ),
          onPressed: _toggleVoz,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: _escuchando
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: AppColors.primary, width: 1.5),
        ),
        fillColor: _escuchando
            ? AppColors.primaryLight
            : AppColors.background,
      ),
    );
  }
}

// ── Toggle correo / celular ───────────────────────────────────────────────────
class _ContactToggle extends StatelessWidget {
  final bool usandoCelular;
  final ValueChanged<bool> onChanged;
  const _ContactToggle(
      {required this.usandoCelular, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: '✉️  Correo',
            selected: !usandoCelular,
            onTap: () => onChanged(false),
          ),
          _ToggleOption(
            label: '📱  Celular',
            selected: usandoCelular,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleOption(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: selected
                ? Border.all(color: AppColors.border)
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Checkbox política de privacidad ──────────────────────────────────────────
class _PrivacyCheckbox extends StatelessWidget {
  final bool value;
  final bool mostrarError;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTapPolicy;

  const _PrivacyCheckbox({
    required this.value,
    required this.mostrarError,
    required this.onChanged,
    required this.onTapPolicy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: value ? AppColors.primaryLight : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: mostrarError
                    ? AppColors.error
                    : value
                        ? AppColors.primary
                        : AppColors.border,
                width: value ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color:
                        value ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: value
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      width: 1.5,
                    ),
                  ),
                  child: value
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 15)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'He leído y acepto la ',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: onTapPolicy,
                            child: const Text(
                              'política de privacidad',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (mostrarError)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Debes aceptar la política de privacidad para continuar',
              style: TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}