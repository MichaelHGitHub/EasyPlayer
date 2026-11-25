# EasyPlayer

**EasyPlayer** is a modern, cross-platform media player for Windows PC (x64) and Android (ARM64), engineered and developed by **PandaSoft**.

EasyPlayer seamlessly plays all popular audio and video formats, combining an intuitive folder-based queue player with an on-device Automatic Speech Recognition (ASR) engine that generates synchronized subtitles and an interactive, clickable transcript without cloud inference. The speech model downloads on the first transcription; subsequent transcription works offline.

---

## 📦 Downloads & Release Builds

* **Android build**: [app-release.apk](https://github.com/MichaelHGitHub/EasyPlayer/blob/main/Release/Android/app-release.apk)
* **Windows build**: [EasyPlay_x64_Release.zip](https://github.com/MichaelHGitHub/EasyPlayer/blob/main/Release/Windows/EasyPlay_x64_Release.zip)

---

## 🌟 Key Features

*   **Universal Format Support**: Powered by `libmpv` (FFmpeg backend via `media_kit`).
    *   **Audio**: MP3, FLAC, WAV, AAC, M4A, OGG, Opus, WMA, ALAC, AIFF, APE.
    *   **Video**: MP4, MKV, WebM, AVI, MOV, FLV, WMV, TS, 3GP.
*   **On-Device, Offline Speech-to-Text (ASR)**:
    *   Zero server dependencies; speech recognition runs 100% locally on-device.
    *   High-accuracy multilingual support for **English** and **Simplified Chinese (简体中文)** with code-switching support.
    *   Quantized SenseVoice-Small INT8 model (~226 MiB) downloads on first use and is stored locally for offline transcription.
*   **Instant Playback & On-Demand Transcription**:
    *   Audio and video start playing immediately without delay.
    *   Toggle Closed Captions (CC) on-demand to stream progressive subtitles in the background with immediate task cancellation on track skip.
    *   Generated transcripts are cached locally (keyed by Fast Hybrid Hash in <5ms) for instant recall.
*   **Subtitle Flexibility & Sidecar Support**:
    *   Supports embedded tracks (MKV/MP4), external sidecar files (`.srt`/`.vtt`), and auto-generated captions.
*   **Audio Metadata & Album Art**:
    *   Extracts ID3/Vorbis tags and displays album art with a responsive waveform visualizer for audio files.
*   **Interactive Transcript & Subtitle Overlay**:
    *   **Click-to-Seek**: Tap or click any sentence in the transcript to jump immediately to that point in the media.
    *   **Smart Auto-Scroll**: Follows active speech during playback, with manual browse pause and re-sync.
    *   **On-Video Captions**: High-contrast, customizable subtitle overlay.
    *   **Inline Editing & Export**: Correct recognition results on the fly; export transcripts to `.srt`, `.vtt`, or `.txt`.
*   **Folder Queue & Navigation**:
    *   Integrated directory browser to play entire directories seamlessly.
    *   Multiple playback modes: Single, Sequential (Play Next), Shuffle, and Repeat (Track / Folder) with graceful auto-skip on corrupted files.
*   **Study & Listening Ergonomics**:
    *   **A-B Repeat Looping**: Set custom loop boundaries or loop single sentences directly from the transcript.
    *   **Sleep Timer**: Auto-off timer with a smooth 15s audio fade-out and system WakeLock release.
    *   **Bilingual UI**: Fully localized in English and Simplified Chinese (简体中文).
*   **Playback Memory (Resume Playback)**:
    *   Automatically remembers playback position and volume for every file.

---

## 🎨 Branding & Identity

*   **Developer**: **PandaSoft**
*   **Android Package**: `com.pandasoft.easyplayer`
*   **Windows Package**: `PandaSoft.EasyPlayer`
*   **Artwork Assets**:
    *   All official icons and high-resolution logo assets are maintained in [`artwork/`](artwork/).
    *   See [`artwork/README.md`](artwork/README.md) for platform-specific asset mapping (Windows ICOs and Android mipmaps).

---

## 📚 Documentation & Specifications

*   [**Functional Specification**](docs/Functional_Specification.md): Detailed functional requirements, UI/UX behaviors, hotkeys, and platform specifications.
*   [**Architecture & Development Plan**](docs/Architecture_and_Plan.md): Technical architecture, data flow diagrams, technology stack, and phased implementation roadmap.

---

## 🛠️ Technology Stack

*   **UI Framework**: Flutter (Dart) for Windows Desktop & Android.
*   **Playback Engine**: `media_kit` + `media_kit_video` (`libmpv` / FFmpeg).
*   **Speech Engine**: `sherpa_onnx` (SenseVoice-Small INT8 ~226 MiB) on background Dart Isolate with VAD.
*   **Audio Pipeline**: Native demuxer / resampler pipeline (16kHz 16-bit mono PCM).
*   **Cache & Storage**: Local app data storage with Fast Hybrid Hashing ($<5\text{ ms}$).

---

## 📄 License & Attribution

Copyright © 2026 PandaSoft. All rights reserved.
