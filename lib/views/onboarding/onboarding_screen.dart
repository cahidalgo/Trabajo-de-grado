import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

class _OnboardingPage {
  final IconData icon;
  final String titulo;
  final String descripcion;
  const _OnboardingPage({required this.icon, required this.titulo, required this.descripcion});
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
    _OnboardingPage(
      icon: Icons.work_outline,
      titulo: '¡Encuentra trabajo!',
      descripcion: 'Mira vacantes disponibles y postúlate fácil, desde tu celular.',
    ),
    _OnboardingPage(
      icon: Icons.person_outline,
      titulo: 'Crea tu perfil',
      descripcion: 'Cuéntanos tu experiencia y lo que sabes hacer para que te encuentren.',
    ),
    _OnboardingPage(
      icon: Icons.school_outlined,
      titulo: 'Aprende y crece',
      descripcion: 'Accede a cursos y formación para mejorar tus oportunidades laborales.',
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
            // Botón saltar (RF04: se puede omitir en cualquier momento)
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completar,
                child: const Text('Saltar'),
              ),
            ),

            // Páginas de onboarding
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
                        Icon(p.icon, size: 100, color: AppColors.primary),
                        const SizedBox(height: 32),
                        Text(p.titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text(p.descripcion, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary), textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicadores de página
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_paginas.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _paginaActual == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _paginaActual == i ? AppColors.primary : AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),

            // Botón siguiente / comenzar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () {
                  if (_paginaActual < _paginas.length - 1) {
                    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                  } else {
                    _completar();
                  }
                },
                child: Text(_paginaActual < _paginas.length - 1 ? 'Siguiente' : 'Comenzar'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
