# Yu-Gi-Oh! Power of Chaos Remake · Android sources

**English** | [Español](README.es.md) | [Windows launcher](https://github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake/tree/main)

The Windows launcher now offers **Extract for PC** and **Create APK**. An APK
built with these Android sources retains the mobile touch controls, scrolling,
dragging and native tribute selection. The APK is saved beside the launcher.

This branch supplies the Android engine and build scripts. **Original game data,
SDK/JDK, signing keys and a prebuilt game APK are not included.** Set up the local
tools and supply your compatible games. Physical device testing is still pending.

## Use with the Windows launcher

Follow [Android build setup in the main README](https://github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake/tree/main#android-build-setup).
Clone this branch into a separate directory; do not copy it over the Windows source.
Your own persistent debug keystore identifies your locally built APKs. For an
update, also configure your previous APK so the builder checks its certificate.
A first installation accepts `--first-build`; the output certificate must still
match the configured key. Never publish the key or converted game resources.

## Direct build

Run from this checkout after preparing compact data from your games:

```powershell
python tools/android/build_apk.py --godot <godot_console.exe> --sdk <Android-SDK> --debug-keystore <your-debug.keystore> --first-build --data <compact-data> --work <new-work-directory> --output <new.apk>
```

For an update replace `--first-build` with `--previous-apk <your-previous.apk>`.
The builder checks bundled game startup, signature, certificate, ZIP integrity,
PCK hash and 16 KB alignment. It writes its receipt and logs to the work directory.
Game code is in `game/`; generated export projects are not source code.

These are unofficial experimental sources derived in part through reverse
engineering. Fidelity, hardware support and project-wide licensing remain under
review. See [third-party notices](THIRD_PARTY_NOTICES.md).
