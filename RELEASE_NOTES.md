## v0.1.0-alpha.17

- Fresh Android installations now open the resource-pack selector instead of stopping at the old missing-data message. Select your existing PCK from Downloads; no new resource pack is required.
- The Windows launcher includes the corrected Android APK (versionCode 21). Its package and signing certificate are unchanged, so it can update the previous public APK in place.
- Added a first-run regression that starts the configured main scene with empty app storage, covering the boot path missed by the previous direct importer checks.

Install the new APK over the existing app, open it and tap **Select .pck resource pack**. Compatible updates preserve imported resources and saves. The focused startup checks run on the build computer; this APK has not yet been verified on a physical Android device.
