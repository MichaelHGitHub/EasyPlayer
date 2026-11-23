import 'dart:typed_data';
import 'package:easy_player/core/utils/wav_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('WavParser parses 16kHz mono WAV correctly', () {
    // Construct a valid 16kHz mono 16-bit PCM WAV file in memory
    final sampleCount = 1600; // 0.1 seconds of audio
    final dataSize = sampleCount * 2;
    final fileSize = 44 + dataSize;
    final bytes = Uint8List(fileSize);
    final bd = ByteData.sublistView(bytes);

    // RIFF header
    bytes.setRange(0, 4, 'RIFF'.codeUnits);
    bd.setUint32(4, fileSize - 8, Endian.little);
    bytes.setRange(8, 12, 'WAVE'.codeUnits);

    // fmt  subchunk
    bytes.setRange(12, 16, 'fmt '.codeUnits);
    bd.setUint32(16, 16, Endian.little); // chunkSize = 16
    bd.setUint16(20, 1, Endian.little); // audioFormat = 1 (PCM)
    bd.setUint16(22, 1, Endian.little); // numChannels = 1
    bd.setUint32(24, 16000, Endian.little); // sampleRate = 16000
    bd.setUint32(28, 32000, Endian.little); // byteRate
    bd.setUint16(32, 2, Endian.little); // blockAlign
    bd.setUint16(34, 16, Endian.little); // bitsPerSample = 16

    // data subchunk
    bytes.setRange(36, 40, 'data'.codeUnits);
    bd.setUint32(40, dataSize, Endian.little);

    // Fill sample values (sine wave-like values)
    for (int i = 0; i < sampleCount; i++) {
      bd.setInt16(44 + i * 2, (i * 10) % 30000, Endian.little);
    }

    final samples = WavParser.parseWavBytes(bytes);
    expect(samples, isNotNull);
    expect(samples!.length, sampleCount);
  });
}
