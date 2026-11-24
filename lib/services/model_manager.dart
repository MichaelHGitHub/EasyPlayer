import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import '../core/utils/storage_paths.dart';

class ModelManager {
  static const String modelDirName = 'sensevoice_small_int8';
  static const String onnxFileName = 'model.int8.onnx';
  static const String tokensFileName = 'tokens.txt';
  static const int _modelSize = 237115547;
  static const String _modelSha256 = '12ca1a2ae7ecf3e0019ef2822307ee0b5cadc9196569e379b4c4026f8205276d';
  static const String _modelUrl =
      'https://huggingface.co/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2025-09-09/resolve/355f4d4884d8afd08aef04b9007a8556d7b463b2/model.int8.onnx';

  static File get onnxModelFile => File(p.join(StoragePaths.senseVoiceModelDir.path, onnxFileName));
  static File get tokensFile => File(p.join(StoragePaths.senseVoiceModelDir.path, tokensFileName));
  static File get _partialModelFile => File('${onnxModelFile.path}.part');

  /// Checks if the downloaded model and bundled vocabulary are available.
  static Future<bool> isModelReady() async {
    final modelExists = await onnxModelFile.exists();
    final tokensExists = await tokensFile.exists();
    if (!modelExists || !tokensExists) return false;

    final modelSize = await onnxModelFile.length();
    final tokensSize = await tokensFile.length();
    return modelSize == _modelSize && tokensSize > 10;
  }

  /// Downloads the model on first use and extracts the small bundled vocabulary.
  static Future<void> ensureModelAvailable({
    Function(double progress)? onProgress,
    bool Function()? isCancelled,
  }) async {
    if (await isModelReady()) return;

    await StoragePaths.senseVoiceModelDir.create(recursive: true);

    try {
      if (!await tokensFile.exists() || await tokensFile.length() <= 10) {
        final ByteData tokensData = await rootBundle.load('assets/models/$tokensFileName');
        final Uint8List tokensBytes = tokensData.buffer.asUint8List(tokensData.offsetInBytes, tokensData.lengthInBytes);
        await tokensFile.writeAsBytes(tokensBytes, flush: true);
      }

      if (isCancelled?.call() ?? false) {
        throw const ModelDownloadCancelledException();
      }

      if (await onnxModelFile.exists() && await onnxModelFile.length() != _modelSize) {
        await onnxModelFile.delete();
      }

      if (!await onnxModelFile.exists()) {
        await _downloadModel(onProgress: onProgress, isCancelled: isCancelled);
      }
    } catch (_) {
      if (await _partialModelFile.exists()) {
        await _partialModelFile.delete();
      }
      rethrow;
    }
  }

  static Future<void> _downloadModel({
    Function(double progress)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
    var downloadedBytes = 0;
    var lastReportedPercent = -1;

    try {
      onProgress?.call(0);
      final request = await client.getUrl(Uri.parse(_modelUrl));
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Model server returned HTTP ${response.statusCode}.');
      }
      if (response.contentLength >= 0 && response.contentLength != _modelSize) {
        throw const HttpException('Model server returned an unexpected file size.');
      }

      final outputFile = await _partialModelFile.open(mode: FileMode.write);
      try {
        await for (final chunk in response) {
          if (isCancelled?.call() ?? false) {
            throw const ModelDownloadCancelledException();
          }

          downloadedBytes += chunk.length;
          if (downloadedBytes > _modelSize) {
            throw const HttpException('Downloaded model exceeds the expected file size.');
          }

          await outputFile.writeFrom(chunk);

          final percent = (downloadedBytes * 100 / _modelSize).floor();
          if (percent != lastReportedPercent) {
            lastReportedPercent = percent;
            onProgress?.call(downloadedBytes / _modelSize);
          }
        }
        await outputFile.flush();
      } finally {
        await outputFile.close();
      }

      if (isCancelled?.call() ?? false) {
        throw const ModelDownloadCancelledException();
      }
      if (downloadedBytes != _modelSize) {
        throw const HttpException('Downloaded model has an unexpected file size.');
      }
      final digest = await sha256.bind(_partialModelFile.openRead()).first;
      if (isCancelled?.call() ?? false) {
        throw const ModelDownloadCancelledException();
      }
      if (digest.toString() != _modelSha256) {
        throw const HttpException('Downloaded model failed its integrity check.');
      }

      await _partialModelFile.rename(onnxModelFile.path);
      onProgress?.call(1);
    } catch (_) {
      if (await _partialModelFile.exists()) {
        await _partialModelFile.delete();
      }
      rethrow;
    } finally {
      client.close(force: true);
    }
  }

  /// Purges extracted model if corrupted
  static Future<void> purgeModel() async {
    if (await StoragePaths.senseVoiceModelDir.exists()) {
      await StoragePaths.senseVoiceModelDir.delete(recursive: true);
    }
  }
}

class ModelDownloadCancelledException implements Exception {
  const ModelDownloadCancelledException();
}
