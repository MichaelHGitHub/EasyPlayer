import 'package:flutter/material.dart';
import '../../controllers/caption_controller.dart';
import '../../controllers/player_controller.dart';
import '../../core/constants/settings_keys.dart';
import '../../core/utils/storage_paths.dart';
import '../../l10n/app_localizations.dart';
import '../../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final PlayerController playerController;
  final CaptionController captionController;

  const SettingsScreen({
    super.key,
    required this.playerController,
    required this.captionController,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService.instance;
  int _cacheSizeBytes = 0;
  bool _isLoadingCache = true;

  @override
  void initState() {
    super.initState();
    _calculateCacheSize();
  }

  Future<void> _calculateCacheSize() async {
    setState(() => _isLoadingCache = true);
    final int transcriptSize = await StoragePaths.getDirectorySize(StoragePaths.transcriptsDir);
    final int artSize = await StoragePaths.getDirectorySize(StoragePaths.albumArtCacheDir);
    if (mounted) {
      setState(() {
        _cacheSizeBytes = transcriptSize + artSize;
        _isLoadingCache = false;
      });
    }
  }

  Future<void> _clearCache() async {
    // Purge transcripts and thumbnails while preserving model
    if (await StoragePaths.transcriptsDir.exists()) {
      await StoragePaths.transcriptsDir.delete(recursive: true);
      await StoragePaths.transcriptsDir.create();
    }
    if (await StoragePaths.albumArtCacheDir.exists()) {
      await StoragePaths.albumArtCacheDir.delete(recursive: true);
      await StoragePaths.albumArtCacheDir.create();
    }
    await _calculateCacheSize();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.cacheCleared)),
      );
    }
  }

  void _showAboutDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            Image.asset(
              'artwork/logo_transparent.png',
              width: 36,
              height: 36,
              errorBuilder: (_, __, ___) => const Icon(Icons.play_circle_fill, color: Color(0xFF818CF8)),
            ),
            const SizedBox(width: 12),
            Text(l10n.appTitle, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.aboutVersion, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            Text(l10n.developerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.aboutDescription, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 12),
            Text(l10n.copyright, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(
            child: Text(l10n.ok),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _settingsService.settings;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: ListView(
        children: [
          // Section: General & Language
          _buildSectionHeader(l10n.settingsGeneralLocalization),
          ListTile(
            title: Text(l10n.language, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              s.uiLanguage == 'zh_CN' ? l10n.chinese : (s.uiLanguage == 'en' ? l10n.english : l10n.followSystem),
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: DropdownButton<String>(
              value: s.uiLanguage,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white),
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(value: 'system', child: Text(l10n.followSystem)),
                DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                DropdownMenuItem(value: 'zh_CN', child: Text(l10n.chinese)),
              ],
              onChanged: (val) {
                if (val != null) {
                  _settingsService.update(SettingsKeys.uiLanguage, val, (set) => set.uiLanguage = val);
                  setState(() {});
                }
              },
            ),
          ),
          SwitchListTile(
            title: Text(l10n.hardwareAcceleration, style: const TextStyle(color: Colors.white)),
            subtitle:
                Text(l10n.hardwareAccelerationDescription, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            value: s.hardwareAcceleration,
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (val) {
              _settingsService.update(SettingsKeys.hardwareAcceleration, val, (set) => set.hardwareAcceleration = val);
              setState(() {});
            },
          ),
          SwitchListTile(
            title: Text(l10n.recordPlaybackHistory, style: const TextStyle(color: Colors.white)),
            subtitle: Text(l10n.recordPlaybackHistoryDescription,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            value: s.recordPlaybackHistory,
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (val) {
              _settingsService.update(
                  SettingsKeys.recordPlaybackHistory, val, (set) => set.recordPlaybackHistory = val);
              setState(() {});
            },
          ),

          // Section: Playback & Navigation
          _buildSectionHeader(l10n.playbackNavigation),
          ListTile(
            title: Text(l10n.fastBackwardDuration, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              '${s.skipBackwardSeconds} ${l10n.seconds}',
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: DropdownButton<int>(
              value: [5, 10, 15, 20, 25, 30].contains(s.skipBackwardSeconds) ? s.skipBackwardSeconds : 10,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white),
              underline: const SizedBox(),
              items: [5, 10, 15, 20, 25, 30].map((sec) {
                return DropdownMenuItem<int>(
                  value: sec,
                  child: Text('$sec ${l10n.seconds}'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  _settingsService.update(
                      SettingsKeys.skipBackwardSeconds, val, (set) => set.skipBackwardSeconds = val);
                  setState(() {});
                }
              },
            ),
          ),
          ListTile(
            title: Text(l10n.fastForwardDuration, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              '${s.skipForwardSeconds} ${l10n.seconds}',
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: DropdownButton<int>(
              value: [5, 10, 15, 20, 25, 30].contains(s.skipForwardSeconds) ? s.skipForwardSeconds : 10,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white),
              underline: const SizedBox(),
              items: [5, 10, 15, 20, 25, 30].map((sec) {
                return DropdownMenuItem<int>(
                  value: sec,
                  child: Text('$sec ${l10n.seconds}'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  _settingsService.update(SettingsKeys.skipForwardSeconds, val, (set) => set.skipForwardSeconds = val);
                  setState(() {});
                }
              },
            ),
          ),

          // Section: Audio Enhancements
          _buildSectionHeader(l10n.audioEnhancements),
          SwitchListTile(
            title: Text(l10n.loudnessNormalization, style: const TextStyle(color: Colors.white)),
            subtitle: Text(l10n.loudnessNormalizationDescription,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            value: s.audioNormalization,
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (val) {
              _settingsService.update(SettingsKeys.audioNormalization, val, (set) => set.audioNormalization = val);
              widget.playerController.applyAudioFilters(
                loudnessNormalization: val,
                vocalClarityBoost: s.voiceClarityBoost,
              );
              setState(() {});
            },
          ),
          SwitchListTile(
            title: Text(l10n.vocalClarityBoost, style: const TextStyle(color: Colors.white)),
            subtitle:
                Text(l10n.vocalClarityBoostDescription, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            value: s.voiceClarityBoost,
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (val) {
              _settingsService.update(SettingsKeys.voiceClarityBoost, val, (set) => set.voiceClarityBoost = val);
              widget.playerController.applyAudioFilters(
                loudnessNormalization: s.audioNormalization,
                vocalClarityBoost: val,
              );
              setState(() {});
            },
          ),

          // Section: Subtitles & ASR
          _buildSectionHeader(l10n.subtitlesAndAsr),
          SwitchListTile(
            title: Text(l10n.overrideAssStyling, style: const TextStyle(color: Colors.white)),
            subtitle:
                Text(l10n.overrideAssStylingDescription, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            value: s.overrideAssStyling,
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (val) {
              _settingsService.update(SettingsKeys.overrideAssStyling, val, (set) => set.overrideAssStyling = val);
              widget.captionController.configure(overrideAssStyling: val);
              setState(() {});
            },
          ),
          SwitchListTile(
            title: Text(l10n.showAudioEventTags, style: const TextStyle(color: Colors.white)),
            subtitle:
                Text(l10n.showAudioEventTagsDescription, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            value: s.showAudioEventTags,
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (val) {
              _settingsService.update(SettingsKeys.showAudioEventTags, val, (set) => set.showAudioEventTags = val);
              setState(() {});
            },
          ),
          SwitchListTile(
            title: Text(l10n.includeSubtitlesInSnapshots, style: const TextStyle(color: Colors.white)),
            subtitle: Text(l10n.includeSubtitlesInSnapshotsDescription,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            value: s.snapshotIncludeSubtitles,
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (val) {
              _settingsService.update(
                  SettingsKeys.snapshotIncludeSubtitles, val, (set) => set.snapshotIncludeSubtitles = val);
              setState(() {});
            },
          ),

          // Section: Storage & Cache
          _buildSectionHeader(l10n.storageAndCache),
          ListTile(
            title: Text(l10n.cachedTranscriptsAndThumbnails, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              _isLoadingCache
                  ? l10n.calculatingStorage
                  : l10n.cacheSizeUsed((_cacheSizeBytes / (1024 * 1024)).toStringAsFixed(2)),
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
              onPressed: _clearCache,
              child: Text(l10n.clearCache),
            ),
          ),

          // Section: About
          _buildSectionHeader(l10n.about),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF818CF8)),
            title: Text(l10n.about, style: const TextStyle(color: Colors.white)),
            subtitle:
                Text('${l10n.developerName} • ${l10n.aboutVersion}', style: const TextStyle(color: Colors.white54)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF818CF8),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
