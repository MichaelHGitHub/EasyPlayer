import 'dart:typed_data';

class WavParser {
  /// Parses standard PCM WAV file bytes into 16kHz mono Float32List samples normalized to [-1.0, 1.0].
  static Float32List? parseWavBytes(Uint8List bytes) {
    if (bytes.length < 44) return null;
    final ByteData bd = ByteData.sublistView(bytes);

    final String riff = String.fromCharCodes(bytes.sublist(0, 4));
    final String wave = String.fromCharCodes(bytes.sublist(8, 12));
    if (riff != 'RIFF' || wave != 'WAVE') return null;

    int offset = 12;
    int audioFormat = 1;
    int numChannels = 1;
    int sampleRate = 16000;
    int bitsPerSample = 16;
    int dataOffset = -1;
    int dataSize = 0;

    while (offset + 8 <= bytes.length) {
      final String subchunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final int chunkSize = bd.getUint32(offset + 4, Endian.little);
      offset += 8;

      if (subchunkId == 'fmt ') {
        audioFormat = bd.getUint16(offset, Endian.little);
        numChannels = bd.getUint16(offset + 2, Endian.little);
        sampleRate = bd.getUint32(offset + 4, Endian.little);
        bitsPerSample = bd.getUint16(offset + 14, Endian.little);
        offset += chunkSize;
      } else if (subchunkId == 'data') {
        dataOffset = offset;
        dataSize = chunkSize;
        break;
      } else {
        offset += chunkSize;
      }
    }

    if (dataOffset == -1) return null;
    dataSize = dataSize.clamp(0, bytes.length - dataOffset);
    if (dataSize <= 0) return null;
    if (audioFormat != 1 || bitsPerSample != 16) return null;

    final int numSamples = dataSize ~/ (2 * numChannels);
    final Float32List mono = Float32List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      int sampleIndex = dataOffset + i * 2 * numChannels;
      int sample = bd.getInt16(sampleIndex, Endian.little);
      if (numChannels > 1) {
        int sampleRight = bd.getInt16(sampleIndex + 2, Endian.little);
        sample = (sample + sampleRight) ~/ 2;
      }
      mono[i] = (sample / 32768.0).clamp(-1.0, 1.0);
    }

    if (sampleRate == 16000) return mono;

    final double ratio = sampleRate / 16000.0;
    final int targetLength = (numSamples / ratio).floor();
    final Float32List resampled = Float32List(targetLength);
    for (int i = 0; i < targetLength; i++) {
      final double srcIdx = i * ratio;
      final int idx = srcIdx.floor();
      resampled[i] = mono[idx.clamp(0, numSamples - 1)];
    }
    return resampled;
  }
}
