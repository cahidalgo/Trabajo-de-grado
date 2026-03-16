import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/models/perfil.dart';
import '../../viewmodels/perfil_viewmodel.dart';

class CompletarPerfilScreen extends StatefulWidget {
  const CompletarPerfilScreen({super.key});

  @override
  State<CompletarPerfilScreen> createState() => _CompletarPerfilScreenState();
}

class _CompletarPerfilScreenState extends State<CompletarPerfilScreen> {
  // Una clave de formulario POR PASO
  final _formKey1 = GlobalKey<FormState>(); // Paso 1: Educación
  final _formKey2 = GlobalKey<FormState>(); // Paso 2: Experiencia
  final _formKey3 = GlobalKey<FormState>(); // Paso 3: Preferencias

  final _experienciaCtrl = TextEditingController();
  final _habilidadesCtrl = TextEditingController();

  int     _pasoActual         = 0;
  String? _nivelEducativo;
  bool    _nivelError         = false; // error manual paso 1
  final List<String> _areasSeleccionadas = [];
  String? _modalidadPreferida;
  String? _jornadaPreferida;

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
  static const _jornadas    = ['Tiempo completo', 'Medio tiempo', 'Por horas'];

  @override
  void dispose() {
    _experienciaCtrl.dispose();
    _habilidadesCtrl.dispose();
    super.dispose();
  }

  // Valida únicamente el paso actual
  bool _validarPasoActual() {
    switch (_pasoActual) {
      case 0:
        // Paso 1: validación manual del nivel educativo
        if (_nivelEducativo == null) {
          setState(() => _nivelError = true);
          return false;
        }
        setState(() => _nivelError = false);
        return true;
      case 1:
        // Paso 2: validación del Form de experiencia
        return _formKey2.currentState?.validate() ?? false;
      case 2:
        // Paso 3: sin campos obligatorios
        return true;
      default:
        return true;
    }
  }

  Future<void> _guardarYContinuar() async {
    if (!_validarPasoActual()) return;

    final prefs     = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuarioId');
    if (usuarioId == null) return;

    final perfil = Perfil(
      usuarioId: usuarioId,
      nivelEducativo: _nivelEducativo,
      experienciaLaboral: _experienciaCtrl.text.trim(),
      habilidades: _habilidadesCtrl.text.trim(),
      areasInteres: _areasSeleccionadas.join(', '),
      modalidadPreferida: _modalidadPreferida,
      jornadaPreferida: _jornadaPreferida,
      perfilCompleto: true,
    );

    if (!mounted) return;
    await context.read<PerfilViewModel>().guardar(perfil);
    if (!mounted) return;
    if (context.read<PerfilViewModel>().state == PerfilState.guardado) {
      context.go('/onboarding');
    }
  }

  void _siguiente() {
    if (!_validarPasoActual()) return;
    setState(() => _pasoActual++);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PerfilViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completa tu perfil'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.go('/onboarding'),
            child: const Text('Omitir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de progreso
          LinearProgressIndicator(
            value: (_pasoActual + 1) / 3,
            backgroundColor: const Color(0xFFE3F2FD),
            color: AppColors.primary,
            minHeight: 6,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paso ${_pasoActual + 1} de 3',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                Text(['Educación', 'Experiencia', 'Preferencias'][_pasoActual],
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1),

          // Contenido del paso actual (NO IndexedStack — cambia el widget real)
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildPasoActual(),
            ),
          ),

          // Botones de navegación
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (vm.state == PerfilState.error)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(vm.errorMsg ?? '',
                        style: const TextStyle(color: Color(0xFFB00020))),
                  ),
                Row(
                  children: [
                    if (_pasoActual > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _pasoActual--),
                          child: const Text('Atrás'),
                        ),
                      ),
                    if (_pasoActual > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: vm.state == PerfilState.loading
                            ? null
                            : (_pasoActual < 2 ? _siguiente : _guardarYContinuar),
                        child: vm.state == PerfilState.loading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text(_pasoActual < 2 ? 'Siguiente' : 'Guardar perfil'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasoActual() {
    switch (_pasoActual) {
      case 0: return _Paso1Educacion(
          key: const ValueKey('paso1'),
          niveles: _nivelesEducativos,
          seleccionado: _nivelEducativo,
          mostrarError: _nivelError,
          onSeleccionar: (v) => setState(() {
            _nivelEducativo = v;
            _nivelError     = false;
          }),
        );
      case 1: return _Paso2Experiencia(
          key: const ValueKey('paso2'),
          formKey: _formKey2,
          experienciaCtrl: _experienciaCtrl,
          habilidadesCtrl: _habilidadesCtrl,
        );
      case 2: return _Paso3Preferencias(
          key: const ValueKey('paso3'),
          areas: _areas,
          areasSeleccionadas: _areasSeleccionadas,
          modalidades: _modalidades,
          jornadas: _jornadas,
          modalidadSeleccionada: _modalidadPreferida,
          jornadaSeleccionada: _jornadaPreferida,
          onToggleArea: (area, v) => setState(() => v
              ? _areasSeleccionadas.add(area)
              : _areasSeleccionadas.remove(area)),
          onModalidad: (v) => setState(() => _modalidadPreferida = v),
          onJornada:   (v) => setState(() => _jornadaPreferida   = v),
        );
      default: return const SizedBox.shrink();
    }
  }
}

// ── Paso 1: Educación ─────────────────────────────────────────────────────
class _Paso1Educacion extends StatelessWidget {
  final List<String> niveles;
  final String? seleccionado;
  final bool mostrarError;
  final ValueChanged<String> onSeleccionar;

  const _Paso1Educacion({
    super.key,
    required this.niveles,
    required this.seleccionado,
    required this.mostrarError,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿Cuál es tu nivel de estudio?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Selecciona el más alto que hayas alcanzado.',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ...niveles.map((nivel) => _OpcionSeleccionable(
            label: nivel,
            seleccionado: seleccionado == nivel,
            onTap: () => onSeleccionar(nivel),
          )),
          if (mostrarError)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('Selecciona una opción para continuar',
                  style: TextStyle(color: Color(0xFFB00020), fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

// ── Paso 2: Experiencia ───────────────────────────────────────────────────
class _Paso2Experiencia extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController experienciaCtrl;
  final TextEditingController habilidadesCtrl;

  const _Paso2Experiencia({
    super.key,
    required this.formKey,
    required this.experienciaCtrl,
    required this.habilidadesCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cuéntanos tu experiencia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Describe qué trabajos has tenido y qué sabes hacer.',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            TextFormField(
              controller: experienciaCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Experiencia laboral',
                hintText: 'Ej: Vendedor ambulante por 5 años, trabajo en restaurante...',
                alignLabelWithHint: true,
              ),
              validator: Validators.textoLargo,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: habilidadesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Tus habilidades',
                hintText: 'Ej: Atención al cliente, manejo de dinero, trabajo en equipo...',
                alignLabelWithHint: true,
              ),
              validator: Validators.textoLargo,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Paso 3: Preferencias ──────────────────────────────────────────────────
class _Paso3Preferencias extends StatelessWidget {
  final List<String> areas;
  final List<String> areasSeleccionadas;
  final List<String> modalidades;
  final List<String> jornadas;
  final String? modalidadSeleccionada;
  final String? jornadaSeleccionada;
  final void Function(String, bool) onToggleArea;
  final ValueChanged<String> onModalidad;
  final ValueChanged<String> onJornada;

  const _Paso3Preferencias({
    super.key,
    required this.areas,
    required this.areasSeleccionadas,
    required this.modalidades,
    required this.jornadas,
    required this.modalidadSeleccionada,
    required this.jornadaSeleccionada,
    required this.onToggleArea,
    required this.onModalidad,
    required this.onJornada,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿Qué tipo de trabajo buscas?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Esto nos ayuda a mostrarte las mejores vacantes para ti.',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          const Text('Áreas de interés', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: areas.map((area) {
              final sel = areasSeleccionadas.contains(area);
              return FilterChip(
                label: Text(area),
                selected: sel,
                onSelected: (v) => onToggleArea(area, v),
                selectedColor: const Color(0xFFBBDEFB),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Modalidad preferida', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...modalidades.map((m) => _OpcionSeleccionable(
            label: m,
            seleccionado: modalidadSeleccionada == m,
            onTap: () => onModalidad(m),
          )),
          const SizedBox(height: 20),
          const Text('Jornada preferida', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...jornadas.map((j) => _OpcionSeleccionable(
            label: j,
            seleccionado: jornadaSeleccionada == j,
            onTap: () => onJornada(j),
          )),
        ],
      ),
    );
  }
}

// ── Widget compartido ─────────────────────────────────────────────────────
class _OpcionSeleccionable extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;
  const _OpcionSeleccionable(
      {required this.label, required this.seleccionado, required this.onTap});

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
            color: seleccionado ? AppColors.primary : const Color(0xFFBDBDBD),
            width: seleccionado ? 2 : 1,
          ),
          color: seleccionado ? const Color(0xFFE3F2FD) : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal)),
            ),
            if (seleccionado)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
