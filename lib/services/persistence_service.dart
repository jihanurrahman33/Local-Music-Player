import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/models/song.dart';

class PlaylistData {
  PlaylistData({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final List<String> songIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songIds': songIds,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory PlaylistData.fromJson(Map<String, dynamic> json) => PlaylistData(
        id: json['id'] as String,
        name: json['name'] as String,
        songIds: List<String>.from(json['songIds'] as List? ?? []),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class HistoryEntry {
  HistoryEntry({required this.songId, required this.playedAt});

  final String songId;
  final DateTime playedAt;

  Map<String, dynamic> toJson() => {
        'songId': songId,
        'playedAt': playedAt.toIso8601String(),
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        songId: json['songId'] as String,
        playedAt: DateTime.tryParse(json['playedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class PersistenceService {
  PersistenceService(this._prefs);

  final SharedPreferences _prefs;

  static const _kFavoritesKey = 'local_music_favorites';
  static const _kPlaylistsKey = 'local_music_playlists';
  static const _kHistoryKey = 'local_music_history';
  static const _kImportedSongsKey = 'local_music_imported_songs';
  static const _kShuffleByDefaultKey = 'local_music_shuffle_default';

  static Future<PersistenceService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PersistenceService(prefs);
  }

  // --- Favorites ---
  Set<String> getFavorites() {
    final list = _prefs.getStringList(_kFavoritesKey) ?? [];
    return list.toSet();
  }

  bool isFavorite(String songId) {
    return getFavorites().contains(songId);
  }

  Future<bool> toggleFavorite(String songId) async {
    final favs = getFavorites();
    final isFav = favs.contains(songId);
    if (isFav) {
      favs.remove(songId);
    } else {
      favs.add(songId);
    }
    await _prefs.setStringList(_kFavoritesKey, favs.toList());
    return !isFav;
  }

  // --- Playlists ---
  List<PlaylistData> getPlaylists() {
    final raw = _prefs.getString(_kPlaylistsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => PlaylistData.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error decoding playlists: $e');
      return [];
    }
  }

  Future<void> _savePlaylists(List<PlaylistData> list) async {
    final raw = jsonEncode(list.map((p) => p.toJson()).toList());
    await _prefs.setString(_kPlaylistsKey, raw);
  }

  Future<PlaylistData> createPlaylist(String name) async {
    final list = getPlaylists();
    final now = DateTime.now();
    final newPlaylist = PlaylistData(
      id: 'pl_${now.millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'New Playlist' : name.trim(),
      songIds: [],
      createdAt: now,
      updatedAt: now,
    );
    list.add(newPlaylist);
    await _savePlaylists(list);
    return newPlaylist;
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final list = getPlaylists();
    final index = list.indexWhere((p) => p.id == id);
    if (index >= 0) {
      final existing = list[index];
      list[index] = PlaylistData(
        id: existing.id,
        name: newName.trim().isEmpty ? existing.name : newName.trim(),
        songIds: existing.songIds,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
      await _savePlaylists(list);
    }
  }

  Future<void> deletePlaylist(String id) async {
    final list = getPlaylists();
    list.removeWhere((p) => p.id == id);
    await _savePlaylists(list);
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final list = getPlaylists();
    final index = list.indexWhere((p) => p.id == playlistId);
    if (index >= 0) {
      final existing = list[index];
      if (!existing.songIds.contains(songId)) {
        existing.songIds.add(songId);
        list[index] = PlaylistData(
          id: existing.id,
          name: existing.name,
          songIds: existing.songIds,
          createdAt: existing.createdAt,
          updatedAt: DateTime.now(),
        );
        await _savePlaylists(list);
      }
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final list = getPlaylists();
    final index = list.indexWhere((p) => p.id == playlistId);
    if (index >= 0) {
      final existing = list[index];
      existing.songIds.remove(songId);
      list[index] = PlaylistData(
        id: existing.id,
        name: existing.name,
        songIds: existing.songIds,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
      await _savePlaylists(list);
    }
  }

  Future<void> reorderPlaylistSong(
      String playlistId, int oldIndex, int newIndex) async {
    final list = getPlaylists();
    final index = list.indexWhere((p) => p.id == playlistId);
    if (index >= 0) {
      final existing = list[index];
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final songId = existing.songIds.removeAt(oldIndex);
      existing.songIds.insert(newIndex, songId);
      list[index] = PlaylistData(
        id: existing.id,
        name: existing.name,
        songIds: existing.songIds,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
      await _savePlaylists(list);
    }
  }

  // --- History & Play Counts ---
  List<HistoryEntry> getHistory() {
    final raw = _prefs.getString(_kHistoryKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error decoding history: $e');
      return [];
    }
  }

  Future<void> recordPlay(String songId) async {
    final list = getHistory();
    // Keep up to 200 history entries
    list.insert(0, HistoryEntry(songId: songId, playedAt: DateTime.now()));
    if (list.length > 200) {
      list.removeRange(200, list.length);
    }
    final raw = jsonEncode(list.map((h) => h.toJson()).toList());
    await _prefs.setString(_kHistoryKey, raw);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_kHistoryKey);
  }

  Map<String, int> getPlayCounts() {
    final history = getHistory();
    final counts = <String, int>{};
    for (final item in history) {
      counts[item.songId] = (counts[item.songId] ?? 0) + 1;
    }
    return counts;
  }

  // --- Imported Songs ---
  List<Song> getImportedSongs() {
    final raw = _prefs.getString(_kImportedSongsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      final seenIds = <String>{};
      final seenUris = <String>{};
      final seenBasenames = <String>{};
      final results = <Song>[];

      for (final json in list) {
        final m = json as Map<String, dynamic>;
        final song = Song(
          id: m['id'] as String,
          title: m['title'] as String,
          artist: m['artist'] as String?,
          album: m['album'] as String?,
          albumId: m['albumId'] as String?,
          artistId: m['artistId'] as String?,
          duration: m['durationMs'] != null
              ? Duration(milliseconds: m['durationMs'] as int)
              : null,
          uri: m['uri'] as String?,
          artworkUri: m['artworkUri'] as String?,
          trackNumber: m['trackNumber'] as int?,
          year: m['year'] as int?,
          genre: m['genre'] as String?,
          dateAdded: m['dateAdded'] != null
              ? DateTime.tryParse(m['dateAdded'] as String)
              : null,
        );

        final basename = (song.uri != null && song.uri!.isNotEmpty)
            ? p.basename(song.uri!).toLowerCase()
            : song.title.toLowerCase().trim();

        final isDuplicateId = seenIds.contains(song.id);
        final isDuplicateUri = song.uri != null &&
            song.uri!.isNotEmpty &&
            seenUris.contains(song.uri);
        final isDuplicateBasename = seenBasenames.contains(basename);

        if (!isDuplicateId && !isDuplicateUri && !isDuplicateBasename) {
          seenIds.add(song.id);
          seenBasenames.add(basename);
          if (song.uri != null && song.uri!.isNotEmpty) {
            seenUris.add(song.uri!);
          }
          results.add(song);
        }
      }

      // If duplicate records were found and pruned, sanitize persisted state
      if (results.length < list.length) {
        saveImportedSongs(results);
      }

      return results;
    } catch (e) {
      debugPrint('Error decoding imported songs: $e');
      return [];
    }
  }

  Future<void> saveImportedSongs(List<Song> songs) async {
    final jsonList = songs
        .map((s) => {
              'id': s.id,
              'title': s.title,
              'artist': s.artist,
              'album': s.album,
              'albumId': s.albumId,
              'artistId': s.artistId,
              'durationMs': s.duration?.inMilliseconds,
              'uri': s.uri,
              'artworkUri': s.artworkUri,
              'trackNumber': s.trackNumber,
              'year': s.year,
              'genre': s.genre,
              'dateAdded': s.dateAdded?.toIso8601String(),
            })
        .toList();
    await _prefs.setString(_kImportedSongsKey, jsonEncode(jsonList));
  }

  Future<void> addImportedSongs(List<Song> newSongs) async {
    final existing = getImportedSongs();
    final existingIds = existing.map((s) => s.id).toSet();
    final existingUris = existing
        .map((s) => s.uri)
        .where((u) => u != null && u.isNotEmpty)
        .toSet();
    final existingBasenames = existing
        .map((s) => (s.uri != null && s.uri!.isNotEmpty)
            ? p.basename(s.uri!).toLowerCase()
            : s.title.toLowerCase().trim())
        .toSet();
    final merged = [...existing];

    for (final song in newSongs) {
      final basename = (song.uri != null && song.uri!.isNotEmpty)
          ? p.basename(song.uri!).toLowerCase()
          : song.title.toLowerCase().trim();

      final isDuplicateId = existingIds.contains(song.id);
      final isDuplicateUri = song.uri != null &&
          song.uri!.isNotEmpty &&
          existingUris.contains(song.uri);
      final isDuplicateBasename = existingBasenames.contains(basename);

      if (!isDuplicateId && !isDuplicateUri && !isDuplicateBasename) {
        merged.add(song);
        existingIds.add(song.id);
        existingBasenames.add(basename);
        if (song.uri != null && song.uri!.isNotEmpty) {
          existingUris.add(song.uri!);
        }
      }
    }
    await saveImportedSongs(merged);
  }

  // --- Settings / Preferences ---
  bool get shuffleByDefault => _prefs.getBool(_kShuffleByDefaultKey) ?? false;

  Future<void> setShuffleByDefault(bool value) async {
    await _prefs.setBool(_kShuffleByDefaultKey, value);
  }
}
