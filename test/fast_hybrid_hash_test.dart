import 'dart:io';
import 'package:easy_player/core/utils/fast_hybrid_hash.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FastHybridHash Tests', () {
    test('computes deterministic hash for small file', () async {
      final tempDir = await Directory.systemTemp.createTemp('ep_test_');
      final tempFile = File('${tempDir.path}/small.txt');
      await tempFile.writeAsString('Hello EasyPlayer by PandaSoft!');

      final String hash1 = await FastHybridHash.compute(tempFile);
      final String hash2 = await FastHybridHash.compute(tempFile);

      expect(hash1.length, 64); // SHA-256 hex string length
      expect(hash1, equals(hash2));

      await tempDir.delete(recursive: true);
    });

    test('computes deterministic hash for large file (> 192KB)', () async {
      final tempDir = await Directory.systemTemp.createTemp('ep_test_large_');
      final tempFile = File('${tempDir.path}/large.bin');

      // Create a 300KB dummy file
      final bytes = List<int>.generate(300 * 1024, (i) => i % 256);
      await tempFile.writeAsBytes(bytes);

      final String hash1 = await FastHybridHash.compute(tempFile);
      final String hash2 = await FastHybridHash.compute(tempFile);

      expect(hash1.length, 64);
      expect(hash1, equals(hash2));

      await tempDir.delete(recursive: true);
    });
  });
}
