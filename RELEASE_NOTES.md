## v0.1.0-alpha.16

- Android now shares the PC launcher's display, FPS, simulation speed, quick-play and reviewed Spanish card-text options, while retaining touch scrolling, dragging and selection of one or two tribute monsters.
- **Create APK** prepares an unchanged, consistently signed public Android APK together with a private resource PCK. Import your PCK once on Android; no account, SDK/JDK setup or personal signing key is needed for the normal launcher workflow.
- Android can check GitHub for compatible public updates and open the APK download. Confirm installation through Android without uninstalling to keep resources, preferences and saves.
- One public APK serves all players; game resources stay in each player's separately imported PCK. Existing custom signing configurations remain available, and the updater reports incompatible signing keys before offering a replacement.
- Expanded Unicode regression coverage for reviewed Spanish card names, descriptions and JSON cache round trips.

Build-computer checks cover resource import, persistence, update metadata and touch controls. The new Android import/update workflow has not yet been verified on a physical device.

## Download

Download **PowerOfChaos.exe** and keep your existing **PoC Data** folder. For Android, **Create APK** places both the APK and private resource PCK in **PoC Data/android/apks/**. Original game resources and private signing keys are not published.
