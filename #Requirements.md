# Requirements

This document outlines all requirements and dependencies needed to run the AutoHotkey scripts in this repository.

## Essential Software

- **AutoHotkey**: Version 1.1.33+ (or v2.0+ for scripts using AHK v2 syntax)
  - Download from: [https://www.autohotkey.com/download/](https://www.autohotkey.com/download/)
  - Both Unicode 32-bit and 64-bit versions are supported

## Optional Dependencies

- **SoundPlayer**: For scripts that use sound notifications
- **ImageMagick**: For scripts that manipulate images
  - Download from: [https://imagemagick.org/script/download.php](https://imagemagick.org/script/download.php)
- **FFmpeg**: For scripts that process video or audio
  - Download from: [https://ffmpeg.org/download.html](https://ffmpeg.org/download.html)

## Windows Compatibility

These scripts have been tested and are known to work on:
- Windows 10 (all updates)
- Windows 11
- Windows 8.1

Some scripts may work on Windows 7, but this is no longer tested or supported.

## Setup Instructions

1. Install AutoHotkey
2. Clone or download this repository
3. Install any optional dependencies needed for specific scripts
4. Run scripts by double-clicking the .ahk files or set them to start with Windows

## Script-Specific Requirements

- `clipboard_manager.ahk`: Requires at least 100MB free RAM
- `screen_capture.ahk`: Requires administrative privileges for some features
- `window_manager.ahk`: Multi-monitor setup recommended for full functionality

## Troubleshooting

If you encounter any issues:
1. Ensure you're running the latest version of AutoHotkey
2. Check that you have administrative privileges if the script requires them
3. Verify that any external programs referenced in the scripts are installed and accessible in your PATH
4. For scripts that interact with specific applications, ensure those applications are installed
