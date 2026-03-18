import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../constants/app_colors.dart';

class VoiceInputField extends StatefulWidget {
  final TextEditingController controller;
  final String                 labelText;
  final String                 hintText;
  final String? Function(String?)? validator;
  final int                    maxLines;
  final TextInputType?         keyboardType;
  final TextCapitalization     textCapitalization;

  const VoiceInputField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.validator,
    this.maxLines          = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
  });

  @override
  State<VoiceInputField> createState() => _VoiceInputFieldState();
}

class _VoiceInputFieldState extends State<VoiceInputField>
    with SingleTickerProviderStateMixin {
  final SpeechToText _stt        = SpeechToText();
  bool               _escuchando = false;
  bool               _disponible = false;

  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _init();
  }

  Future<void> _init() async {
    _disponible = await _stt.initialize(
      onError: (_) => setState(() => _escuchando = false),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _stt.stop();
    super.dispose();
  }

  Future<void> _toggleVoz() async {
    if (!_disponible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El micrófono no está disponible en este dispositivo.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_escuchando) {
      await _stt.stop();
      setState(() => _escuchando = false);
      return;
    }

    // Pide permiso y arranca escucha
    setState(() => _escuchando = true);
    await _stt.listen(
      localeId: 'es_CO',
      onResult: (result) {
        // Actualiza el campo mientras habla (en tiempo real)
        widget.controller.text = result.recognizedWords;
        if (result.finalResult) {
          setState(() => _escuchando = false);
        }
      },
      listenFor: const Duration(seconds: 45),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          decoration: InputDecoration(
            labelText: widget.labelText,
            alignLabelWithHint: widget.maxLines > 1,
            hintText: _escuchando ? null : widget.hintText,
            // Borde rojo cuando está escuchando
            enabledBorder: _escuchando
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  )
                : null,
            focusedBorder: _escuchando
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  )
                : null,
            // Botón de micrófono como sufijo
            suffixIcon: _disponible
                ? ScaleTransition(
                    scale: _escuchando ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
                    child: IconButton(
                      icon: Icon(
                        _escuchando ? Icons.mic : Icons.mic_none_outlined,
                        color: _escuchando ? Colors.red : AppColors.primary,
                      ),
                      tooltip: _escuchando ? 'Toca para detener' : 'Dictar con voz',
                      onPressed: _toggleVoz,
                    ),
                  )
                : null,
          ),
        ),
        // Indicador textual de escucha
        if (_escuchando)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const SizedBox(
                  width: 12, height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Escuchando... habla ahora',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _toggleVoz,
                  child: const Text(
                    'Detener',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
