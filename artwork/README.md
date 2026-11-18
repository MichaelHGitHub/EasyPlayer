# PandaSoft Artwork & Brand Assets for EasyPlayer

This directory contains the official brand assets, application icons, and logo graphics for **EasyPlayer**, developed by **PandaSoft**.

## Asset Inventory

| File | Dimensions | Format / Color Depth | Target Usage |
| :--- | :--- | :--- | :--- |
| `logo_transparent.png` | 1024 x 1024 | PNG (RGBA, 32-bit) | High-res master logo, Android adaptive icon foreground, in-app About screen, splash screens |
| `logo_no_bg.png` | 1024 x 1024 | PNG (RGBA, 32-bit) | Secondary master logo (transparent background) for marketing and documentation |
| `logo_256x256.ico` | 256 x 256 | Windows ICO (32-bit) | Primary Windows executable icon (`app.ico`), High-DPI desktop shortcuts, installer packaging |
| `logo_108x108.ico` | 108 x 108 | Windows ICO (32-bit) | Android adaptive icon standard grid baseline (108dp base canvas) |
| `logo_48x48.ico` | 48 x 48 | Windows ICO (32-bit) | Windows File Explorer Medium / Large icon display |
| `logo_32x32.ico` | 32 x 32 | Windows ICO (32-bit) | Windows taskbar icon, standard DPI desktop shortcuts |
| `logo_16x16.ico` | 16 x 16 | Windows ICO (32-bit) | Windows title bar icon, notification area / system tray icon, Details view |

---

## Platform Deployment Mapping

### 1. Windows Desktop (`windows/runner/resources/`)
- **Main Executable Icon**: Compile `logo_256x256.ico` (with embedded multi-resolution mipmaps or directly) as `app_icon.ico`.
- **Title Bar & System Tray**: Use `logo_16x16.ico` and `logo_32x32.ico` for crisp rendering at standard DPI.

### 2. Android (`android/app/src/main/res/`)
- **Adaptive Launcher Icon (`mipmap-*`)**:
  - `mipmap-mdpi`: 48 x 48 px
  - `mipmap-hdpi`: 72 x 72 px
  - `mipmap-xhdpi`: 96 x 96 px
  - `mipmap-xxhdpi`: 144 x 144 px
  - `mipmap-xxxhdpi`: 192 x 192 px
  - Generated from `logo_transparent.png` (using `logo_108x108` scaling ratios for safe zone margins).
- **In-App Branding**:
  - `drawable/logo_transparent.png`: Placed in drawables for the Player "About PandaSoft" dialog and media notifications.
