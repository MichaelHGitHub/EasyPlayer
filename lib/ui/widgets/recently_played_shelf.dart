import 'dart:io';
import 'package:flutter/material.dart';
import '../../controllers/player_controller.dart';
import '../../controllers/playlist_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../models/media_item.dart';
import '../../services/database_service.dart';

class RecentlyPlayedShelf extends StatefulWidget {
  final PlayerController playerController;
  final PlaylistController playlistController;
  final VoidCallback onMediaSelected;

  const RecentlyPlayedShelf({
    super.key,
    required this.playerController,
    required this.playlistController,
    required this.onMediaSelected,
  });

  @override
  State<RecentlyPlayedShelf> createState() => _RecentlyPlayedShelfState();
}

class _RecentlyPlayedShelfState extends State<RecentlyPlayedShelf> {
  List<MediaItem> _recentItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final items = await DatabaseService.instance.getRecentHistory();
    if (mounted) {
      setState(() {
        _recentItems = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    await DatabaseService.instance.clearRecentHistory();
    await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
    }

    if (_recentItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recentlyPlayed,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                ),
                TextButton(
                  onPressed: _clearHistory,
                  child: Text(l10n.clearHistory, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 96,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: _recentItems.length,
              itemBuilder: (context, index) {
                final item = _recentItems[index];
                final double progress =
                    (item.duration != null && item.duration!.inMilliseconds > 0 && item.resumePositionMs != null)
                        ? (item.resumePositionMs! / item.duration!.inMilliseconds).clamp(0.0, 1.0)
                        : 0.0;

                return InkWell(
                  onTap: () {
                    widget.playlistController.setSingleItem(item.filePath);
                    widget.playerController.openMedia(item);
                    widget.onMediaSelected();
                  },
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail / Icon
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              item.coverArtPath != null && File(item.coverArtPath!).existsSync()
                                  ? Image.file(File(item.coverArtPath!), fit: BoxFit.cover)
                                  : Container(
                                      color: const Color(0xFF334155),
                                      child: Icon(
                                        item.isVideo ? Icons.movie : Icons.audiotrack,
                                        color: const Color(0xFF818CF8),
                                      ),
                                    ),
                              // Progress bar
                              if (progress > 0)
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.transparent,
                                    color: const Color(0xFF6366F1),
                                    minHeight: 3,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Title
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            item.fileName,
                            style: const TextStyle(fontSize: 11, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
