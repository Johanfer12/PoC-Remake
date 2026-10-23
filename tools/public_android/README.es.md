# Yu-Gi-Oh! Power of Chaos Remake · Fuentes Android

[English](README.md) | **Español** | [Launcher Windows](https://github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake/tree/main)

El launcher Windows ofrece **Extraer para PC** y **Crear APK**. Incluye las fuentes Android y prepara las herramientas automáticamente, sin instalar Python ni configurar SDK/JDK por separado. Conserva los controles táctiles, scroll, arrastre y selección nativa de sacrificios, con el mismo icono de PC.

Todo queda en **`PoC Data/android/`**: herramientas reutilizables, firma, registros y APK. La conexión de Joey ya se probó entre **PC y PC**, y entre **PC y Android**. Seguimos en alfa y agradecemos comentarios y reportes.

Esta rama contiene fuentes, sin recursos de los juegos originales ni claves privadas.

## Usar desde el launcher Windows

Descarga el EXE de [Releases](https://github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake/releases), selecciona tus juegos o reutiliza tu biblioteca y pulsa **Crear APK**. La primera vez acepta la licencia del SDK; el launcher descarga y verifica las herramientas oficiales. No hace falta clonar esta rama.

El APK aparece en `PoC Data/android/apks/`. Conserva y respalda `PoC Data`, incluida tu firma local, para actualizar tus APK. Consulta [Crear tu APK Android](https://github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake/blob/main/README.es.md#crear-tu-apk-android).

## Compilar directamente

Desde la raíz de esta copia, con los datos compactos preparados desde tus juegos:

```powershell
python tools/android/build_apk.py --godot <godot_console.exe> --sdk <Android-SDK> --debug-keystore <tu-debug.keystore> --first-build --data <datos-compactos> --work <carpeta-nueva> --output <nuevo.apk>
```

Para actualizar, sustituye `--first-build` por `--previous-apk <tu-anterior.apk>`.
El compilador verifica arranque de los juegos incluidos, firma, certificado,
integridad ZIP, hash del PCK y alineación de 16 KB. Conserva informe y registros
en la carpeta de trabajo. `game/` contiene el código editable; el proyecto
exportable generado no es la fuente principal.

Fuentes experimentales no oficiales, derivadas en parte mediante ingeniería
inversa. La fidelidad, el soporte de hardware y la licencia general siguen en
revisión. Consulta los [avisos de terceros](THIRD_PARTY_NOTICES.md).
