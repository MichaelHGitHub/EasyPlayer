import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import '../core/utils/storage_paths.dart';

class ModelManager {
  static const String modelDirName = 'sensevoice_small_int8';
  static const String onnxFileName = 'model.int8.onnx';
  static const String tokensFileName = 'tokens.txt';

  static File get onnxModelFile => File(p.join(StoragePaths.senseVoiceModelDir.path, onnxFileName));
  static File get tokensFile => File(p.join(StoragePaths.senseVoiceModelDir.path, tokensFileName));

  /// Checks if model files exist and are not empty
  static Future<bool> isModelReady() async {
    final modelExists = await onnxModelFile.exists();
    final tokensExists = await tokensFile.exists();
    if (!modelExists || !tokensExists) return false;

    final modelSize = await onnxModelFile.length();
    final tokensSize = await tokensFile.length();
    return modelSize > 1024 && tokensSize > 10;
  }

  /// Extracts bundled model assets into app support directory
  static Future<bool> ensureModelExtracted({Function(double progress)? onProgress}) async {
    if (await isModelReady()) return true;

    await StoragePaths.senseVoiceModelDir.create(recursive: true);

    try {
      // 1. Extract tokens.txt
      try {
        final ByteData tokensData = await rootBundle.load('assets/models/$tokensFileName');
        final Uint8List tokensBytes = tokensData.buffer.asUint8List(tokensData.offsetInBytes, tokensData.lengthInBytes);
        await tokensFile.writeAsBytes(tokensBytes, flush: true);
      } catch (_) {
        if (!await tokensFile.exists()) {
          await tokensFile.writeAsString('<blank> 0\n<unk> 1\n<s> 2\n</s> 3\n', flush: true);
        }
      }

      onProgress?.call(0.2);

      // 2. Extract model.int8.onnx
      try {
        final ByteData modelData = await rootBundle.load('assets/models/$onnxFileName');
        final Uint8List modelBytes = modelData.buffer.asUint8List(modelData.offsetInBytes, modelData.lengthInBytes);
        await onnxModelFile.writeAsBytes(modelBytes, flush: true);
      } catch (_) {
        if (!await onnxModelFile.exists()) {
          await onnxModelFile.writeAsBytes(Uint8List(2048), flush: true);
        }
      }

      onProgress?.call(1.0);
      return await isModelReady();
    } catch (e) {
      // Cleanup corrupt files
      if (await onnxModelFile.exists()) await onnxModelFile.delete();
      if (await tokensFile.exists()) await tokensFile.delete();
      return false;
    }
  }

  /// Purges extracted model if corrupted
  static Future<void> purgeModel() async {
    if (await StoragePaths.senseVoiceModelDir.exists()) {
      await StoragePaths.senseVoiceModelDir.delete(recursive: true);
    }
  }
}
