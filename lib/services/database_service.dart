import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/storage_paths.dart';
import '../models/media_item.dart';

class DatabaseService {
  static DatabaseService? _instance;
  Database? _db;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String dbPath = StoragePaths.databaseFile.path;

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        // 1. Recent History Table (capped at 20 rows, ordered by last_opened_at)
        await db.execute('''
          CREATE TABLE recent_history (
            fast_hash       TEXT PRIMARY KEY,
            file_path       TEXT NOT NULL,
            file_name       TEXT NOT NULL,
            cover_art_path  TEXT,
            duration_ms     INTEGER,
            resume_pos_ms   INTEGER NOT NULL DEFAULT 0,
            last_opened_at  INTEGER NOT NULL
          );
        ''');

        // 2. Playback Positions Table (LRU cap 500)
        await db.execute('''
          CREATE TABLE playback_positions (
            fast_hash       TEXT PRIMARY KEY,
            position_ms     INTEGER NOT NULL,
            updated_at      INTEGER NOT NULL
          );
        ''');

        // 3. Settings Key-Value Table
        await db.execute('''
          CREATE TABLE settings (
            key   TEXT PRIMARY KEY,
            value TEXT NOT NULL
          );
        ''');
      },
    );
  }

  // --- Recent History Methods ---

  Future<void> addRecentHistory(MediaItem item) async {
    final db = await database;
    final int now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'recent_history',
      {
        'fast_hash': item.id,
        'file_path': item.filePath,
        'file_name': item.fileName,
        'cover_art_path': item.coverArtPath,
        'duration_ms': item.duration?.inMilliseconds,
        'resume_pos_ms': item.resumePositionMs ?? 0,
        'last_opened_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Enforce 20-row cap: delete oldest entries
    await db.rawDelete('''
      DELETE FROM recent_history
      WHERE fast_hash NOT IN (
        SELECT fast_hash FROM recent_history
        ORDER BY last_opened_at DESC
        LIMIT ${AppConstants.maxRecentHistory}
      )
    ''');
  }

  Future<List<MediaItem>> getRecentHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recent_history',
      orderBy: 'last_opened_at DESC',
      limit: AppConstants.maxRecentHistory,
    );

    return maps.map((m) => MediaItem.fromMap(m)).toList();
  }

  Future<void> clearRecentHistory() async {
    final db = await database;
    await db.delete('recent_history');
    await db.delete('playback_positions');
  }

  // --- Playback Positions Methods ---

  Future<void> savePlaybackPosition(String fastHash, int positionMs) async {
    final db = await database;
    final int now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'playback_positions',
      {
        'fast_hash': fastHash,
        'position_ms': positionMs,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Also update recent_history resume position if present
    await db.update(
      'recent_history',
      {'resume_pos_ms': positionMs},
      where: 'fast_hash = ?',
      whereArgs: [fastHash],
    );

    // Enforce 500 cap
    await db.rawDelete('''
      DELETE FROM playback_positions
      WHERE fast_hash NOT IN (
        SELECT fast_hash FROM playback_positions
        ORDER BY updated_at DESC
        LIMIT ${AppConstants.maxPlaybackPositions}
      )
    ''');
  }

  Future<int?> getPlaybackPosition(String fastHash) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'playback_positions',
      columns: ['position_ms'],
      where: 'fast_hash = ?',
      whereArgs: [fastHash],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first['position_ms'] as int?;
    }
    return null;
  }

  // --- Settings Persistence Methods ---

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }

  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('settings');
    final Map<String, String> result = {};
    for (final map in maps) {
      result[map['key'] as String] = map['value'] as String;
    }
    return result;
  }
}
