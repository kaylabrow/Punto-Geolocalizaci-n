# GeoPuntos

App iOS (SwiftUI + SwiftData) para crear, archivar y gestionar puntos de geolocalización.

## Funcionalidades

- Crear puntos de geolocalización usando la ubicación actual del dispositivo o introduciendo coordenadas manualmente.
- Archivar los puntos (persistencia local con SwiftData).
- Listado con búsqueda, renombrado (swipe / menú contextual / detalle) y eliminación.
- Abrir un punto en Apple Maps o Google Maps (app nativa o web si no está instalada).
- Compartir un punto por WhatsApp con enlace de Google Maps, Apple Maps o ambos.
- Editar nota del punto.

## Requisitos

- macOS con Xcode 15+ (iOS 17 deployment target).
- XcodeGen (opcional, para regenerar el proyecto): `brew install xcodegen`

## Compilar y generar .ipa

1. Generar el proyecto Xcode (si usas XcodeGen):
   ```bash
   cd GeoPuntos
   xcodegen generate
   ```
2. Abrir `GeoPuntos.xcodeproj` en Xcode.
3. Seleccionar dispositivo genérico iOS / "Any iOS Device (arm64)".
4. `Product > Archive`.
5. En el Organizer, seleccionar el archive y `Distribute App > Ad Hoc / App Store Connect / Development` para exportar el `.ipa`.

### Sin firma (simulador / desarrollo)

El proyecto está configurado con `CODE_SIGNING_REQUIRED=NO` para poder compilar sin certificados en CI. Para distribuir en un iPhone real necesitas configurar tu equipo de desarrollo y perfil de aprovisionamiento en Xcode.

## CI (GitHub Actions)

Se incluye `.github/workflows/build-ipa.yml` que compila el proyecto en un runner macOS y genera un `.ipa` sin firma como artefacto. Puedes adaptarlo para firmar con tus certificados (secrets).

## Permisos

- `NSLocationWhenInUseUsageDescription`: ubicación para crear puntos.
- `LSApplicationQueriesSchemes`: `comgooglemaps`, `whatsapp`, `googlemaps`.
