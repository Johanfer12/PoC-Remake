# Yu-Gi-Oh! Power of Chaos Remake · Android sources

**English** | [Español](README.es.md) | [Windows launcher](https://github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake/tree/main)

The Windows launcher offers **Extract for PC** and **Create APK**. It includes the Android sources and prepares the tools automatically, without installing Python or configuring SDK/JDK separately. APKs retain touch controls, scrolling, dragging and native tribute selection, with the same icon as PC. All three games have their own widescreen duel backgrounds.

Everything stays in **`PoC Data/android/`**: reusable tools, signing key, build logs and APKs. Joey connections have been tested between **PC and PC**, and between **PC and Android**. This is still an alpha; feedback and bug reports are welcome.

This branch contains sources, without original game resources or private signing keys.

## Use with the Windows launcher

Download the EXE from [Releases](https://github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake/releases), select your games or reuse your prepared library, then click **Create APK**. On first use accept the SDK license; the launcher downloads and verifies the official tools. Cloning this branch is not required.

The APK appears in `PoC Data/android/apks/`. Keep and back up `PoC Data`, including your local signing key, to update your APKs. See [Build your Android APK](https://github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake/tree/main#build-your-android-apk).

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
