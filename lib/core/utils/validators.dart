class Validators {
  // Nombre completo: mínimo 3 caracteres, solo letras y espacios
  static String? nombreCompleto(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio';
    if (value.trim().length < 3) return 'Debe tener al menos 3 caracteres';
    final regex = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s'-]+$");
    if (!regex.hasMatch(value.trim())) return 'Solo se permiten letras y espacios';
    return null;
  }

  // Correo o celular
  static String? correoOTelefono(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio';
    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!emailRegex.hasMatch(value.trim()) && !phoneRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo válido o un número de 10 dígitos';
    }
    return null;
  }

  // Contraseña con reglas visuales
  static String? contrasena(String? value) {
    if (value == null || value.isEmpty) return 'Este campo es obligatorio';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Debe incluir al menos una mayúscula';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Debe incluir al menos un número';
    return null;
  }

  // Confirmar contraseña
  static String? Function(String?) confirmarContrasena(String original) {
    return (String? value) {
      if (value == null || value.isEmpty) return 'Confirma tu contraseña';
      if (value != original) return 'Las contraseñas no coinciden';
      return null;
    };
  }

  // Campo obligatorio genérico
  static String? obligatorio(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio';
    return null;
  }

  // Texto largo (experiencia, habilidades)
  static String? textoLargo(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio';
    if (value.trim().length < 10) return 'Escribe al menos 10 caracteres';
    return null;
  }

  // Verificador de fortaleza de contraseña (retorna 0-3)
  static int fuerzaContrasena(String value) {
    int score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    return score;
  }
}
