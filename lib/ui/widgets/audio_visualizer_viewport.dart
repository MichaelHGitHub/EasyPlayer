import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../../controllers/caption_controller.dart';
import '../../controllers/player_controller.dart';
import '../../core/utils/storage_paths.dart';
import '../../models/media_item.dart';
import 'subtitle_overlay.dart';

class AudioVisualizerViewport extends StatefulWidget {
  final PlayerController playerController;
  final CaptionController captionController;

  const AudioVisualizerViewport({
    super.key,
    required this.playerController,
    required this.captionController,
  });

  @override
  State<AudioVisualizerViewport> createState() => _AudioVisualizerViewportState();
}

class _AudioVisualizerViewportState extends State<AudioVisualizerViewport> {
  bool _showFullCover = false;
  String? _coverPath;
  String? _lastMediaId;

  Future<String?> _findCoverFile(MediaItem? item) async {
    if (item == null) return null;

    // 1. Check item.coverArtPath
    if (item.coverArtPath != null && await File(item.coverArtPath!).exists()) {
      return item.coverArtPath;
    }

    // 2. Check cached album art in app storage
    try {
      final File cachedArt = StoragePaths.getAlbumArtFile(item.id);
      if (await cachedArt.exists()) {
        return cachedArt.path;
      }
    } catch (_) {}

    // 3. Check for cover image files in song folder
    if (item.filePath.isNotEmpty) {
      try {
        final File songFile = File(item.filePath);
        final Directory parentDir = songFile.parent;
        if (await parentDir.exists()) {
          final String baseName = p.basenameWithoutExtension(songFile.path);

          final List<String> candidateNames = [
            'cover.jpg', 'cover.jpeg', 'cover.png', 'cover.webp',
            'folder.jpg', 'folder.jpeg', 'folder.png', 'folder.webp',
            'album.jpg', 'album.jpeg', 'album.png', 'album.webp',
            'art.jpg', 'art.jpeg', 'art.png', 'art.webp',
            '$baseName.jpg', '$baseName.jpeg', '$baseName.png', '$baseName.webp',
            '${baseName}_cover.jpg', '${baseName}_cover.png',
          ];

          for (final String candidate in candidateNames) {
            final File candidateFile = File(p.join(parentDir.path, candidate));
            if (await candidateFile.exists()) {
              return candidateFile.path;
            }
          }

          // Search directory for any image file
          final List<FileSystemEntity> entities = await parentDir.list().toList();
          for (final entity in entities) {
            if (entity is File) {
              final String ext = p.extension(entity.path).toLowerCase();
              if (['.jpg', '.jpeg', '.png', '.webp'].contains(ext)) {
                return entity.path;
              }
            }
          }
        }
      } catch (_) {}
    }

    return null;
  }

  void _onViewportTap(MediaItem? item) async {
    if (_showFullCover) {
      setState(() {
        _showFullCover = false;
      });
      return;
    }

    final String? path = await _findCoverFile(item);
    if (path != null && mounted) {
      setState(() {
        _coverPath = path;
        _showFullCover = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.playerController,
      builder: (context, _) {
        final MediaItem? item = widget.playerController.playlistController.currentItem;
        final bool isPlaying = widget.playerController.isPlaying;

        // Reset full cover view if media item changed
        if (item?.id != _lastMediaId) {
          _lastMediaId = item?.id;
          _showFullCover = false;
          _coverPath = null;
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onViewportTap(item),
          child: Container(
            color: const Color(0xFF0F172A),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_showFullCover && _coverPath != null && File(_coverPath!).existsSync()) ...[
                  // Full Cover View Screen
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_coverPath!),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Default Playback Viewport Screen (Panda artwork + title + visualizer)
                  Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Album Art / PandaSoft Artwork
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: item?.coverArtPath != null && File(item!.coverArtPath!).existsSync()
                                ? Image.file(File(item.coverArtPath!), fit: BoxFit.cover)
                                : Image.asset(
                                    'artwork/logo_transparent.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.music_note,
                                      size: 96,
                                      color: Color(0xFF818CF8),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 24),

                          // Track Title & Artist (Stationary, zero layout shifts)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              item?.title ?? item?.fileName ?? 'EasyPlayer',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              item?.artist ?? item?.album ?? 'PandaSoft',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF94A3B8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Separated, Fixed-Height Waveform Visualizer Bars (Fixed 36px box)
                          VisualizerBars(isPlaying: isPlaying),
                        ],
                      ),
                    ),
                  ),
                ],

                // Subtitle Overlay for Audio Speech Transcripts
                SubtitleOverlay(captionController: widget.captionController),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VisualizerBars extends StatefulWidget {
  final bool isPlaying;
  const VisualizerBars({super.key, required this.isPlaying});

  @override
  State<VisualizerBars> createState() => _VisualizerBarsState();
}

class _VisualizerBarsState extends State<VisualizerBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final Random _random = Random();
  late List<double> _barHeights;

  @override
  void initState() {
    super.initState();
    _barHeights = List.generate(24, (_) => 4.0);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        if (widget.isPlaying && mounted) {
          setState(() {
            for (int i = 0; i < 24; i++) {
              _barHeights[i] = 4.0 + _random.nextDouble() * 26.0;
            }
          });
        }
      });

    if (widget.isPlaying) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VisualizerBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _animController.repeat(reverse: true);
      } else {
        _animController.stop();
        setState(() {
          _barHeights = List.generate(24, (_) => 4.0);
        });
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36, // Fixed height box ensures parent layout never shifts or flickers
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // Center bars inside fixed height box
        children: List.generate(24, (index) {
          final double h = widget.isPlaying ? _barHeights[index] : 4.0;
          return Container(
            width: 3.5,
            height: h,
            margin: const EdgeInsets.symmetric(horizontal: 2.0),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(2.0),
            ),
          );
        }),
      ),
    );
  }
}
