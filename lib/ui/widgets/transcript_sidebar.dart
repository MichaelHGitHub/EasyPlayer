import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../controllers/ab_repeat_controller.dart';
import '../../controllers/caption_controller.dart';
import '../../controllers/player_controller.dart';
import '../../models/asr_state.dart';
import '../../models/subtitle_cue.dart';
import '../../services/asr_service.dart';
import '../../services/subtitle_parser.dart';

class TranscriptSidebar extends StatefulWidget {
  final CaptionController captionController;
  final PlayerController playerController;
  final ABRepeatController abRepeatController;
  final VoidCallback onClose;

  const TranscriptSidebar({
    super.key,
    required this.captionController,
    required this.playerController,
    required this.abRepeatController,
    required this.onClose,
  });

  @override
  State<TranscriptSidebar> createState() => _TranscriptSidebarState();
}

class _TranscriptSidebarState extends State<TranscriptSidebar> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.isScrollingNotifier.value) {
        if (!_isUserScrolling) {
          setState(() => _isUserScrolling = true);
          widget.captionController.setAutoScrollLocked(false);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToActiveCue(int index) {
    if (!widget.captionController.isAutoScrollLocked) return;
    if (_scrollController.hasClients && index >= 0) {
      final double targetOffset = (index * 72.0).clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showEditCueDialog(SubtitleCue cue) {
    final TextEditingController editController = TextEditingController(text: cue.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'Edit Cue (${cue.displayStartTime})',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: TextField(
          controller: editController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () {
              widget.captionController.editCueText(cue.id, editController.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _exportTranscript(String format) async {
    final cues = widget.captionController.cues;
    if (cues.isEmpty) return;

    String content;
    if (format == 'srt') {
      content = SubtitleParser.toSrt(cues);
    } else if (format == 'txt') {
      content = SubtitleParser.toPlainText(cues);
    } else {
      content = SubtitleParser.toVtt(cues);
    }

    try {
      final Directory? downloadsDir = await getDownloadsDirectory();
      final String path = '${downloadsDir?.path ?? 'C:\\temp'}/transcript_${DateTime.now().millisecondsSinceEpoch}.$format';
      final File exportFile = File(path);
      await exportFile.writeAsString(content);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to: $path')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      color: const Color(0xFF1E293B),
      child: Column(
        children: [
          // Header & Search Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF0F172A),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Interactive Transcript',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    Row(
                      children: [
                        // Export popup
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.file_download, color: Colors.white70),
                          tooltip: 'Export Transcript',
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'vtt', child: Text('Export as WebVTT (.vtt)')),
                            const PopupMenuItem(value: 'srt', child: Text('Export as SubRip (.srt)')),
                            const PopupMenuItem(value: 'txt', child: Text('Export as Plain Text (.txt)')),
                          ],
                          onSelected: _exportTranscript,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Real-time Search Field
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search transcript...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Colors.white54),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Colors.white54),
                            onPressed: () {
                              _searchController.clear();
                              widget.captionController.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => widget.captionController.setSearchQuery(val),
                ),
                // Search match navigation if results exist
                if (widget.captionController.searchMatchIndices.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.captionController.currentSearchMatchIndex + 1} of ${widget.captionController.searchMatchIndices.length} matches',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF818CF8)),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_upward, size: 16, color: Colors.white70),
                              onPressed: () {
                                widget.captionController.previousSearchMatch();
                                final matchIdx = widget.captionController.searchMatchIndices[widget.captionController.currentSearchMatchIndex];
                                _scrollToActiveCue(matchIdx);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_downward, size: 16, color: Colors.white70),
                              onPressed: () {
                                widget.captionController.nextSearchMatch();
                                final matchIdx = widget.captionController.searchMatchIndices[widget.captionController.currentSearchMatchIndex];
                                _scrollToActiveCue(matchIdx);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ASR Progress Bar / Status
          AnimatedBuilder(
            animation: ASRService.instance,
            builder: (context, _) {
              final asrState = ASRService.instance.state;
              if (asrState.isBusy) {
                return Column(
                  children: [
                    LinearProgressIndicator(value: asrState.progress, color: const Color(0xFF6366F1)),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        asrState.status == ASRStatus.modelLoading
                            ? 'Loading speech model...'
                            : 'Transcribing speech: ${(asrState.progress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF818CF8)),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Cues List
          Expanded(
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: widget.captionController,
                  builder: (context, child) {
                    final cues = widget.captionController.cues;
                    final currentCue = widget.captionController.currentCue;

                    if (cues.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.subtitles_off, size: 48, color: Colors.white30),
                            const SizedBox(height: 12),
                            const Text('No subtitles or transcript available', style: TextStyle(color: Colors.white54)),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.transcribe),
                              label: const Text('Start AI Transcription'),
                              onPressed: () {
                                final item = widget.playerController.playlistController.currentItem;
                                if (item != null) {
                                  widget.captionController.setSourceType(SubtitleSourceType.autoASR);
                                  ASRService.instance.startTranscription(
                                    filePath: item.filePath,
                                    fastHash: item.id,
                                    duration: item.duration ?? widget.playerController.duration,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: cues.length,
                      itemBuilder: (context, index) {
                        final cue = cues[index];
                        final bool isActive = currentCue?.id == cue.id;
                        final bool isSearchMatch = widget.captionController.searchMatchIndices.contains(index);

                        if (isActive && widget.captionController.isAutoScrollLocked) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToActiveCue(index);
                          });
                        }

                        return Container(
                          color: isActive
                              ? const Color(0xFF6366F1).withOpacity(0.25)
                              : isSearchMatch
                                  ? const Color(0xFFEAB308).withOpacity(0.15)
                                  : Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Click-to-seek
                              widget.playerController.seek(Duration(milliseconds: cue.startMs));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Timestamp pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isActive ? const Color(0xFF6366F1) : const Color(0xFF334155),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      cue.displayStartTime,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isActive ? Colors.white : Colors.white70,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Text & badges
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cue.text,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isActive ? Colors.white : const Color(0xFFCBD5E1),
                                            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                        if (cue.isEdited)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.0),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0284C7).withOpacity(0.4),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                              child: const Text('Edited', style: TextStyle(fontSize: 10, color: Color(0xFF38BDF8))),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Micro-actions (Loop sentence & Edit)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.repeat_one, size: 16, color: Colors.white54),
                                        tooltip: 'Loop Sentence',
                                        onPressed: () {
                                          widget.captionController.loopSentence(cue, widget.abRepeatController);
                                          widget.playerController.seek(Duration(milliseconds: cue.startMs));
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 16, color: Colors.white54),
                                        tooltip: 'Edit Text',
                                        onPressed: () => _showEditCueDialog(cue),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                // Floating "Resume Auto-scroll" button
                AnimatedBuilder(
                  animation: widget.captionController,
                  builder: (context, _) {
                    if (!widget.captionController.isAutoScrollLocked) {
                      return Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton.extended(
                          icon: const Icon(Icons.sync, size: 18),
                          label: const Text('Resume Auto-scroll'),
                          backgroundColor: const Color(0xFF6366F1),
                          onPressed: () {
                            setState(() => _isUserScrolling = false);
                            widget.captionController.setAutoScrollLocked(true);
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
