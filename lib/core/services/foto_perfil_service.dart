import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Servicio de foto de perfil usando Supabase Storage.
///
/// Requiere un bucket "avatars" público en Supabase Storage.
/// Las fotos se almacenan como: avatars/{authId}.jpg
class FotoPerfilService {
  static final _picker = ImagePicker();
  static const _bucket = 'avatars';

  /// Obtiene la URL pública de la foto del usuario autenticado.
  /// Retorna null si no tiene foto.
  static Future<String?> obtenerUrl() async {
    final authId = SupabaseService.currentAuthId;
    if (authId == null) return null;

    final path = '$authId.jpg';

    try {
      // Verificar si existe listando archivos
      final files = await SupabaseService.client
          .storage
          .from(_bucket)
          .list(path: '', searchOptions: SearchOptions(search: authId));

      final existe = files.any((f) => f.name == '$authId.jpg');
      if (!existe) return null;

      return SupabaseService.client
          .storage
          .from(_bucket)
          .getPublicUrl(path);
    } catch (_) {
      return null;
    }
  }

  /// Obtiene la URL pública para un authId específico.
  static String? obtenerUrlPara(String authId) {
    try {
      return SupabaseService.client
          .storage
          .from(_bucket)
          .getPublicUrl('$authId.jpg');
    } catch (_) {
      return null;
    }
  }

  /// Sube una foto desde un archivo local y retorna la URL pública.
  static Future<String?> subir(File archivo) async {
    final authId = SupabaseService.currentAuthId;
    if (authId == null) return null;

    final path = '$authId.jpg';
    final bytes = await archivo.readAsBytes();

    try {
      // Intentar primero update (si ya existe), si falla hacer upload
      try {
        await SupabaseService.client.storage
            .from(_bucket)
            .updateBinary(path, bytes, fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ));
      } catch (_) {
        await SupabaseService.client.storage
            .from(_bucket)
            .uploadBinary(path, bytes, fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ));
      }

      // Retornar URL pública con cache buster para forzar recarga
      final url = SupabaseService.client.storage
          .from(_bucket)
          .getPublicUrl(path);

      return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      return null;
    }
  }

  /// Abre el selector de imagen y sube a Supabase Storage.
  /// Retorna la URL pública o null si se canceló/falló.
  static Future<String?> seleccionarYSubir(ImageSource fuente) async {
    final imagen = await _picker.pickImage(
      source: fuente,
      imageQuality: 75,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (imagen == null) return null;
    return subir(File(imagen.path));
  }

  /// Elimina la foto del usuario autenticado.
  static Future<void> eliminar() async {
    final authId = SupabaseService.currentAuthId;
    if (authId == null) return;

    try {
      await SupabaseService.client.storage
          .from(_bucket)
          .remove(['$authId.jpg']);
    } catch (_) {
      // Ignorar si no existía
    }
  }
}
