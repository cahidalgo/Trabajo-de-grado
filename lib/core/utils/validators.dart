class Validators {
  static String? correoOTelefono(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!emailRegex.hasMatch(value.trim()) && !phoneRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo o número de celular válido (10 dígitos)';
    }
    return null;
  }

  static String? contrasena(String? value) {
    if (value == null || value.isEmpty) return 'Este campo es obligatorio';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? obligatorio(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio';
    return null;
  }
}
