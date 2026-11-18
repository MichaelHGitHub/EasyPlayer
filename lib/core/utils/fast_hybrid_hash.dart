import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class FastHybridHash {
  static const int chunkSize = 65536; // 64KB
  static const int threshold = chunkSize * 3; // 192KB

  /// Calculates Fast Hybrid Hash: SHA-256(size + first64K + mid64K + last64K)
  /// Runs in < 5ms even on multi-gigabyte files.
  static Future<String> compute(File file) async {
    final int fileSize = await file.length();
    final RandomAccessFile raf = await file.open(mode: FileMode.read);

    try {
      final BytesBuilder builder = BytesBuilder(copy: false);

      // 8-byte big-endian file size
      final ByteData sizeBytes = ByteData(8)..setInt64(0, fileSize, Endian.big);
      builder.add(sizeBytes.buffer.asUint8List());

      if (fileSize <= threshold) {
        // For small files <= 192KB, read the entire file
        final Uint8List allBytes = await raf.read(fileSize);
        builder.add(allBytes);
      } else {
        // 1. First 64KB
        await raf.setPosition(0);
        final Uint8List firstChunk = await raf.read(chunkSize);
        builder.add(firstChunk);

        // 2. Middle 64KB
        final int midOffset = (fileSize ~/ 2) - (chunkSize ~/ 2);
        await raf.setPosition(midOffset);
        final Uint8List midChunk = await raf.read(chunkSize);
        builder.add(midChunk);

        // 3. Last 64KB
        final int lastOffset = fileSize - chunkSize;
        await raf.setPosition(lastOffset);
        final Uint8List lastChunk = await raf.read(chunkSize);
        builder.add(lastChunk);
      }

      final Digest digest = sha256.convert(builder.toBytes());
      return digest.toString();
    } finally {
      await raf.close();
    }
  }

  /// Synchronous version for testing or isolate use
  static String computeSync(File file) {
    final int fileSize = file.lengthSync();
    final RandomAccessFile raf = file.openSync(mode: FileMode.read);

    try {
      final BytesBuilder builder = BytesBuilder(copy: false);

      final ByteData sizeBytes = ByteData(8)..setInt64(0, fileSize, Endian.big);
      builder.add(sizeBytes.buffer.asUint8List());

      if (fileSize <= threshold) {
        final Uint8List allBytes = raf.readSync(fileSize);
        builder.add(allBytes);
      } else {
        raf.setPositionSync(0);
        final Uint8List firstChunk = raf.readSync(chunkSize);
        builder.add(firstChunk);

        final int midOffset = (fileSize ~/ 2) - (chunkSize ~/ 2);
        raf.setPositionSync(midOffset);
        final Uint8List midChunk = raf.readSync(chunkSize);
        builder.add(midChunk);

        final int lastOffset = fileSize - chunkSize;
        raf.setPositionSync(lastOffset);
        final Uint8List lastChunk = raf.readSync(chunkSize);
        builder.add(lastChunk);
      }

      final Digest digest = sha256.convert(builder.toBytes());
      return digest.toString();
    } finally {
      raf.closeSync();
    }
  }
}
