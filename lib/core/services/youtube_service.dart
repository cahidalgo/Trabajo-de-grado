import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'supabase_service.dart';

/// Modelo de un video de YouTube
class YouTubeVideo {
  final String videoId;
  final String titulo;
  final String? descripcion;
  final String? thumbnailUrl;
  final String? channelTitle;
  final String? publishedAt;

  YouTubeVideo({
    required this.videoId,
    required this.titulo,
    this.descripcion,
    this.thumbnailUrl,
    this.channelTitle,
    this.publishedAt,
  });

  String get url => 'https://www.youtube.com/watch?v=$videoId';
}

/// Modelo de una playlist de YouTube (desde la tabla youtube_playlists)
class YouTubePlaylist {
  final int id;
  final String playlistId;
  final String categoria;
  final String titulo;
  final String? descripcion;

  YouTubePlaylist({
    required this.id,
    required this.playlistId,
    required this.categoria,
    required this.titulo,
    this.descripcion,
  });

  factory YouTubePlaylist.fromMap(Map<String, dynamic> map) => YouTubePlaylist(
    id: map['id'],
    playlistId: map['playlist_id'],
    categoria: map['categoria'],
    titulo: map['titulo'] ?? '',
    descripcion: map['descripcion'],
  );
}

/// Servicio para consultar YouTube Data API v3
///
/// SETUP REQUERIDO:
/// 1. Ir a https://console.cloud.google.com
/// 2. Crear proyecto → Habilitar "YouTube Data API v3"
/// 3. Crear credencial → API Key
/// 4. Pegar la key abajo (para MVP) o en variables de entorno
class YouTubeService {
  // ══════════════════════════════════════════════════════════════
  // ⚠️  REEMPLAZA ESTA KEY CON TU API KEY DE GOOGLE CLOUD
  // ══════════════════════════════════════════════════════════════
  static const _apiKey = 'AIzaSyBbbM_ys9fhI6aY4k7mDq3GxDHtsoMfztw';
  static const _baseUrl = 'https://www.googleapis.com/youtube/v3';

  /// Obtiene las playlists curadas desde la tabla youtube_playlists
  static Future<List<YouTubePlaylist>> obtenerPlaylists({String? categoria}) async {
    var query = SupabaseService.client
        .from('youtube_playlists')
        .select()
        .eq('activa', true);

    if (categoria != null) {
      query = query.eq('categoria', categoria);
    }

    final data = await query.order('categoria');
    return (data as List).map((e) => YouTubePlaylist.fromMap(e)).toList();
  }

  /// Obtiene los videos de una playlist de YouTube
  /// Costo: 1 unidad de quota por llamada
  static Future<List<YouTubeVideo>> obtenerVideosDePlaylist(
    String playlistId, {
    int maxResults = 10,
  }) async {
    if (_apiKey == 'TU_YOUTUBE_API_KEY_AQUI') {
      debugPrint('⚠️ YouTubeService: Configura tu API Key de YouTube');
      return [];
    }

    try {
      final uri = Uri.parse('$_baseUrl/playlistItems').replace(
        queryParameters: {
          'part': 'snippet',
          'playlistId': playlistId,
          'maxResults': maxResults.toString(),
          'key': _apiKey,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        debugPrint('YouTube API error: ${response.statusCode} ${response.body}');
        return [];
      }

      final json = jsonDecode(response.body);
      final items = json['items'] as List? ?? [];

      return items
          .where((item) {
            // Filtrar videos eliminados o privados
            final snippet = item['snippet'] as Map<String, dynamic>?;
            return snippet != null &&
                snippet['title'] != 'Private video' &&
                snippet['title'] != 'Deleted video';
          })
          .map((item) {
            final snippet = item['snippet'] as Map<String, dynamic>;
            final thumbnails = snippet['thumbnails'] as Map<String, dynamic>?;
            final medium = thumbnails?['medium'] as Map<String, dynamic>?;
            final resourceId = snippet['resourceId'] as Map<String, dynamic>?;

            return YouTubeVideo(
              videoId: resourceId?['videoId'] ?? '',
              titulo: snippet['title'] ?? '',
              descripcion: snippet['description'],
              thumbnailUrl: medium?['url'],
              channelTitle: snippet['channelTitle'],
              publishedAt: snippet['publishedAt'],
            );
          })
          .where((v) => v.videoId.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('YouTube API exception: $e');
      return [];
    }
  }

  /// Obtiene videos agrupados por playlist para una categoría
  static Future<Map<YouTubePlaylist, List<YouTubeVideo>>>
      obtenerVideosPorCategoria(String categoria) async {
    final playlists = await obtenerPlaylists(categoria: categoria);
    final result = <YouTubePlaylist, List<YouTubeVideo>>{};

    for (final playlist in playlists) {
      final videos = await obtenerVideosDePlaylist(playlist.playlistId);
      if (videos.isNotEmpty) {
        result[playlist] = videos;
      }
    }

    return result;
  }
}
