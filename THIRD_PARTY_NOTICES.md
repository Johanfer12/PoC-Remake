# Third-party notices

## Audio conversion

The Windows converter uses SoundFile 0.13.1 (BSD-3-Clause), CFFI (MIT) and
libsndfile 1.2.2 (LGPL-2.1-or-later), including Vorbis/OGG codec components.
The packaged launcher's Licenses folder includes their notices, the matching
libsndfile 1.2.2 source archive and the Xiph codec copyright notices.

Sources: https://github.com/bastibe/python-soundfile/tree/0.13.1,
https://github.com/libsndfile/libsndfile/tree/1.2.2,
https://github.com/xiph/vorbis/tree/v1.3.7,
https://github.com/xiph/ogg/tree/v1.3.5.

## Android tools downloaded by the launcher

The optional APK builder prepares tools in `PoC Data/android/tools/`, separate
from game resources. Downloads are from the official upstream releases and
verified against pinned SHA-256 hashes. Tool archives are removed after extraction;
their bundled notices and license files remain with the installed tools.

- Godot 4.7.2 and matching export templates: MIT and upstream third-party notices.
  https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable
- Eclipse Temurin OpenJDK 21: GPLv2 with Classpath Exception and bundled notices.
  https://adoptium.net/about/ and https://openjdk.org/legal/gplv2+ce.html
- Google Android SDK Build Tools 35.0.1 and Platform Tools 37.0.1: Android SDK
  license and included notices. The launcher links the terms and requires acceptance
  before initial setup: https://developer.android.com/studio/terms

No developer signing key is distributed. A persistent debug key is generated
locally in `PoC Data/android/signing/` for the user's own builds.

## Feather icons

The SVG icons embedded in game/scenes/launcher/launcher_controls.gd are based on
Feather (volume-2, volume-x, settings, x, check).
Upstream: https://github.com/feathericons/feather
License source: https://github.com/feathericons/feather/blob/main/LICENSE

The following license applies only to those icons, not to the rest of this project.

The MIT License (MIT)

Copyright (c) 2013-2023 Cole Bemis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
