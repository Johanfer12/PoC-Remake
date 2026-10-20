<p align="center">
  <img src="game/assets/icons/launcher.svg" width="112" height="112" alt="Icono de Power of Chaos Remake">
</p>

# Yu-Gi-Oh! Power of Chaos Remake

[English](README.md) | **Español**

**Tus juegos de Power of Chaos reunidos en un launcher moderno para Windows.**

## Ventajas

- **Duelos en red en Joey sin DirectPlay.** La conexión moderna por red local sustituye ese componente antiguo de Windows. Queda pendiente completar la prueba entre dos PC físicos.
- **Portable.** Lleva juntos el EXE y su carpeta **`PoC Data`**: ahí viajan tus recursos, partidas y ajustes.
- **Recursos más livianos.** Las imágenes WebP sin pérdida y el audio OGG reducen el espacio ocupado. La biblioteca de Yugi probada ocupa aproximadamente **un 44% menos** que su versión convertida sin comprimir. El ahorro depende del juego y la edición.
- **Decoraciones para 16:9.** Los laterales decorados rodean el área de duelo original de 4:3 en las vistas compatibles de Yugi y Joey. Las imágenes actuales son temporales.
- **Todo en uno.** Yugi the Destiny, Kaiba the Revenge y Joey the Passion comparten un launcher. Puedes empezar con uno y añadir los demás cuando quieras.
- **Dibujo a más de 30 FPS.** El renderizado sigue la frecuencia de la pantalla e interpola entre los pasos originales del juego a 30 Hz. Los FPS efectivos dependen del equipo y la pantalla; se conserva la velocidad original de juego.

## ¿Qué es este remake?

Yu-Gi-Oh! Power of Chaos Remake es una reconstrucción experimental en Godot del motor de **Yugi the Destiny, Kaiba the Revenge y Joey the Passion**. Busca conservar las reglas, la presentación y la sensación de los originales, facilitando su uso y mantenimiento en PC modernos.

Tú aportas una copia compatible del juego que quieras usar. El launcher lee sus recursos en tu equipo y los prepara para el nuevo motor. **Basta con un juego para empezar.**

> **Versión preliminar:** el desarrollo y las pruebas de compatibilidad continúan. Todavía no es un reemplazo terminado y completamente fiel de todas las ediciones originales.

### Más funciones del launcher

- **Un solo EXE para Windows.** Incluye Godot, el conversor y 7-Zip; no necesitas instalarlos por separado.
- **Importación desde ISO o carpeta instalada.** Las imágenes compatibles se leen sin ejecutar sus instaladores ni los juegos originales.
- **Archivos locales.** Tus ISO, recursos y partidas no se suben a GitHub ni a un servicio de conversión.
- **Añade juegos sin empezar de nuevo.** Las importaciones posteriores conservan los juegos preparados y los guardados del remake.
- **Selector de idiomas.** Inglés, español, alemán, francés, italiano y japonés; el primer inicio toma un idioma compatible del sistema y recuerda tu elección.
- **Menú propio.** Música del launcher, controles dorados, icono propio y ajuste de volumen.
- **Motor en Godot.** Los recursos originales los aporta cada jugador por separado.

«Remake» se refiere a la reconstrucción del motor. No significa que se hayan redibujado las cartas ni vuelto a grabar las voces y la música originales.

## Empezar en Windows

1. Descarga **`PowerOfChaos.exe`** desde [Releases](https://github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake/releases). También hay compilaciones de desarrollo en [Actions](https://github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake/actions/workflows/build-windows.yml).
2. Pon el EXE en una carpeta donde quieras guardar el launcher y tus partidas, y ábrelo.
3. En **SUBE TUS RECURSOS**, pasa el cursor por el juego que quieras añadir y elige **ISO** o **Carpeta**.
4. Selecciona una imagen de disco o carpeta instalada compatible, pulsa **Preparar juegos** y espera a que termine.
5. Haz clic en el logo del juego preparado para jugar. Puedes añadir los otros después.

La descarga es un único EXE, sin asistente de instalación. La primera importación prepara las herramientas incluidas en `PoC Data/tools/`; abrir el menú no espera esa extracción. Los archivos de Actions pueden venir en ZIP; los de Releases permiten descargar directamente el EXE.

Necesitas Windows con soporte para el renderizador OpenGL de compatibilidad de Godot, una copia compatible de al menos un juego y espacio libre para los recursos y archivos temporales. Una carpeta instalada debe contener `Data.dat`, `Voice.dat`, `Region.dat` y el ejecutable original correspondiente; este se lee para obtener tablas del motor, sin ejecutarlo.

## Cómo funciona

```text
Tu ISO o carpeta instalada
            |
 Validación y extracción local
            |
 Recursos convertidos en tu PC
            |
     Motor del juego en Godot
```

El EXE distribuido contiene el launcher, el motor y las herramientas de conversión. No incluye los ejecutables originales ni sus ilustraciones, voces o música de juego: se obtienen de la copia que selecciones.

La conversión valida y comprime una biblioteca temporal dentro de `PoC Data` antes de activarla en `PoC Data/resources/`. Al añadir un juego se conservan los ya importados. Tras completar el cambio se retira la copia generada anterior; tus ISO, carpetas originales y guardados no se sobrescriben. El importador rechaza revisiones no compatibles e imágenes dañadas o incompletas; no descarga recursos faltantes.

### Dónde queda cada archivo

| Archivos | Ubicación junto al EXE |
| --- | --- |
| Recursos WebP/OGG y datos del motor | `PoC Data/resources/` |
| Guardados del remake | `PoC Data/saves/` |
| Ajustes | `PoC Data/content.cfg` |
| Herramientas y licencias | `PoC Data/tools/` |
| Extracción temporal | `PoC Data/temp/` y carpetas transitorias dentro de `PoC Data/` |
| Último error de importación | `PoC Data/import-last-error.log` |

**Mueve o respalda juntos `PowerOfChaos.exe` y `PoC Data`.** Las rutas relativas permiten cambiar de carpeta o unidad sin volver a importar. Usa una carpeta con permiso de escritura.

Al actualizar en la misma carpeta se copian los antiguos `saves/` adyacentes sin reemplazar guardados portables más recientes. También se migran los ajustes anteriores y se prepara una copia compacta de la biblioteca importada. Se mantiene la fuente antigua hasta verificar la nueva. Si cambias de carpeta, lleva el antiguo `saves/` junto al nuevo EXE antes de abrirlo por primera vez, o mueve tu `PoC Data` existente.

## Compatibilidad y límites actuales

Esta versión pública está orientada a **Windows PC**.

| Juego | Importaciones comprobadas | Comprobaciones del motor |
| --- | --- | --- |
| Yugi the Destiny | ISO y carpeta compatibles | Inicio independiente del título y duelo normal |
| Kaiba the Revenge | ISO y carpeta compatibles | Inicio independiente del título y duelo normal; perfiles compatibles sin necesitar Yugi |
| Joey the Passion | Carpeta compatible | Inicio independiente del título y duelo normal |

Falta validar de principio a fin una ISO completa de Joey; una imagen truncada se rechazó correctamente. La compatibilidad con otras revisiones y regiones sigue ampliándose.

Las reglas, la IA, la presentación y los tiempos siguen comparándose con los originales. Estas pruebas no certifican todos los duelos ni todas las cartas. Al informar de un fallo, indica juego, edición, origen de importación y pasos para reproducirlo; no adjuntes archivos originales del juego.

Los discos MSI/CAB compatibles se extraen con el 7-Zip incluido. Los medios Inno Setup requieren `innoextract` en `PATH`; para otros instaladores, instala tu copia por separado y selecciona su carpeta.

## Idiomas y voces

El selector controla el launcher y los textos disponibles del juego. La disponibilidad depende de la edición importada. `Data.dat` puede variar entre regiones y revisiones.

Los doblajes se detectan desde `Voice.dat`. Al cambiar de idioma se usa el doblaje correspondiente si está importado; de lo contrario, se conserva el principal. El selector no descarga voces.

Puedes añadir voces de otra copia compatible del mismo juego mediante las herramientas de código fuente:

```powershell
python -m pocx.import_games --base "datos-existentes" --voice "joey=C:\Mi copia de Joey\Voice.dat" --out "datos-nuevos"
```

Usa una carpeta de salida nueva para importaciones manuales. El launcher gestiona sus propias actualizaciones. Dos doblajes distintos del mismo juego e idioma se rechazan como conflicto.

## Ejecutar desde el código fuente

Requiere **Godot 4.7.2** y **Python 3.12 o posterior**. La compilación automática usa Python 3.13.

```powershell
git clone https://github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake.git
cd Yu-Gi-Oh-Power-of-Chaos-Remake
python -m pip install ./tools
godot --editor --path game
```

Ejecuta `game/project.godot` desde el editor e importa tus recursos. Si usas un entorno virtual de Python, abre Godot desde una consola con ese entorno activado. Las importaciones desde el código necesitan 7-Zip instalado en su ubicación habitual de Windows o disponible en `PATH`. El EXE publicado ya incluye las herramientas y el codificador de audio; no necesita FFmpeg.

Pruebas del importador con datos sintéticos, sin recursos originales:

```powershell
$env:PYTHONPATH = "tools"
python -m unittest discover -s tools/tests -p "test_*import.py" -v
```

## Compilaciones automáticas

El flujo [Launcher Windows](https://github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake/actions/workflows/build-windows.yml) genera una compilación con cada cambio en `main` y cada solicitud de cambios; también puede iniciarse manualmente. Las etiquetas que empiezan por `v` publican una versión preliminar con EXE, suma SHA-256 y manifiesto de compilación.

Cada compilación comprueba la política de archivos, ejecuta las pruebas sintéticas, crea una exportación limpia y verifica el conversor incluido. No necesita ni incorpora recursos originales. Las copias instaladas no se actualizan automáticamente.

## Estado del proyecto y avisos

Este es un proyecto independiente y no oficial, sin afiliación ni respaldo de los editores o titulares de los juegos originales. Los nombres identifican los títulos compatibles; los recursos y marcas pertenecen a sus respectivos titulares.

El tema musical del launcher, sus dos fondos externos de duelo y el icono propio pertenecen a este proyecto. Los marcos de juegos pendientes incluyen contornos vectoriales derivados de los logos originales; sus imágenes se cargan únicamente tras importar la copia del usuario.

El código incluye trabajo derivado de ingeniería inversa. Su procedencia y la licencia general siguen en revisión; no se ha asignado una licencia global al repositorio. Publicar estas fuentes no otorga derechos para redistribuir los recursos originales.

Cada componente de terceros conserva su licencia. Consulta [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) y **Licencias** en el launcher, incluidas las fuentes correspondientes de 7-Zip.
