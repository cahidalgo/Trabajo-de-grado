import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/voice_input_field.dart';
import '../../data/models/perfil.dart';
import '../../data/models/usuario.dart';
import '../../data/repositories/usuario_repository.dart';
import '../../viewmodels/perfil_viewmodel.dart';
import '../../core/widgets/avatar_perfil.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _experienciaCtrl = TextEditingController();
  final _habilidadesCtrl = TextEditingController();
  final _usuarioRepo = UsuarioRepository();

  bool _cargando = true;
  bool _guardando = false;
  int? _usuarioId;
  String? _nivelEducativo;
  String? _modalidadPreferida;
  String? _jornadaPreferida;
  final List<String> _areasSeleccionadas = [];

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
    'Primaria incompleta',
    'Primaria completa',
    'Bachillerato incompleto',
    'Bachillerato completo',
    'Técnico / Tecnólogo',
    'Universitario',
  ];
  static const _areas = [
    'Ventas', 'Gastronomía', 'Logística', 'Servicios',
    'Construcción', 'Aseo y limpieza', 'Vigilancia', 'Otro',
  ];
  static const _modalidades = ['Presencial', 'Virtual', 'Híbrida'];
  static const _jornadas = ['Tiempo completo', 'Medio tiempo', 'Por horas'];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    _usuarioId = prefs.getInt('usuarioId');
    if (_usuarioId == null) return;

    final usuario = await _usuarioRepo.obtenerPorId(_usuarioId!);
    final perfil = context.read<PerfilViewModel>().perfil ??
        await _cargarPerfilDirecto(_usuarioId!);

    _nombreCtrl.text = usuario?.nombreCompleto ?? '';
    _experienciaCtrl.text = perfil?.experienciaLaboral ?? '';
    _habilidadesCtrl.text = perfil?.habilidades ?? '';
    _nivelEducativo = perfil?.nivelEducativo;
    _modalidadPreferida = perfil?.modalidadPreferida;
    _jornadaPreferida = perfil?.jornadaPreferida;

    final areas = perfil?.areasInteres ?? '';
    if (areas.isNotEmpty) {
      _areasSeleccionadas.addAll(
        areas.split(',').map((a) => a.trim()).where((a) => a.isNotEmpty),
      );
    }

    setState(() => _cargando = false);
  }

  Future<Perfil?> _cargarPerfilDirecto(int usuarioId) async {
    await context.read<PerfilViewModel>().cargar(usuarioId);
    return context.read<PerfilViewModel>().perfil;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    if (_usuarioId != null && _nombreCtrl.text.trim().isNotEmpty) {
      await _usuarioRepo.actualizarNombre(_usuarioId!, _nombreCtrl.text.trim());
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

    if (!mounted) return;
    await context.read<PerfilViewModel>().guardar(perfil);
    setState(() => _guardando = false);

    if (!mounted) return;
    if (context.read<PerfilViewModel>().state == PerfilState.guardado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _experienciaCtrl.dispose();
    _habilidadesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        actions: [
          TextButton(
            onPressed: _guardando ? null : _guardar,
            child: _guardando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Guardar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
              // ── Avatar ────────────────────────────────────────────────
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
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Datos personales ──────────────────────────────────────
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

              // ── Nivel educativo ───────────────────────────────────────
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

              // ── Experiencia y habilidades ─────────────────────────────
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
                hintText: 'Ej: Atención al cliente, manejo de dinero...',
                validator: Validators.textoLargo,
                maxLines: 3,
              ),

              const SizedBox(height: 28),

              // ── Áreas de interés ──────────────────────────────────────
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
                    onSelected: (v) => setState(
                      () => v
                          ? _areasSeleccionadas.add(area)
                          : _areasSeleccionadas.remove(area),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // ── Modalidad preferida ───────────────────────────────────
              const _Subtitulo('Modalidad preferida'),
              const SizedBox(height: 12),
              ..._modalidades.map(
                (m) => _OpcionSeleccionable(
                  label: m,
                  seleccionado: _modalidadPreferida == m,
                  onTap: () => setState(() => _modalidadPreferida = m),
                ),
              ),

              const SizedBox(height: 28),

              // ── Jornada preferida ─────────────────────────────────────
              const _Subtitulo('Jornada preferida'),
              const SizedBox(height: 12),
              ..._jornadas.map(
                (j) => _OpcionSeleccionable(
                  label: j,
                  seleccionado: _jornadaPreferida == j,
                  onTap: () => setState(() => _jornadaPreferida = j),
                ),
              ),

              const SizedBox(height: 32),

              // ── Botón guardar final ───────────────────────────────────
              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Guardar cambios'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  fontWeight:
                      seleccionado ? FontWeight.w600 : FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (seleccionado)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}