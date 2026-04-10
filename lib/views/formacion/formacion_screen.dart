import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/youtube_service.dart';
import '../../core/utils/category_style.dart';
import '../../core/widgets/app_ui.dart';
import '../../data/models/formacion.dart';
import '../../data/repositories/formacion_repository.dart';

class FormacionScreen extends StatefulWidget {
  const FormacionScreen({super.key});

  @override
  State<FormacionScreen> createState() => _FormacionScreenState();
}

class _FormacionScreenState extends State<FormacionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formación'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.school_outlined), text: 'Cursos'),
            Tab(icon: Icon(Icons.play_circle_outline), text: 'Videos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          _CursosTab(),
          _VideosTab(),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// TAB 1: CURSOS INSTITUCIONALES
// ══════════════════════════════════════════════════════════════════
class _CursosTab extends StatefulWidget {
  const _CursosTab();

  @override
  State<_CursosTab> createState() => _CursosTabState();
}

class _CursosTabState extends State<_CursosTab>
    with AutomaticKeepAliveClientMixin {
  final _repo = FormacionRepository();
  List<Formacion> _cursos = [];
  bool _cargando = true;
  String? _filtro;

  static const _categorias = [
    'ventas', 'gastronomía', 'logística', 'servicios',
    'herramientas digitales', 'emprendimiento', 'habilidades blandas', 'construcción',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    _cursos = await _repo.obtenerCursos(categoria: _filtro);
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            children: [
              const AppPageIntro(
                title: 'Cursos certificados',
                subtitle: 'Cursos gratuitos del SENA, Google y MinTIC para fortalecer tu perfil laboral.',
                icon: Icons.verified_outlined,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FiltroChip(
                      label: 'Todos',
                      seleccionado: _filtro == null,
                      onTap: () { setState(() => _filtro = null); _cargar(); },
                    ),
                    ..._categorias.map((c) => _FiltroChip(
                      label: c,
                      seleccionado: _filtro == c,
                      onTap: () { setState(() => _filtro = c); _cargar(); },
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _cursos.isEmpty
                  ? const AppEmptyState(
                      icon: Icons.school_outlined,
                      title: 'No hay cursos en esta categoría',
                      description: 'Prueba con otra categoría.',
                    )
                  : RefreshIndicator(
                      onRefresh: _cargar,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: _cursos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _TarjetaCurso(
                          curso: _cursos[i],
                          onAbrirUrl: _abrirUrl,
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// TAB 2: VIDEOS DE YOUTUBE
// ══════════════════════════════════════════════════════════════════
class _VideosTab extends StatefulWidget {
  const _VideosTab();

  @override
  State<_VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<_VideosTab>
    with AutomaticKeepAliveClientMixin {
  List<YouTubePlaylist> _playlists = [];
  Map<String, List<YouTubeVideo>> _videosPorPlaylist = {};
  bool _cargando = true;
  String? _filtro;
  String? _playlistExpandida;

  static const _categorias = [
    'ventas', 'emprendimiento', 'herramientas digitales', 'habilidades blandas',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cargarPlaylists();
  }

  Future<void> _cargarPlaylists() async {
    setState(() => _cargando = true);
    _playlists = await YouTubeService.obtenerPlaylists(categoria: _filtro);
    _videosPorPlaylist.clear();
    _playlistExpandida = null;
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _togglePlaylist(String playlistId) async {
    if (_playlistExpandida == playlistId) {
      setState(() => _playlistExpandida = null);
      return;
    }

    setState(() => _playlistExpandida = playlistId);

    if (!_videosPorPlaylist.containsKey(playlistId)) {
      final videos = await YouTubeService.obtenerVideosDePlaylist(playlistId);
      if (mounted) {
        setState(() => _videosPorPlaylist[playlistId] = videos);
      }
    }
  }

  Future<void> _abrirVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            children: [
              const AppPageIntro(
                title: 'Video cursos',
                subtitle: 'Playlists de YouTube curadas con cursos gratuitos en español para tu crecimiento profesional.',
                icon: Icons.play_circle_outline,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FiltroChip(
                      label: 'Todos',
                      seleccionado: _filtro == null,
                      onTap: () { setState(() => _filtro = null); _cargarPlaylists(); },
                    ),
                    ..._categorias.map((c) => _FiltroChip(
                      label: c,
                      seleccionado: _filtro == c,
                      onTap: () { setState(() => _filtro = c); _cargarPlaylists(); },
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _playlists.isEmpty
                  ? const AppEmptyState(
                      icon: Icons.play_circle_outline,
                      title: 'No hay videos en esta categoría',
                      description: 'Prueba con otra categoría o revisa tu conexión.',
                    )
                  : RefreshIndicator(
                      onRefresh: _cargarPlaylists,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: _playlists.length,
                        itemBuilder: (_, i) => _TarjetaPlaylist(
                          playlist: _playlists[i],
                          expandida: _playlistExpandida == _playlists[i].playlistId,
                          videos: _videosPorPlaylist[_playlists[i].playlistId] ?? [],
                          onTap: () => _togglePlaylist(_playlists[i].playlistId),
                          onAbrirVideo: _abrirVideo,
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// WIDGETS
// ══════════════════════════════════════════════════════════════════

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;

  const _FiltroChip({required this.label, required this.seleccionado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: seleccionado ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: seleccionado ? AppColors.primary : AppColors.border),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: seleccionado ? Colors.white : AppColors.textPrimary,
                fontWeight: seleccionado ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tarjeta de curso institucional ────────────────────────────────────────────
class _TarjetaCurso extends StatelessWidget {
  final Formacion curso;
  final void Function(String url) onAbrirUrl;

  const _TarjetaCurso({required this.curso, required this.onAbrirUrl});

  @override
  Widget build(BuildContext context) {
    final style = AppCategoryStyles.resolve(curso.categoria);

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: style.accent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(style.icon, color: style.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(curso.titulo,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: style.accent),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                      if ((curso.entidad ?? '').isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(curso.entidad!,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((curso.descripcion ?? '').isNotEmpty) ...[
                  Text(curso.descripcion!,
                    style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                ],
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    if ((curso.modalidad ?? '').isNotEmpty)
                      AppTag(label: curso.modalidad!, color: style.accent),
                    if ((curso.duracion ?? '').isNotEmpty)
                      AppTag(label: curso.duracion!, color: AppColors.primary),
                    if (curso.gratuito)
                      const AppTag(label: '✓ Gratuito', color: Color(0xFF2E7D32)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _verDetalle(context),
                      child: const Text('Ver detalle'),
                    ),
                    const Spacer(),
                    if ((curso.url ?? '').isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () => onAbrirUrl(curso.url!),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Inscribirme'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          textStyle: const TextStyle(fontSize: 13),
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

  void _verDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.62, minChildSize: 0.4, maxChildSize: 0.9, expand: false,
        builder: (ctx, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 42, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 20),
              Text(curso.titulo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              if ((curso.entidad ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(curso.entidad!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ],
              const SizedBox(height: 16),
              if ((curso.descripcion ?? '').isNotEmpty)
                Text(curso.descripcion!, style: const TextStyle(fontSize: 15, height: 1.6)),
              const SizedBox(height: 20),
              if ((curso.modalidad ?? '').isNotEmpty) _DetalleRow('Modalidad', curso.modalidad!),
              if ((curso.duracion ?? '').isNotEmpty) _DetalleRow('Duración', curso.duracion!),
              if ((curso.categoria ?? '').isNotEmpty) _DetalleRow('Categoría', curso.categoria!),
              _DetalleRow('Precio', curso.gratuito ? 'Gratuito' : 'Consultar'),
              const SizedBox(height: 24),
              if ((curso.url ?? '').isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onAbrirUrl(curso.url!);
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Ir a inscribirme'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tarjeta de playlist de YouTube ────────────────────────────────────────────
class _TarjetaPlaylist extends StatelessWidget {
  final YouTubePlaylist playlist;
  final bool expandida;
  final List<YouTubeVideo> videos;
  final VoidCallback onTap;
  final void Function(String url) onAbrirVideo;

  const _TarjetaPlaylist({
    required this.playlist,
    required this.expandida,
    required this.videos,
    required this.onTap,
    required this.onAbrirVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Header de la playlist
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: expandida
                    ? const BorderRadius.vertical(top: Radius.circular(16))
                    : BorderRadius.circular(16),
                border: Border.all(
                  color: expandida ? AppColors.primary.withOpacity(0.4) : AppColors.border,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.playlist_play, color: Color(0xFFFF0000), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(playlist.titulo,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 3),
                        Text(playlist.descripcion ?? playlist.categoria,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(expandida ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary),
                ],
              ),
            ),
          ),

          // Lista de videos expandida
          if (expandida)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border.all(color: AppColors.primary.withOpacity(0.4)),
              ),
              child: videos.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(strokeWidth: 2),
                            SizedBox(height: 12),
                            Text('Cargando videos...', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: videos.map((video) => _VideoItem(
                        video: video,
                        onTap: () => onAbrirVideo(video.url),
                      )).toList(),
                    ),
            ),
        ],
      ),
    );
  }
}

// ── Item individual de video ──────────────────────────────────────────────────
class _VideoItem extends StatelessWidget {
  final YouTubeVideo video;
  final VoidCallback onTap;

  const _VideoItem({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: video.thumbnailUrl != null
                  ? Image.network(
                      video.thumbnailUrl!,
                      width: 120, height: 68, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderThumb(),
                    )
                  : _placeholderThumb(),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(video.titulo,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (video.channelTitle != null)
                    Text(video.channelTitle!,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.play_circle_outline, color: Color(0xFFFF0000), size: 28),
          ],
        ),
      ),
    );
  }

  Widget _placeholderThumb() => Container(
    width: 120, height: 68,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
  );
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────
class _DetalleRow extends StatelessWidget {
  final String label;
  final String valor;
  const _DetalleRow(this.label, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textSecondary))),
          const SizedBox(width: 12),
          Expanded(child: Text(valor, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
