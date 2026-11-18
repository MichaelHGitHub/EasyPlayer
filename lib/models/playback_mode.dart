enum PlayMode {
  single,
  sequential,
  shuffle,
}

enum RepeatMode {
  none,
  track,
  folder,
}

enum AspectRatioMode {
  fit, // Fit / Letterbox
  fill, // Fill / Crop
  stretch, // Stretch to viewport
  fixed16_9, // 16:9
  fixed4_3, // 4:3
}

enum OrientationLock {
  auto,
  landscape,
  portrait,
}

enum SubtitleEncoding {
  auto,
  utf8,
  gbk,
  big5,
  utf16,
}

enum SleepTimerMode {
  off,
  m15,
  m30,
  m45,
  m60,
  custom,
  endOfTrack,
}
