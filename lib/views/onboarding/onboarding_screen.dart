import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

class OnboardingPage {
  final IconData icon;
  final String titulo;
  final String descripcion;
  const OnboardingPage({
    required this.icon,
    required this.titulo,
    required this.descripcion,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _paginaActual = 0;

  final _paginas = const [
    OnboardingPage(
      icon: Icons.work_outline,
      titulo: '¡Encuentra trabajo!',
      descripcion:
          'Mira vacantes disponibles y postúlate fácil, desde tu celular.',
    ),
    OnboardingPage(
      icon: Icons.person_outline,
      titulo: 'Crea tu perfil',
      descripcion:
          'Cuéntanos tu experiencia y lo que sabes hacer para que te encuentren.',
    ),
    OnboardingPage(
      icon: Icons.school_outlined,
      titulo: 'Aprende y crece',
      descripcion:
          'Accede a cursos y formación para mejorar tus oportunidades laborales.',
    ),
  ];

  Future<void> _completar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completado', true);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Botón saltar
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completar,
                child: const Text('Saltar'),
              ),
            ),
            // Páginas
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _paginas.length,
                onPageChanged: (i) => setState(() => _paginaActual = i),
                itemBuilder: (_, i) {
                  final p = _paginas[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            p.icon,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          p.titulo,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p.descripcion,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Indicadores
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _paginas.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _paginaActual == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _paginaActual == i
                        ? AppColors.primary
                        : AppColors.textDisabled,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Botón siguiente / comenzar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () {
                  if (_paginaActual < _paginas.length - 1) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  } else {
                    _completar();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(
                  _paginaActual < _paginas.length - 1
                      ? 'Siguiente'
                      : 'Comenzar',
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}