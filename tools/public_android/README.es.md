# Yu-Gi-Oh! Power of Chaos Remake · Fuentes Android

[English](README.md) | **Español** | [Launcher Windows](https://github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake/tree/main)

El launcher Windows ofrece **Extraer para PC** y **Crear APK**. Al compilar con
estas fuentes Android conserva el táctil, el scroll, el arrastre y la selección
nativa de sacrificios. El APK queda junto al launcher.

Esta rama contiene el motor Android y el compilador. **No incluye datos de los
juegos originales, SDK/JDK, claves de firma ni un APK con los juegos.** Configura
las herramientas locales y aporta tus copias compatibles. La prueba física en
teléfono o tablet sigue pendiente.

## Usar desde el launcher Windows

Sigue [la configuración Android del README principal](https://github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake/blob/main/README.es.md#configurar-la-compilación-android).
Clona esta rama en una carpeta separada; no la copies encima del código PC.
Conserva tu propia clave de depuración para actualizar tus APK. Al configurar una
actualización, indica también tu APK anterior para verificar su certificado.
La primera instalación admite `--first-build`; el certificado resultante también
debe coincidir con la clave configurada. No publiques la clave ni los recursos.

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
