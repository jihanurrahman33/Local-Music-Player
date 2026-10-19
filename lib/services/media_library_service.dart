import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart' as p;
import '../shared/models/album.dart';
import '../shared/models/artist.dart';
import '../shared/models/playlist.dart';
import '../shared/models/song.dart';
import 'persistence_service.dart';

class MediaLibraryService {
  MediaLibraryService(this._persistence);

  final PersistenceService _persistence;
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<Song> _cachedSongs = [];

  List<Song> get cachedSongs => List.unmodifiable(_cachedSongs);

  /// Load all songs by scanning Android MediaStore and merging manually imported files
  Future<List<Song>> loadLibrary({bool refresh = false}) async {
    final songsMap = <String, Song>{};
    final seenUris = <String>{};
    final seenBasenames = <String>{};

    // 1. Load from Android MediaStore if on Android
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final hasPermission = await _audioQuery.permissionsStatus();
        if (hasPermission) {
          final mediaStoreSongs = await _audioQuery.querySongs(
            sortType: SongSortType.DATE_ADDED,
            orderType: OrderType.DESC_OR_GREATER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true,
          );

          for (final model in mediaStoreSongs) {
            // Filter ringtones, notifications, and short clips
            final durationMs = model.duration ?? 0;
            final isNotSystemSound = model.isAlarm != true &&
                model.isNotification != true &&
                model.isRingtone != true;
            if ((durationMs >= 3000 || durationMs == 0) &&
                isNotSystemSound &&
                model.isMusic != false) {
              final song = Song(
                id: 'ms_${model.id}',
                title: (model.title.trim().isNotEmpty)
                    ? model.title.trim()
                    : model.displayNameWOExt,
                artist: (model.artist != null && model.artist != '<unknown>')
                    ? model.artist
                    : 'Unknown Artist',
                album: (model.album != null && model.album != '<unknown>')
                    ? model.album
                    : 'Unknown Album',
                albumId: model.albumId?.toString(),
                artistId: model.artistId?.toString(),
                duration: Duration(milliseconds: durationMs),
                uri: model.data, // File path on device
                trackNumber: model.track,
                year: null,
                dateAdded: model.dateAdded != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                        model.dateAdded! * 1000)
                    : null,
              );
              songsMap[song.id] = song;
              if (song.uri != null && song.uri!.isNotEmpty) {
                seenUris.add(song.uri!);
                seenBasenames.add(p.basename(song.uri!).toLowerCase());
              } else {
                seenBasenames.add(song.title.toLowerCase().trim());
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error querying Android MediaStore: $e');
      }
    }

    // 2. Load manually imported songs (iOS / custom files)
    final imported = _persistence.getImportedSongs();
    for (final song in imported) {
      // Reconcile: check if file still exists on disk (if not Web)
      if (!kIsWeb &&
          song.uri != null &&
          !song.uri!.startsWith('asset') &&
          !song.uri!.startsWith('http') &&
          !song.uri!.startsWith('memory:')) {
        try {
          final file = File(song.uri!);
          if (!file.existsSync()) {
            continue; // Skip deleted file
          }
        } catch (_) {
          // Keep if cannot check
        }
      }

      final basename = (song.uri != null && song.uri!.isNotEmpty)
          ? p.basename(song.uri!).toLowerCase()
          : song.title.toLowerCase().trim();

      // Prevent duplicate if already loaded from MediaStore or prior import
      if (seenBasenames.contains(basename) ||
          (song.uri != null &&
              song.uri!.isNotEmpty &&
              seenUris.contains(song.uri))) {
        continue;
      }

      songsMap[song.id] = song;
      seenBasenames.add(basename);
      if (song.uri != null && song.uri!.isNotEmpty) {
        seenUris.add(song.uri!);
      }
    }

    // 3. Attach favorites and play counts
    final favorites = _persistence.getFavorites();
    final playCounts = _persistence.getPlayCounts();

    _cachedSongs = songsMap.values.map((song) {
      return song.copyWith(
        isFavorite: favorites.contains(song.id),
        playCount: playCounts[song.id] ?? 0,
      );
    }).toList();

    // Default sort by title
    _cachedSongs.sort((a, b) =>
        a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase()));

    return _cachedSongs;
  }

  /// Import audio files from file picker (iOS document picker / desktop / web / manual)
  Future<List<Song>> importFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'wav', 'flac', 'aac', 'ogg', 'opus'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      final imported = <Song>[];
      for (final file in result.files) {
        final path = file.path;
        final name = file.name;
        final title = p.basenameWithoutExtension(name);

        // Derive artist & title if filename is "Artist - Title"
        String parsedArtist = 'Unknown Artist';
        String parsedTitle = title;
        if (title.contains(' - ')) {
          final parts = title.split(' - ');
          parsedArtist = parts[0].trim();
          parsedTitle = parts.sublist(1).join(' - ').trim();
        }

        // Generate deterministic ID based on stable file name/URI so re-importing deduplicates
        final fileUri =
            path ?? (file.bytes != null ? 'memory:${file.name}' : name);
        final fileKey = (file.name.isNotEmpty) ? file.name : (path ?? name);
        final stableId = 'imp_${fileKey.toLowerCase().hashCode.abs()}';

        final song = Song(
          id: stableId,
          title: parsedTitle.isEmpty ? 'Untitled Track' : parsedTitle,
          artist: parsedArtist,
          album: 'Imported Files',
          uri: fileUri,
          dateAdded: DateTime.now(),
        );
        imported.add(song);
      }

      await _persistence.addImportedSongs(imported);
      await loadLibrary(refresh: true);
      return imported;
    } catch (e) {
      debugPrint('Error importing audio files: $e');
      return [];
    }
  }

  /// Toggle song favorite
  Future<bool> toggleFavorite(String songId) async {
    final isFav = await _persistence.toggleFavorite(songId);
    final index = _cachedSongs.indexWhere((s) => s.id == songId);
    if (index >= 0) {
      _cachedSongs[index] = _cachedSongs[index].copyWith(isFavorite: isFav);
    }
    return isFav;
  }

  /// Record a song play
  Future<void> recordPlay(String songId) async {
    await _persistence.recordPlay(songId);
    final index = _cachedSongs.indexWhere((s) => s.id == songId);
    if (index >= 0) {
      final updatedCount = _cachedSongs[index].playCount + 1;
      _cachedSongs[index] =
          _cachedSongs[index].copyWith(playCount: updatedCount);
    }
  }

  /// Clear play history
  Future<void> clearHistory() async {
    await _persistence.clearHistory();
    for (int i = 0; i < _cachedSongs.length; i++) {
      _cachedSongs[i] = _cachedSongs[i].copyWith(playCount: 0);
    }
  }

  /// Group cached songs into Albums
  List<Album> getAlbums() {
    final albumMap = <String, List<Song>>{};
    for (final song in _cachedSongs) {
      final key = song.displayAlbum;
      albumMap.putIfAbsent(key, () => []).add(song);
    }

    final albums = albumMap.entries.map((entry) {
      final songs = entry.value;
      final first = songs.first;
      return Album(
        id: first.albumId ?? 'alb_${entry.key.hashCode}',
        title: entry.key,
        artist: first.displayArtist,
        artworkUri: first.artworkUri,
        songCount: songs.length,
        songs: songs,
      );
    }).toList();

    albums.sort((a, b) =>
        a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase()));
    return albums;
  }

  /// Group cached songs into Artists
  List<Artist> getArtists() {
    final artistMap = <String, List<Song>>{};
    for (final song in _cachedSongs) {
      final key = song.displayArtist;
      artistMap.putIfAbsent(key, () => []).add(song);
    }

    final artists = artistMap.entries.map((entry) {
      final songs = entry.value;
      final albums = <String>{};
      for (final s in songs) {
        albums.add(s.displayAlbum);
      }
      return Artist(
        id: songs.first.artistId ?? 'art_${entry.key.hashCode}',
        name: entry.key,
        songCount: songs.length,
        albumCount: albums.length,
        artworkUri: songs.first.artworkUri,
        songs: songs,
      );
    }).toList();

    artists.sort((a, b) =>
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    return artists;
  }

  /// Get user playlists with resolved Song objects
  List<Playlist> getPlaylists() {
    final records = _persistence.getPlaylists();
    final songLookup = {for (final s in _cachedSongs) s.id: s};

    return records.map((record) {
      final songs =
          record.songIds.map((id) => songLookup[id]).whereType<Song>().toList();
      return Playlist(
        id: record.id,
        name: record.name,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        songCount: songs.length,
        songs: songs,
        artworkUri: songs.isNotEmpty ? songs.first.artworkUri : null,
      );
    }).toList();
  }

  /// Get favorite songs
  List<Song> getFavorites() {
    return _cachedSongs.where((s) => s.isFavorite).toList();
  }

  /// Get recently played songs
  List<Song> getRecentlyPlayed() {
    final history = _persistence.getHistory();
    final songLookup = {for (final s in _cachedSongs) s.id: s};
    final seen = <String>{};
    final result = <Song>[];

    for (final entry in history) {
      if (!seen.contains(entry.songId)) {
        seen.add(entry.songId);
        final song = songLookup[entry.songId];
        if (song != null) {
          result.add(song);
        }
      }
    }
    return result;
  }

  /// Get most played songs
  List<Song> getMostPlayed({int limit = 20}) {
    final list = _cachedSongs.where((s) => s.playCount > 0).toList();
    list.sort((a, b) => b.playCount.compareTo(a.playCount));
    return list.take(limit).toList();
  }

  /// Get recently added songs
  List<Song> getRecentlyAdded({int limit = 20}) {
    final list = [..._cachedSongs];
    list.sort((a, b) {
      final aDate = a.dateAdded ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.dateAdded ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return list.take(limit).toList();
  }

  /// Search across songs, albums, and artists
  SearchResults search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return const SearchResults.empty();
    }

    final matchedSongs = _cachedSongs.where((s) {
      return s.displayTitle.toLowerCase().contains(q) ||
          s.displayArtist.toLowerCase().contains(q) ||
          s.displayAlbum.toLowerCase().contains(q) ||
          (s.genre?.toLowerCase().contains(q) ?? false);
    }).toList();

    final matchedAlbums = getAlbums().where((a) {
      return a.displayTitle.toLowerCase().contains(q) ||
          a.displayArtist.toLowerCase().contains(q);
    }).toList();

    final matchedArtists = getArtists().where((art) {
      return art.displayName.toLowerCase().contains(q);
    }).toList();

    return SearchResults(
      songs: matchedSongs,
      albums: matchedAlbums,
      artists: matchedArtists,
    );
  }
}

class SearchResults {
  const SearchResults({
    this.songs = const [],
    this.albums = const [],
    this.artists = const [],
  });

  const SearchResults.empty()
      : songs = const [],
        albums = const [],
        artists = const [];

  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> artists;

  bool get isEmpty => songs.isEmpty && albums.isEmpty && artists.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
