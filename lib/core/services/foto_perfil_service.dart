import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FotoPerfilService {
  static final _picker = ImagePicker();
  static const _prefKey = 'foto_perfil_path';

  /// Retorna la ruta guardada o null si no hay foto
  static Future<String?> obtenerRuta() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey);
  }

  /// Guarda la ruta de la foto
  static Future<void> guardarRuta(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, path);
  }

  /// Abre el selector de fuente (galería o cámara) y devuelve la ruta
  static Future<String?> seleccionarFoto(ImageSource fuente) async {
    final imagen = await _picker.pickImage(
      source: fuente,
      imageQuality: 75,   // comprime para no ocupar espacio
      maxWidth: 512,
      maxHeight: 512,
    );
    if (imagen == null) return null;
    await guardarRuta(imagen.path);
    return imagen.path;
  }

  /// Elimina la foto guardada
  static Future<void> eliminarFoto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}
