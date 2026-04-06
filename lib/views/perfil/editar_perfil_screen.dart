import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/voice_input_field.dart';
import '../../data/models/perfil.dart';
import '../../data/repositories/usuario_repository.dart';
import '../../viewmodels/perfil_viewmodel.dart';
import '../../core/widgets/avatar_perfil.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() =>
      _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _experienciaCtrl = TextEditingController();
  final _habilidadesCtrl = TextEditingController();
  final _usuarioRepo = UsuarioRepository();

  // ── Cambio de contraseña ────────────────────────────────────
  final _passActualCtrl = TextEditingController();
  final _passNuevaCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();
  bool _seccionPassAbierta = false;
  bool _verActual = false;
  bool _verNueva = false;
  bool _verConfirm = false;
  String _passNueva = '';

  bool _cargando = true;
  bool _guardando = false;
  int? _usuarioId;
  String? _nivelEducativo;
  String? _modalidadPreferida;
  String? _jornadaPreferida;
  final List<String> _areasSeleccionadas = [];

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

  String _iniciales() {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) return '?';
    final partes = nombre.split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre[0].toUpperCase();
  }

  static const _nivelesEducativos = [
    'Primaria incompleta', 'Primaria completa',
    'Bachillerato incompleto', 'Bachillerato completo',
    'Técnico / Tecnólogo', 'Universitario',
  ];
  static const _areas = [
    'Ventas', 'Gastronomía', 'Logística', 'Servicios',
    'Construcción', 'Aseo y limpieza', 'Vigilancia', 'Otro',
  ];
  static const _modalidades = ['Presencial', 'Virtual', 'Híbrida'];
  static const _jornadas = [
    'Tiempo completo', 'Medio tiempo', 'Por horas'
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    // Obtener usuarioId desde la sesión activa de Supabase
    final authId = SupabaseService.currentAuthId;
    if (authId == null) return;

    final data = await SupabaseService.client
        .from('usuarios')
        .select('id, nombre_completo')
        .eq('auth_id', authId)
        .maybeSingle();

    if (data == null) return;
    _usuarioId = data['id'] as int;

    final perfil = context.read<PerfilViewModel>().perfil ??
        await _cargarPerfilDirecto(_usuarioId!);

    _nombreCtrl.text = data['nombre_completo'] as String? ?? '';
    _experienciaCtrl.text = perfil?.experienciaLaboral ?? '';
    _habilidadesCtrl.text = perfil?.habilidades ?? '';
    _nivelEducativo = perfil?.nivelEducativo;
    _modalidadPreferida = perfil?.modalidadPreferida;
    _jornadaPreferida = perfil?.jornadaPreferida;

    final areas = perfil?.areasInteres ?? '';
    if (areas.isNotEmpty) {
      _areasSeleccionadas.addAll(
          areas.split(',').map((a) => a.trim()).where((a) => a.isNotEmpty));
    }
    setState(() => _cargando = false);
  }

  Future<Perfil?> _cargarPerfilDirecto(int usuarioId) async {
    await context.read<PerfilViewModel>().cargar(usuarioId);
    return context.read<PerfilViewModel>().perfil;
  }

  Future<void> _guardar() async {
  if (!_formKey.currentState!.validate()) return;

  // ── 1. Cambio de contraseña (independiente del perfil) ────
  if (_seccionPassAbierta &&
      (_passActualCtrl.text.isNotEmpty ||
          _passNuevaCtrl.text.isNotEmpty)) {
    final errorPass = await _cambiarContrasena();
    if (!mounted) return;

    if (errorPass != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(errorPass),
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

  // ── 2. Guardar perfil solo si hay usuarioId válido ────────
  if (_usuarioId == null) {
    Navigator.pop(context);
    return;
  }

  setState(() => _guardando = true);

  // Actualizar nombre
  if (_nombreCtrl.text.trim().isNotEmpty) {
    await _usuarioRepo.actualizarNombre(
        _usuarioId!, _nombreCtrl.text.trim());
  }

  final perfil = Perfil(
    usuarioId: _usuarioId!,
    nivelEducativo: _nivelEducativo,
    experienciaLaboral: _experienciaCtrl.text.trim(),
    habilidades: _habilidadesCtrl.text.trim(),
    areasInteres: _areasSeleccionadas.join(', '),
    modalidadPreferida: _modalidadPreferida,
    jornadaPreferida: _jornadaPreferida,
    perfilCompleto: _nivelEducativo != null &&
        _experienciaCtrl.text.trim().isNotEmpty &&
        _habilidadesCtrl.text.trim().isNotEmpty,
  );

  final vm = context.read<PerfilViewModel>();

  try {
    await vm.guardar(perfil);
    setState(() => _guardando = false);
    if (!mounted) return;

    // ✅ Siempre mostrar éxito si no lanzó excepción
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Perfil actualizado correctamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    vm.resetState();
    Navigator.pop(context);

  } catch (e) {
    setState(() => _guardando = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ Error al guardar el perfil. Intenta de nuevo.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Future<String?> _cambiarContrasena() async {
    if (_passNuevaCtrl.text.length < 8) {
      return 'La nueva contraseña debe tener mínimo 8 caracteres';
    }
    if (_passNuevaCtrl.text != _passConfirmCtrl.text) {
      return 'Las contraseñas no coinciden';
    }

    // Supabase Auth gestiona la autenticación — se actualiza
    // directamente a través de la sesión activa, sin hash local.
    await _usuarioRepo.actualizarContrasena(_passNuevaCtrl.text);
    return null;
  }

  // Eliminar _hash: ya no hay hashing manual con Supabase Auth

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _experienciaCtrl.dispose();
    _habilidadesCtrl.dispose();
    _passActualCtrl.dispose();
    _passNuevaCtrl.dispose();
    _passConfirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        actions: [
          TextButton(
            onPressed: _guardando ? null : _guardar,
            child: _guardando
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2))
                : const Text('Guardar',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
              // ── Avatar ──────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    AvatarPerfil(
                      iniciales: _iniciales(),
                      radius: 50,
                      editable: true,
                      onFotoCambiada: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toca el ícono para cambiar tu foto',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Datos personales ─────────────────────────────
              const _Subtitulo('Datos personales'),
              const SizedBox(height: 12),
              VoiceInputField(
                controller: _nombreCtrl,
                labelText: 'Nombre completo',
                hintText: 'Di tu nombre o escríbelo',
                validator: Validators.nombreCompleto,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 28),

              // ── Nivel educativo ──────────────────────────────
              const _Subtitulo('Nivel educativo'),
              const SizedBox(height: 12),
              ..._nivelesEducativos.map(
                (n) => _OpcionSeleccionable(
                  label: n,
                  seleccionado: _nivelEducativo == n,
                  onTap: () => setState(() => _nivelEducativo = n),
                ),
              ),
              const SizedBox(height: 28),

              // ── Experiencia y habilidades ────────────────────
              const _Subtitulo('Experiencia y habilidades'),
              const SizedBox(height: 12),
              VoiceInputField(
                controller: _experienciaCtrl,
                labelText: 'Experiencia laboral',
                hintText: 'Ej: Vendedor ambulante por 5 años...',
                validator: Validators.textoLargo,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              VoiceInputField(
                controller: _habilidadesCtrl,
                labelText: 'Habilidades',
                hintText:
                    'Ej: Atención al cliente, manejo de dinero...',
                validator: Validators.textoLargo,
                maxLines: 3,
              ),
              const SizedBox(height: 28),

              // ── Áreas de interés ─────────────────────────────
              const _Subtitulo('Áreas de interés'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _areas.map((area) {
                  final sel = _areasSeleccionadas.contains(area);
                  return FilterChip(
                    label: Text(area),
                    selected: sel,
                    onSelected: (v) => setState(() => v
                        ? _areasSeleccionadas.add(area)
                        : _areasSeleccionadas.remove(area)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // ── Modalidad preferida ──────────────────────────
              const _Subtitulo('Modalidad preferida'),
              const SizedBox(height: 12),
              ..._modalidades.map(
                (m) => _OpcionSeleccionable(
                  label: m,
                  seleccionado: _modalidadPreferida == m,
                  onTap: () =>
                      setState(() => _modalidadPreferida = m),
                ),
              ),
              const SizedBox(height: 28),

              // ── Jornada preferida ────────────────────────────
              const _Subtitulo('Jornada preferida'),
              const SizedBox(height: 12),
              ..._jornadas.map(
                (j) => _OpcionSeleccionable(
                  label: j,
                  seleccionado: _jornadaPreferida == j,
                  onTap: () =>
                      setState(() => _jornadaPreferida = j),
                ),
              ),
              const SizedBox(height: 32),

              // ── Sección cambiar contraseña ───────────────────
              _SeccionContrasena(
                abierta: _seccionPassAbierta,
                onToggle: () => setState(
                    () => _seccionPassAbierta = !_seccionPassAbierta),
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

// ── Sección colapsable de contraseña ─────────────────────────────────────────
class _SeccionContrasena extends StatelessWidget {
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

  const _SeccionContrasena({
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

// ── Widgets base ──────────────────────────────────────────────────────────────
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

class _OpcionSeleccionable extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;
  const _OpcionSeleccionable({
    required this.label,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionado ? AppColors.primary : AppColors.border,
            width: seleccionado ? 1.5 : 1,
          ),
          color: seleccionado ? AppColors.primaryLight : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: seleccionado
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (seleccionado)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
