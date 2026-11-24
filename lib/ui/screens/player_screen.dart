import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../controllers/ab_repeat_controller.dart';
import '../../controllers/caption_controller.dart';
import '../../controllers/player_controller.dart';
import '../../controllers/playlist_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../models/asr_state.dart';
import '../../services/asr_service.dart';
import '../../services/settings_service.dart';
import '../../services/sleep_timer_service.dart';
import '../widgets/audio_visualizer_viewport.dart';
import '../widgets/playback_controls.dart';
import '../widgets/playlist_drawer.dart';
import '../widgets/recently_played_shelf.dart';
import '../widgets/sleep_timer_dialog.dart';
import '../widgets/track_settings_dialog.dart';
import '../widgets/transcript_sidebar.dart';
import '../widgets/video_viewport.dart';
import 'settings_screen.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final PlaylistController _playlistController;
  late final CaptionController _captionController;
  late final ABRepeatController _abRepeatController;
  late final PlayerController _playerController;
  late final SleepTimerService _sleepTimerService;

  bool _isSidebarOpen = false;
  bool _isFullscreen = false;
  final FocusNode _focusNode = FocusNode();

  static const MethodChannel _appChannel = MethodChannel('com.pandasoft.easyplayer/app');

  Future<void> _moveToBackground() async {
    try {
      await _appChannel.invokeMethod('moveToBackground');
    } catch (_) {
      SystemNavigator.pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _playlistController = PlaylistController();
    _captionController = CaptionController();
    _abRepeatController = ABRepeatController();
    _sleepTimerService = SleepTimerService();

    _playerController = PlayerController(
      playlistController: _playlistController,
      captionController: _captionController,
      abRepeatController: _abRepeatController,
    );

    _sleepTimerService.configure(
      volumeSetter: (vol) => _playerController.setVolume(vol),
      onStopPlayback: () => _playerController.pause(),
    );

    // Initial settings config
    final s = SettingsService.instance.settings;
    _captionController.configure(
      fontSize: s.subtitleFontSize,
      bottomMarginPercent: s.subtitleBottomMarginPercent,
      delayMs: s.subtitleDelayMs,
      overrideAssStyling: s.overrideAssStyling,
    );
    _playerController.setAspectRatioMode(s.aspectRatioMode);
    _playlistController.setModes(playMode: s.playMode, repeatMode: s.repeatMode);
    _playerController.applyAudioFilters(
      loudnessNormalization: s.audioNormalization,
      vocalClarityBoost: s.voiceClarityBoost,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _playerController.dispose();
    _playlistController.dispose();
    _captionController.dispose();
    _abRepeatController.dispose();
    _sleepTimerService.dispose();
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  Future<void> _captureSnapshot() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final path = await _playerController.captureSnapshot();
      if (mounted && path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snapshotSavedPath(path))),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snapshotSaveFailed(error))),
        );
      }
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.space) {
      _playerController.playOrPause();
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _playerController.seekBackward(SettingsService.instance.settings.skipBackwardSeconds);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _playerController.seekForward(SettingsService.instance.settings.skipForwardSeconds);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _playerController.setVolume(_playerController.volume + 5.0);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _playerController.setVolume(_playerController.volume - 5.0);
    } else if (key == LogicalKeyboardKey.keyF) {
      _toggleFullscreen();
    } else if (key == LogicalKeyboardKey.keyM) {
      _playerController.toggleMute();
    } else if (key == LogicalKeyboardKey.keyC) {
      _toggleCC();
    } else if (key == LogicalKeyboardKey.keyR) {
      _abRepeatController.toggleActive(_playerController.position.inMilliseconds);
    } else if (key == LogicalKeyboardKey.keyS) {
      _captureSnapshot();
    } else if (key == LogicalKeyboardKey.bracketLeft) {
      final List<double> speeds = AppConstants.supportedPlaybackSpeeds;
      final int currIndex = speeds.indexWhere((s) => (s - _playerController.speed).abs() < 0.05);
      if (currIndex > 0) {
        _playerController.setSpeed(speeds[currIndex - 1]);
      } else if (currIndex == -1 && speeds.isNotEmpty) {
        _playerController.setSpeed(speeds.first);
      }
    } else if (key == LogicalKeyboardKey.bracketRight) {
      final List<double> speeds = AppConstants.supportedPlaybackSpeeds;
      final int currIndex = speeds.indexWhere((s) => (s - _playerController.speed).abs() < 0.05);
      if (currIndex != -1 && currIndex < speeds.length - 1) {
        _playerController.setSpeed(speeds[currIndex + 1]);
      } else if (currIndex == -1 && speeds.isNotEmpty) {
        _playerController.setSpeed(speeds.first);
      }
    } else if (key == LogicalKeyboardKey.escape) {
      if (_isFullscreen) {
        _toggleFullscreen();
      } else if (_isSidebarOpen) {
        setState(() => _isSidebarOpen = false);
      }
    }
  }

  Future<void> _toggleCC() async {
    final l10n = AppLocalizations.of(context)!;

    if (_captionController.sourceType != SubtitleSourceType.off) {
      _captionController.setSourceType(SubtitleSourceType.off);
    } else {
      final item = _playlistController.currentItem;
      if (item != null) {
        final cachedCues = await ASRService.instance.checkCachedTranscript(item.id);
        if (cachedCues != null && cachedCues.isNotEmpty) {
          _captionController.setCues(cachedCues);
          _captionController.setSourceType(SubtitleSourceType.autoASR);
        } else if (_captionController.sidecars.isNotEmpty) {
          _captionController.setSourceType(
            SubtitleSourceType.sidecar,
            sidecar: _captionController.sidecars.first,
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.transcriptMissing),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      try {
        await [
          Permission.audio,
          Permission.videos,
          Permission.photos,
          Permission.storage,
          Permission.manageExternalStorage,
        ].request();
      } catch (_) {}
    }
  }

  Future<void> _openFilePicker() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await _requestPermissions();
      String? filePath;

      if (Platform.isAndroid) {
        filePath = await _appChannel.invokeMethod<String>('pickMediaFile');
      } else {
        final XTypeGroup typeGroup = XTypeGroup(
          label: 'media',
          extensions: <String>[
            ...AppConstants.audioExtensions,
            ...AppConstants.videoExtensions,
          ],
        );
        final XFile? file = await openFile(
          acceptedTypeGroups: <XTypeGroup>[typeGroup],
        );
        filePath = file?.path;
      }

      if (filePath != null && filePath.isNotEmpty) {
        await _playlistController.setSingleItem(filePath);
        if (_playlistController.currentItem != null) {
          await _playerController.openMedia(_playlistController.currentItem!);
        }
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToOpenFile(e))),
        );
      }
    }
  }

  Future<void> _openFolderPicker() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await _requestPermissions();
      final String? selectedDirectory = await getDirectoryPath(
        confirmButtonText: l10n.selectFolder,
      );

      if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
        await _playlistController.loadDirectory(
          selectedDirectory,
          includeSubfolders: SettingsService.instance.settings.includeSubfolders,
        );

        if (_playlistController.queue.isNotEmpty) {
          final item = _playlistController.currentItem ?? _playlistController.queue.first;
          await _playerController.openMedia(item);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.unsupportedMediaFiles)),
          );
        }
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToOpenFolder(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        await _moveToBackground();
      },
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
          backgroundColor: Colors.black,
          drawer: PlaylistDrawer(
            playlistController: _playlistController,
            playerController: _playerController,
            onOpenFile: _openFilePicker,
            onOpenFolder: _openFolderPicker,
          ),
          appBar: _isFullscreen
              ? null
              : AppBar(
                  backgroundColor: const Color(0xFF0F172A),
                  title: Text(
                    _playlistController.currentItem?.fileName ?? 'EasyPlayer',
                    style: const TextStyle(fontSize: 16),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.file_open),
                      tooltip: l10n.openFile,
                      onPressed: _openFilePicker,
                    ),
                    IconButton(
                      icon: const Icon(Icons.folder_open),
                      tooltip: l10n.openFolder,
                      onPressed: _openFolderPicker,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: l10n.settings,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(
                              playerController: _playerController,
                              captionController: _captionController,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
          body: SafeArea(
            child: Column(
              children: [
                // Recently Played shelf when stopped or queue empty
                if (!_isFullscreen && !_playerController.isPlaying && _playlistController.queue.isEmpty)
                  RecentlyPlayedShelf(
                    playerController: _playerController,
                    playlistController: _playlistController,
                    onMediaSelected: () => setState(() {}),
                  ),

                // Viewport & Sidebar area
                Expanded(
                  child: Row(
                    children: [
                      // Main Viewport (Video or Audio Visualizer)
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AnimatedBuilder(
                              animation: _playerController,
                              builder: (context, _) {
                                if (_playerController.hasVideo) {
                                  return VideoViewport(
                                    playerController: _playerController,
                                    captionController: _captionController,
                                    onToggleFullscreen: _toggleFullscreen,
                                  );
                                } else {
                                  return AudioVisualizerViewport(
                                    playerController: _playerController,
                                    captionController: _captionController,
                                  );
                                }
                              },
                            ),

                            // Script Generation In-Progress Banner
                            AnimatedBuilder(
                              animation: ASRService.instance,
                              builder: (context, _) {
                                final asrState = ASRService.instance.state;
                                if (asrState.status == ASRStatus.error) {
                                  return Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xF03F1D24),
                                        borderRadius: BorderRadius.circular(16.0),
                                        border: Border.all(color: const Color(0x99EF4444)),
                                      ),
                                      child: Text(
                                        asrState.errorMessage ?? l10n.speechRecognitionFailed,
                                        style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
                                      ),
                                    ),
                                  );
                                }
                                if (!asrState.isBusy) return const SizedBox.shrink();

                                final String status;
                                if (asrState.status == ASRStatus.downloadingModel) {
                                  status = '${l10n.modelDownloading}: ${(asrState.progress * 100).toInt()}%';
                                } else if (asrState.status == ASRStatus.modelLoading) {
                                  status = l10n.modelLoading;
                                } else if (asrState.status == ASRStatus.extractingAudio) {
                                  status = l10n.extractingAudio;
                                } else {
                                  status = '${l10n.transcribing}: ${(asrState.progress * 100).toInt()}%';
                                }

                                final String notice = l10n.scriptGenerationNotice;

                                return Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xF01E1B4B),
                                      borderRadius: BorderRadius.circular(24.0),
                                      border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.6)),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 3)),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF818CF8)),
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            '$status — $notice',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Floating Controls overlay in fullscreen
                            if (_isFullscreen)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: AnimatedBuilder(
                                  animation: _playerController,
                                  builder: (context, _) {
                                    return PlaybackControls(
                                      playerController: _playerController,
                                      captionController: _captionController,
                                      abRepeatController: _abRepeatController,
                                      playlistController: _playlistController,
                                      onToggleFullscreen: _toggleFullscreen,
                                      onToggleTranscriptSidebar: () {
                                        setState(() => _isSidebarOpen = !_isSidebarOpen);
                                      },
                                      onOpenTrackMenu: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => TrackSettingsDialog(
                                            playerController: _playerController,
                                            captionController: _captionController,
                                          ),
                                        );
                                      },
                                      onOpenSleepTimer: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => SleepTimerDialog(
                                            sleepTimerService: _sleepTimerService,
                                            currentVolume: _playerController.volume,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Interactive Transcript Sidebar
                      if (_isSidebarOpen)
                        TranscriptSidebar(
                          captionController: _captionController,
                          playerController: _playerController,
                          abRepeatController: _abRepeatController,
                          onClose: () => setState(() => _isSidebarOpen = false),
                        ),
                    ],
                  ),
                ),

                // Standard Bottom Playback Controls (when not in fullscreen)
                if (!_isFullscreen)
                  AnimatedBuilder(
                    animation: _playerController,
                    builder: (context, _) {
                      return PlaybackControls(
                        playerController: _playerController,
                        captionController: _captionController,
                        abRepeatController: _abRepeatController,
                        playlistController: _playlistController,
                        onToggleFullscreen: _toggleFullscreen,
                        onToggleTranscriptSidebar: () {
                          setState(() => _isSidebarOpen = !_isSidebarOpen);
                        },
                        onOpenTrackMenu: () {
                          showDialog(
                            context: context,
                            builder: (_) => TrackSettingsDialog(
                              playerController: _playerController,
                              captionController: _captionController,
                            ),
                          );
                        },
                        onOpenSleepTimer: () {
                          showDialog(
                            context: context,
                            builder: (_) => SleepTimerDialog(
                              sleepTimerService: _sleepTimerService,
                              currentVolume: _playerController.volume,
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
