import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

const kAuthBg1    = Color(0xFF0F2027);
const kAuthBg2    = Color(0xFF203A43);
const kAuthBg3    = Color(0xFF2C5364);
const kAuthAccent = Color(0xFF1DE9B6); // teal/mint
const kAuthBlue   = Color(0xFF1976D2);

// ── Fondo con gradiente + círculos decorativos ──────────────────────────────
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAuthBg1,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kAuthBg1, kAuthBg2, kAuthBg3],
              ),
            ),
          ),
          Positioned(top: -60, right: -60,
              child: _Circle(220, Colors.white.withOpacity(0.05))),
          Positioned(top: 90, right: 50,
              child: _Circle(90, Colors.white.withOpacity(0.04))),
          Positioned(bottom: -80, left: -40,
              child: _Circle(260, kAuthAccent.withOpacity(0.07))),
          Positioned(bottom: 130, right: -30,
              child: _Circle(150, kAuthBlue.withOpacity(0.06))),
          child,
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle(this.size, this.color);
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

// ── Campo de texto moderno ──────────────────────────────────────────────────
class ModernField extends StatelessWidget {
  const ModernField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.hintText,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle:
            TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
        hintStyle:
            TextStyle(color: Colors.white.withOpacity(0.28), fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: _border(Colors.white.withOpacity(0.12)),
        enabledBorder: _border(Colors.white.withOpacity(0.12)),
        focusedBorder: _border(kAuthAccent, width: 1.5),
        errorBorder: _border(const Color(0xFFFF6B6B), width: 1.5),
        focusedErrorBorder: _border(const Color(0xFFFF6B6B), width: 1.5),
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1.0}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
}

// ── Botón con gradiente ─────────────────────────────────────────────────────
class GradientButton extends StatelessWidget {
  const GradientButton({super.key, required this.child, this.onPressed});
  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 200),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: enabled
              ? const LinearGradient(
                  colors: [kAuthAccent, kAuthBlue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade700, Colors.grey.shade800]),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: kAuthAccent.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  )
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Center(
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Banner de error ─────────────────────────────────────────────────────────
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B6B).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFFF6B6B), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: Color(0xFFFF6B6B), fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Campo moderno CON botón de voz ──────────────────────────────────────────
class ModernVoiceField extends StatefulWidget {
  const ModernVoiceField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.hintText,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final String? hintText;
  final TextCapitalization textCapitalization;

  @override
  State<ModernVoiceField> createState() => _ModernVoiceFieldState();
}

class _ModernVoiceFieldState extends State<ModernVoiceField>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _escuchando = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
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
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        labelStyle:
            TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
        hintStyle:
            TextStyle(color: Colors.white.withOpacity(0.28), fontSize: 14),
        prefixIcon: Icon(widget.icon, color: Colors.white54, size: 20),

        // ── Botón micrófono animado ─────────────────────────────────────
        suffixIcon: GestureDetector(
          onTap: _toggleVoz,
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _escuchando
                ? ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kAuthAccent.withOpacity(0.2),
                        border: Border.all(
                            color: kAuthAccent.withOpacity(0.6), width: 1.5),
                      ),
                      child: const Icon(Icons.mic_rounded,
                          color: kAuthAccent, size: 20),
                    ),
                  )
                : Icon(Icons.mic_none_rounded,
                    color: Colors.white38, size: 22),
          ),
        ),

        filled: true,
        fillColor: _escuchando
            ? kAuthAccent.withOpacity(0.05)
            : Colors.white.withOpacity(0.07),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: _border(_escuchando
            ? kAuthAccent.withOpacity(0.5)
            : Colors.white.withOpacity(0.12)),
        enabledBorder: _border(_escuchando
            ? kAuthAccent.withOpacity(0.5)
            : Colors.white.withOpacity(0.12)),
        focusedBorder: _border(kAuthAccent, width: 1.5),
        errorBorder: _border(const Color(0xFFFF6B6B), width: 1.5),
        focusedErrorBorder: _border(const Color(0xFFFF6B6B), width: 1.5),
        errorStyle:
            const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1.0}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
}