import 'package:flutter/material.dart';
import '../../controllers/caption_controller.dart';
import '../../controllers/player_controller.dart';
import '../../core/constants/settings_keys.dart';
import '../../core/utils/storage_paths.dart';
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
        const SnackBar(content: Text('Cache cleared successfully.')),
      );
    }
  }

  void _showAboutDialog() {
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
            const Text('EasyPlayer', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              'Developed by PandaSoft',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Cross-platform audio and video player with on-device offline Automatic Speech Recognition (ASR). Zero server dependencies.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            SizedBox(height: 12),
            Text(
              'Copyright © 2026 PandaSoft. All rights reserved.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _settingsService.settings;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: ListView(
        children: [
          // Section: General & Language
          _buildSectionHeader('General & Localization'),
          ListTile(
            title: const Text('UI Language', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              s.uiLanguage == 'zh_CN' ? '简体中文' : (s.uiLanguage == 'en' ? 'English' : 'Follow System'),
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: DropdownButton<String>(
              value: s.uiLanguage,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white),
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'system', child: Text('Follow System')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'zh_CN', child: Text('简体中文')),
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
            title: const Text('Hardware Acceleration (GPU)', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Direct3D / MediaCodec hardware decoding with safe CPU fallback', style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: s.hardwareAcceleration,
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (val) {
              _settingsService.update(SettingsKeys.hardwareAcceleration, val, (set) => set.hardwareAcceleration = val);
              setState(() {});
            },
          ),
          SwitchListTile(
            title: const Text('Record Playback History', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Save recently opened media to the Recently Played shelf', style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: s.recordPlaybackHistory,
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (val) {
              _settingsService.update(SettingsKeys.recordPlaybackHistory, val, (set) => set.recordPlaybackHistory = val);
              setState(() {});
            },
          ),

          // Section: Audio Enhancements
          _buildSectionHeader('Audio Enhancements'),
          SwitchListTile(
            title: const Text('Dynamic Loudness Normalization', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Automatically levels out audio volume across tracks (loudnorm)', style: TextStyle(color: Colors.white54, fontSize: 12)),
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
            title: const Text('Voice Clarity Boost', style: TextStyle(color: Colors.white)),
            subtitle: const Text('High-pass filter & vocal EQ boost to clarify dialogue', style: TextStyle(color: Colors.white54, fontSize: 12)),
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
          _buildSectionHeader('Subtitles & Speech Recognition (ASR)'),
          SwitchListTile(
            title: const Text('Override Complex Subtitle Styling', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Forces standard EasyPlayer typography over ASS/SSA fansub styles', style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: s.overrideAssStyling,
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (val) {
              _settingsService.update(SettingsKeys.overrideAssStyling, val, (set) => set.overrideAssStyling = val);
              widget.captionController.configure(overrideAssStyling: val);
              setState(() {});
            },
          ),
          SwitchListTile(
            title: const Text('Show Audio Event Tags', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Display tags such as [Laughter], [Applause] in captions', style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: s.showAudioEventTags,
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (val) {
              _settingsService.update(SettingsKeys.showAudioEventTags, val, (set) => set.showAudioEventTags = val);
              setState(() {});
            },
          ),
          SwitchListTile(
            title: const Text('Include Subtitles in Snapshots', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Composite active subtitle text when capturing video frames', style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: s.snapshotIncludeSubtitles,
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (val) {
              _settingsService.update(SettingsKeys.snapshotIncludeSubtitles, val, (set) => set.snapshotIncludeSubtitles = val);
              setState(() {});
            },
          ),

          // Section: Storage & Cache
          _buildSectionHeader('Storage & Cache Management'),
          ListTile(
            title: const Text('Cached Transcripts & Thumbnails', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              _isLoadingCache
                  ? 'Calculating storage...'
                  : '${(_cacheSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB used',
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
              onPressed: _clearCache,
              child: const Text('Clear Cache'),
            ),
          ),

          // Section: About
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF818CF8)),
            title: const Text('About EasyPlayer', style: TextStyle(color: Colors.white)),
            subtitle: const Text('PandaSoft • Version 1.0.0', style: TextStyle(color: Colors.white54)),
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
