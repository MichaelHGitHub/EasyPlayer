import 'package:flutter/material.dart' hide RepeatMode;
import '../../controllers/player_controller.dart';
import '../../controllers/playlist_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../models/playback_mode.dart';

class PlaylistDrawer extends StatelessWidget {
  final PlaylistController playlistController;
  final PlayerController playerController;
  final VoidCallback onOpenFile;
  final VoidCallback onOpenFolder;
  final bool asPanel;

  const PlaylistDrawer({
    super.key,
    required this.playlistController,
    required this.playerController,
    required this.onOpenFile,
    required this.onOpenFolder,
    this.asPanel = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final content = ListenableBuilder(
        listenable: playlistController,
        builder: (context, _) {
          final queue = playlistController.queue;

          return Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.fromLTRB(16, asPanel ? 16 : 48, 16, 16),
                color: const Color(0xFF0F172A),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.playlistQueue,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.file_open, color: Colors.white70),
                              tooltip: l10n.openFile,
                              onPressed: onOpenFile,
                            ),
                            IconButton(
                              icon: const Icon(Icons.folder_open, color: Colors.white70),
                              tooltip: l10n.openFolder,
                              onPressed: onOpenFolder,
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (playlistController.currentDirectory != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          playlistController.currentDirectory!,
                          style: const TextStyle(fontSize: 11, color: Colors.white38),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Play Mode & Repeat Mode Selectors
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Play Mode
                        DropdownButton<PlayMode>(
                          value: playlistController.playMode,
                          dropdownColor: const Color(0xFF0F172A),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          underline: const SizedBox(),
                          items: [
                            DropdownMenuItem(value: PlayMode.sequential, child: Text(l10n.sequential)),
                            DropdownMenuItem(value: PlayMode.single, child: Text(l10n.single)),
                            DropdownMenuItem(value: PlayMode.shuffle, child: Text(l10n.shuffle)),
                          ],
                          onChanged: (mode) {
                            if (mode != null) playlistController.setModes(playMode: mode);
                          },
                        ),
                        // Repeat Mode
                        DropdownButton<RepeatMode>(
                          value: playlistController.repeatMode,
                          dropdownColor: const Color(0xFF0F172A),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          underline: const SizedBox(),
                          items: [
                            DropdownMenuItem(value: RepeatMode.none, child: Text(l10n.noRepeat)),
                            DropdownMenuItem(value: RepeatMode.track, child: Text(l10n.repeatTrack)),
                            DropdownMenuItem(value: RepeatMode.folder, child: Text(l10n.repeatFolder)),
                          ],
                          onChanged: (mode) {
                            if (mode != null) playlistController.setModes(repeatMode: mode);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Items List
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (playlistController.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (queue.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.queue_music, size: 48, color: Colors.white24),
                            const SizedBox(height: 12),
                            Text(l10n.queueEmpty, style: const TextStyle(color: Colors.white54)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.folder_open),
                              label: Text(l10n.openFolder),
                              onPressed: onOpenFolder,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: queue.length,
                      itemBuilder: (context, index) {
                        final item = queue[index];
                        final bool isCurrent = playlistController.currentIndex == index;

                        return ListTile(
                          dense: true,
                          selected: isCurrent,
                          selectedTileColor: const Color(0xFF6366F1).withOpacity(0.2),
                          leading: Icon(
                            item.isVideo ? Icons.movie : Icons.audiotrack,
                            color: isCurrent ? const Color(0xFF818CF8) : Colors.white54,
                            size: 20,
                          ),
                          title: Text(
                            item.fileName,
                            style: TextStyle(
                              color: isCurrent ? Colors.white : const Color(0xFFCBD5E1),
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${(item.fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
                            style: const TextStyle(fontSize: 10, color: Colors.white38),
                          ),
                          trailing: isCurrent && playerController.isPlaying
                              ? const Icon(Icons.volume_up, size: 16, color: Color(0xFF818CF8))
                              : null,
                          onTap: () {
                            playlistController.selectIndex(index);
                            playerController.openMedia(item);
                            if (!asPanel) {
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        });

    if (asPanel) {
      return Container(
        width: 280,
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          border: Border(right: BorderSide(color: Colors.white12)),
        ),
        child: content,
      );
    }

    return Drawer(
      backgroundColor: const Color(0xFF1E293B),
      child: content,
    );
  }
}
