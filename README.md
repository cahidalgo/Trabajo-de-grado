# Formalia

> Plataforma móvil de empleo formal para vendedores ambulantes y pequeñas empresas en Colombia.

Formalia conecta a personas en economía informal con oportunidades de trabajo formal, ofreciendo un proceso de postulación simple, seguimiento del estado de cada candidatura y contenido de formación para mejorar el perfil del candidato.

---

## Tabla de contenidos

- [Contexto y propósito](#contexto-y-propósito)
- [Funcionalidades](#funcionalidades)
- [Stack tecnológico](#stack-tecnológico)
- [Arquitectura del proyecto](#arquitectura-del-proyecto)
- [Esquema de base de datos](#esquema-de-base-de-datos)
- [Instalación y configuración](#instalación-y-configuración)
- [Variables de entorno y claves](#variables-de-entorno-y-claves)
- [Generación del APK](#generación-del-apk)
- [Roles de usuario](#roles-de-usuario)
- [Flujos principales](#flujos-principales)
- [Decisiones técnicas relevantes](#decisiones-técnicas-relevantes)
- [Pendientes y roadmap](#pendientes-y-roadmap)

---

## Contexto y propósito

Colombia tiene millones de personas trabajando en economía informal — vendedores ambulantes, trabajadores por día, personal de servicios — que rara vez acceden a oportunidades de empleo formal porque los canales existentes (LinkedIn, Computrabajo) no están diseñados para ellos.

Formalia cierra esa brecha con una app móvil simple, en español, que no asume conocimientos previos de tecnología y prioriza WhatsApp como canal de comunicación porque es la herramienta que este público ya usa.

El MVP tiene tres tipos de usuario: **vendedores** (buscan trabajo), **empresas** (publican vacantes y gestionan postulantes) y **administradores** (validan empresas y monitorean la plataforma).

---

## Funcionalidades

### Vendedor
- Registro con correo electrónico o número de celular colombiano
- Completar perfil con nivel educativo, experiencia, habilidades y preferencias
- Explorar vacantes con búsqueda por texto y filtros de categoría y modalidad
- Guardar vacantes para revisar después
- Postularse a vacantes (requiere perfil completo)
- Historial de postulaciones con estado en tiempo real
- Ver datos de contacto de la empresa cuando la postulación es aceptada
- Contactar a la empresa directamente por WhatsApp desde la app
- Acceso a cursos y videos de formación curados por categoría

### Empresa
- Registro con NIT y datos de la empresa
- Dashboard con vacantes activas y métricas básicas
- Publicar, editar, pausar y eliminar vacantes
- Ver lista de postulantes por vacante con su perfil completo
- Cambiar el estado de cada postulación: Enviada → Vista → Aceptada / Rechazada
- Contactar postulantes por WhatsApp con mensaje predefinido
- Editar perfil de la empresa

### Administrador
- Dashboard con estadísticas globales (usuarios, empresas, vacantes, postulaciones)
- Validar empresas registradas
- Gestionar usuarios y empresas
- Monitorear vacantes activas

---

## Stack tecnológico

| Capa | Tecnología |
|---|---|
| Frontend | Flutter (Dart) |
| Backend / base de datos | Supabase (PostgreSQL + Auth) |
| Estado | Provider + ChangeNotifier |
| Navegación | go_router |
| Contenido formativo | YouTube Data API v3 |
| Comunicación | url_launcher → WhatsApp / mailto |
| Entrada de voz | speech_to_text |
| Imágenes de perfil | image_picker + Supabase Storage |

---

## Arquitectura del proyecto

El proyecto sigue una arquitectura **MVVM** (Model - View - ViewModel) con repositorios como capa de acceso a datos.

```
lib/
├── core/
│   ├── constants/        # Colores, strings, configuración de Supabase
│   ├── router/           # app_router.dart — rutas y guard de roles
│   ├── services/         # SupabaseService, SessionService, YouTubeService
│   ├── theme/            # AppTheme
│   ├── utils/            # Validators, category_style
│   └── widgets/          # Widgets reutilizables (AppUI, AvatarPerfil, etc.)
│
├── data/
│   ├── models/           # Clases de datos: Usuario, Vacante, Empresa, etc.
│   └── repositories/     # Acceso a Supabase: consultas, inserts, updates
│
├── viewmodels/           # Lógica de negocio y estado por módulo
│
├── views/
│   ├── admin/            # Dashboard, gestión de usuarios/empresas/vacantes
│   ├── auth/             # Login, registro
│   ├── empresas/         # Dashboard empresa, vacantes, postulantes
│   ├── formacion/        # Cursos y videos
│   ├── guardadas/        # Vacantes guardadas
│   ├── home/             # Shell con navegación inferior
│   ├── perfil/           # Perfil del vendedor
│   ├── postulaciones/    # Historial de postulaciones
│   ├── splash/           # Splash con detección de rol
│   └── vacantes/         # Lista y detalle de vacantes
│
└── main.dart
```

### Flujo de roles

`SessionService` es un singleton estático que mantiene el rol del usuario en memoria (`'vendedor'`, `'empresa'`, `'admin'`). Se popula en el splash al detectar el tipo de usuario y se limpia al cerrar sesión. El guard del router usa este valor de forma síncrona para proteger las rutas por rol.

---

## Esquema de base de datos

Las tablas principales en Supabase son:

| Tabla | Descripción |
|---|---|
| `usuarios` | Vendedores registrados |
| `perfiles` | Datos del perfil del vendedor (educación, experiencia, etc.) |
| `empresas` | Empresas registradas |
| `admins` | Administradores de la plataforma |
| `vacantes` | Espejo público de vacantes (lo que ve el vendedor) |
| `vacantes_empresa` | Vacantes con detalle completo (lo que ve la empresa) |
| `postulaciones` | Relación usuario ↔ vacante con estado |
| `vacantes_guardadas` | Vacantes guardadas por el usuario |
| `youtube_playlists` | Playlists curadas de formación por categoría |
| `consentimientos_privacidad` | Registro de aceptación de política de privacidad |

### Dual-write de vacantes

Cuando una empresa publica una vacante, se hace un **dual-write atómico**: se inserta en `vacantes_empresa` (con todos los campos de negocio) y simultáneamente se crea un espejo en `vacantes` (la vista pública del vendedor). Ambas tablas se mantienen sincronizadas al editar, pausar o eliminar.

### Números de teléfono como usuarios

Supabase Auth solo acepta formato email. Los números de celular colombianos se convierten a un email sintético antes de registrarse:

```
3001234567  →  3001234567@formalia.co
```

---

## Instalación y configuración

### Requisitos

- Flutter SDK 3.x
- Dart 3.x
- Cuenta en [Supabase](https://supabase.com)
- Cuenta en [Google Cloud Console](https://console.cloud.google.com) (para YouTube API)
- Android SDK / Xcode (para compilar)

### Pasos

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/formalia.git
cd formalia

# 2. Instalar dependencias
flutter pub get

# 3. Configurar credenciales (ver sección siguiente)

# 4. Correr en modo debug
flutter run
```

---

## Variables de entorno y claves

El proyecto actualmente maneja las claves directamente en el código. Antes de publicar en producción, migrarlas a variables de entorno o Supabase Edge Functions.

### Supabase — `lib/main.dart`

```dart
await Supabase.initialize(
  url:     'https://TU_PROYECTO.supabase.co',
  anonKey: 'TU_ANON_KEY',
);
```

Obtener estos valores en: **Supabase Dashboard → Settings → API**

### YouTube Data API — `lib/core/services/youtube_service.dart`

```dart
static const _apiKey = 'TU_YOUTUBE_API_KEY';
```

Obtener en: **Google Cloud Console → APIs → YouTube Data API v3 → Credenciales**

> ⚠️ Para producción, estas claves deben moverse a una Supabase Edge Function para que nunca queden expuestas en el APK.

---

## Generación del APK

### APK de desarrollo (debug)

```bash
flutter build apk --debug
```

### APK de producción (release)

```bash
flutter build apk --release
```

El archivo queda en:
```
build/app/outputs/flutter-apk/app-release.apk
```

Para instalar directamente en un dispositivo conectado:
```bash
flutter install --release
```

### Configuración requerida para el release

**`android/app/build.gradle.kts`** — R8 debe estar desactivado para que Supabase funcione correctamente:

```kotlin
buildTypes {
    release {
        isMinifyEnabled = false
        isShrinkResources = false
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

**`android/app/src/main/AndroidManifest.xml`** — Permiso de internet obligatorio (Flutter no lo inyecta automáticamente en release):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## Roles de usuario

| Rol | Acceso | Ruta principal |
|---|---|---|
| Vendedor | Vacantes, perfil, postulaciones, formación | `/home` |
| Empresa | Dashboard, vacantes propias, postulantes | `/empresa/dashboard` |
| Admin | Panel de administración completo | `/admin` |

El sistema de roles funciona así:
1. Al iniciar sesión, se consultan las tablas `admins`, `usuarios` y `empresas` en ese orden
2. El primer match determina el rol
3. El rol se guarda en `SessionService.rolActual`
4. El guard del router redirige automáticamente si un rol intenta acceder a rutas de otro

---

## Flujos principales

### Postulación del vendedor

```
Vendedor ve vacante
  → Verificar perfil completo
    → Si incompleto: mostrar banner + bloquear con diálogo
    → Si completo: mostrar diálogo de confirmación
      → Postulación registrada en Supabase
        → Empresa ve postulante en su panel
          → Empresa cambia estado: Enviada → Aceptada
            → Vendedor ve estado actualizado en historial
              → Datos de contacto de la empresa son revelados al vendedor
                → Vendedor puede escribir por WhatsApp desde la app
```

### Contacto empresa → postulante

```
Empresa ve tarjeta de postulante
  → Si el contacto es un teléfono celular
    → Botón "Contactar por WhatsApp"
      → Se abre WhatsApp con mensaje predefinido:
        "Hola [nombre], te contactamos de [empresa] por tu postulación a [vacante] en Formalia."
```

### Publicación de vacante (dual-write)

```
Empresa llena formulario de vacante
  → Se obtiene razon_social de la empresa
  → INSERT en tabla vacantes (espejo público)
  → INSERT en tabla vacantes_empresa (con referencia vacante_id)
  → Vendedores ven la vacante en su lista inmediatamente
```

---

## Decisiones técnicas relevantes

**¿Por qué Supabase en lugar de Firebase?**
PostgreSQL permite JOINs nativos que simplificaron el esquema. Las Row Level Security policies de Supabase son más granulares que las reglas de Firestore para este caso de uso de múltiples roles.

**¿Por qué WhatsApp en lugar de chat propio?**
El público objetivo ya usa WhatsApp como herramienta principal. Implementar un chat propio requeriría backend en tiempo real, notificaciones push y mantenimiento adicional. WhatsApp elimina esa fricción para el MVP.

**¿Por qué dual-write en vacantes?**
Separar `vacantes` (vista pública) de `vacantes_empresa` (vista de negocio) permite que la empresa tenga campos adicionales (banderas de inclusión, zona de portal, formación incluida) sin exponerlos todos al vendedor. La sincronización es explícita y controlada.

**¿Por qué SessionService estático?**
El guard de rutas de `go_router` es síncrono — no puede hacer llamadas async a Supabase en cada navegación. `SessionService` resuelve esto manteniendo el rol en memoria después de que el splash lo determina de forma async.

**Números de teléfono como email sintético**
Supabase Auth no soporta autenticación por SMS en el tier gratuito. Convertir `3001234567` en `3001234567@formalia.co` permite usar el flujo de email/password estándar sin costo adicional.

---

## Pendientes y roadmap

### Crítico (próxima iteración)
- [ ] Recuperación de contraseña (flujo de reset por email)
- [ ] Botón "Vista" en panel de postulantes (marcar que la empresa revisó)
- [ ] Manejo de sesión expirada (listener de auth state)

### Importante
- [ ] Zona / ubicación en las vacantes del vendedor
- [ ] Foto de perfil para vendedores
- [ ] Feedback claro cuando la empresa no está validada por el admin
- [ ] Paginación en lista de vacantes (`.limit()` + scroll infinito)
- [ ] Métricas por vacante en el dashboard de empresa

### Producción
- [ ] Mover API keys a Supabase Edge Functions
- [ ] Configurar ProGuard con reglas específicas para Supabase/Ktor (actualmente R8 desactivado)
- [ ] Firma del APK con keystore propio (actualmente usa debug keystore)
- [ ] Publicación en Google Play Store (applicationId único, no `com.example.mvp`)
- [ ] Push notifications cuando cambia el estado de una postulación
- [ ] Términos y condiciones separados de la política de privacidad
