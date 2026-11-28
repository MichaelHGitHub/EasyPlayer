import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/player_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../models/media_item.dart';

class MediaDetailsDialog extends StatefulWidget {
  final MediaItem item;
  final PlayerController playerController;
  final String? coverPath;

  const MediaDetailsDialog({
    super.key,
    required this.item,
    required this.playerController,
    this.coverPath,
  });

  static Future<void> show(
    BuildContext context, {
    required MediaItem item,
    required PlayerController playerController,
    String? coverPath,
  }) {
    return showDialog(
      context: context,
      builder: (context) => MediaDetailsDialog(
        item: item,
        playerController: playerController,
        coverPath: coverPath,
      ),
    );
  }

  @override
  State<MediaDetailsDialog> createState() => _MediaDetailsDialogState();
}

class _MediaDetailsDialogState extends State<MediaDetailsDialog> {
  int? _fileSizeBytes;
  DateTime? _lastModified;
  String? _resolvedCoverPath;

  @override
  void initState() {
    super.initState();
    _fetchExtraFileStats();
  }

  Future<void> _fetchExtraFileStats() async {
    int? size = widget.item.fileSizeBytes > 0 ? widget.item.fileSizeBytes : null;
    DateTime? modified;
    String? cover = widget.coverPath ?? widget.item.coverArtPath;

    try {
      final file = File(widget.item.filePath);
      if (await file.exists()) {
        size ??= await file.length();
        modified = await file.lastModified();
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _fileSizeBytes = size;
        _lastModified = modified;
        _resolvedCoverPath = cover;
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '—';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(i == 0 ? 0 : 2)} ${suffixes[i]}';
  }

  String _formatDuration(Duration d) {
    if (d == Duration.zero) return '—';
    final int hours = d.inHours;
    final int minutes = d.inMinutes % 60;
    final int seconds = d.inSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dt) {
    final String year = dt.year.toString();
    final String month = dt.month.toString().padLeft(2, '0');
    final String day = dt.day.toString().padLeft(2, '0');
    final String hour = dt.hour.toString().padLeft(2, '0');
    final String minute = dt.minute.toString().padLeft(2, '0');
    final String second = dt.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final MediaItem item = widget.item;
    final bool isVideo = item.isVideo;

    final Duration effectiveDuration =
        (item.duration != null && item.duration != Duration.zero)
            ? item.duration!
            : widget.playerController.duration;

    // Retrieve media_kit tracks information for extra codec details if playing
    final tracks = widget.playerController.player.state.tracks;
    String? videoCodecInfo;
    String? audioCodecInfo;
    String? resolutionInfo;

    for (final videoTrack in tracks.video) {
      if (videoTrack.id != 'no' && videoTrack.id != 'auto') {
        if (videoTrack.w != null && videoTrack.h != null && videoTrack.w! > 0) {
          resolutionInfo = '${videoTrack.w} × ${videoTrack.h}';
        }
        if (videoTrack.codec != null && videoTrack.codec!.isNotEmpty) {
          videoCodecInfo = videoTrack.codec;
        }
      }
    }

    for (final audioTrack in tracks.audio) {
      if (audioTrack.id != 'no' && audioTrack.id != 'auto') {
        if (audioTrack.codec != null && audioTrack.codec!.isNotEmpty) {
          audioCodecInfo = audioTrack.codec;
          if (audioTrack.channels != null && audioTrack.channels!.isNotEmpty) {
            final int? ch = int.tryParse(audioTrack.channels!);
            if (ch != null && ch > 0) {
              audioCodecInfo = '$audioCodecInfo ($ch ch)';
            } else {
              audioCodecInfo = '$audioCodecInfo (${audioTrack.channels})';
            }
          }
        }
      }
    }

    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(20),
      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isVideo ? const Color(0xFF4F46E5) : const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isVideo ? Icons.movie_outlined : Icons.music_note_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isVideo ? l10n.videoDetails : l10n.audioDetails,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.extension.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Art image thumbnail if available
              if (!isVideo && _resolvedCoverPath != null && File(_resolvedCoverPath!).existsSync()) ...[
                Center(
                  child: Container(
                    height: 140,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.file(
                      File(_resolvedCoverPath!),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],

              // Full Track Name / File Name (Selectable, multi-line)
              _buildDetailCard(
                label: l10n.fileName,
                content: SelectableText(
                  item.fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Title metadata (if different from file name)
              if (item.title != null && item.title!.isNotEmpty && item.title != item.fileName) ...[
                _buildDetailRow(l10n.titleLabel, item.title!),
                const SizedBox(height: 8),
              ],

              // Artist / Author (for audio)
              if (!isVideo) ...[
                _buildDetailRow(l10n.artistLabel, item.artist ?? '—'),
                const SizedBox(height: 8),
                _buildDetailRow(l10n.albumLabel, item.album ?? '—'),
                const SizedBox(height: 8),
              ],

              // Video specific resolution & video codec
              if (isVideo) ...[
                if (resolutionInfo != null) ...[
                  _buildDetailRow(l10n.videoResolutionLabel, resolutionInfo),
                  const SizedBox(height: 8),
                ],
                if (videoCodecInfo != null) ...[
                  _buildDetailRow(l10n.videoCodecLabel, videoCodecInfo.toUpperCase()),
                  const SizedBox(height: 8),
                ],
              ],

              // Audio codec (if available)
              if (audioCodecInfo != null) ...[
                _buildDetailRow(l10n.audioCodecLabel, audioCodecInfo.toUpperCase()),
                const SizedBox(height: 8),
              ],

              // Duration & File Size
              Row(
                children: [
                  Expanded(
                    child: _buildDetailRow(l10n.durationLabel, _formatDuration(effectiveDuration)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDetailRow(
                      l10n.fileSizeLabel,
                      _fileSizeBytes != null ? _formatFileSize(_fileSizeBytes!) : '—',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Date Modified
              if (_lastModified != null) ...[
                _buildDetailRow(l10n.dateModifiedLabel, _formatDateTime(_lastModified!)),
                const SizedBox(height: 8),
              ],

              // File Path with copy button
              _buildDetailCard(
                label: l10n.filePathLabel,
                content: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SelectableText(
                        item.filePath,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16, color: Color(0xFF818CF8)),
                      tooltip: l10n.copyPath,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: item.filePath));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.pathCopied),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.close,
            style: const TextStyle(color: Color(0xFF818CF8), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: SelectableText(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({required String label, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          content,
        ],
      ),
    );
  }
}
