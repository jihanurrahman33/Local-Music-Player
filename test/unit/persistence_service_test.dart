import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_music_player/services/persistence_service.dart';
import 'package:local_music_player/shared/models/song.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PersistenceService persistence;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    persistence = await PersistenceService.init();
  });

  group('PersistenceService - Favorites', () {
    test('Toggle favorite adds and removes song ID', () async {
      expect(persistence.isFavorite('song_1'), isFalse);

      final added = await persistence.toggleFavorite('song_1');
      expect(added, isTrue);
      expect(persistence.isFavorite('song_1'), isTrue);
      expect(persistence.getFavorites(), contains('song_1'));

      final removed = await persistence.toggleFavorite('song_1');
      expect(removed, isFalse);
      expect(persistence.isFavorite('song_1'), isFalse);
      expect(persistence.getFavorites(), isEmpty);
    });
  });

  group('PersistenceService - Playlists', () {
    test('Playlist CRUD and song management', () async {
      final pl = await persistence.createPlaylist('Favorites of 2026');
      expect(pl.name, 'Favorites of 2026');

      var list = persistence.getPlaylists();
      expect(list.length, 1);
      expect(list.first.id, pl.id);

      // Add songs
      await persistence.addSongToPlaylist(pl.id, 's_10');
      await persistence.addSongToPlaylist(pl.id, 's_20');
      await persistence.addSongToPlaylist(pl.id, 's_30');

      list = persistence.getPlaylists();
      expect(list.first.songIds, ['s_10', 's_20', 's_30']);

      // Reorder song
      await persistence.reorderPlaylistSong(pl.id, 0, 2);
      list = persistence.getPlaylists();
      expect(list.first.songIds, ['s_20', 's_10', 's_30']);

      // Remove song
      await persistence.removeSongFromPlaylist(pl.id, 's_10');
      list = persistence.getPlaylists();
      expect(list.first.songIds, ['s_20', 's_30']);

      // Rename playlist
      await persistence.renamePlaylist(pl.id, 'Summer Party');
      list = persistence.getPlaylists();
      expect(list.first.name, 'Summer Party');

      // Delete playlist
      await persistence.deletePlaylist(pl.id);
      list = persistence.getPlaylists();
      expect(list, isEmpty);
    });
  });

  group('PersistenceService - History & Play Counts', () {
    test('Record play and aggregate play counts', () async {
      await persistence.recordPlay('song_a');
      await persistence.recordPlay('song_b');
      await persistence.recordPlay('song_a');

      final history = persistence.getHistory();
      expect(history.length, 3);
      expect(history.first.songId, 'song_a');

      final counts = persistence.getPlayCounts();
      expect(counts['song_a'], 2);
      expect(counts['song_b'], 1);

      await persistence.clearHistory();
      expect(persistence.getHistory(), isEmpty);
      expect(persistence.getPlayCounts(), isEmpty);
    });
  });

  group('PersistenceService - Imported Songs & Preferences', () {
    test('Add imported songs and prevent duplicate IDs', () async {
      const song1 = Song(id: 'imp_1', title: 'Track 1');
      const song2 = Song(id: 'imp_2', title: 'Track 2');

      await persistence.addImportedSongs([song1, song2]);
      var imported = persistence.getImportedSongs();
      expect(imported.length, 2);

      // Adding same song again should not duplicate
      await persistence.addImportedSongs([song1]);
      imported = persistence.getImportedSongs();
      expect(imported.length, 2);
    });

    test('Prevent duplicate imports with same URI but different IDs', () async {
      const songA =
          Song(id: 'imp_1', title: 'Song A', uri: '/music/song_a.mp3');
      const songB =
          Song(id: 'imp_2', title: 'Song A Copy', uri: '/music/song_a.mp3');

      await persistence.addImportedSongs([songA, songB]);
      final imported = persistence.getImportedSongs();
      // Only one song should be saved for the same file URI
      expect(imported.where((s) => s.uri == '/music/song_a.mp3').length, 1);
    });

    test('getImportedSongs prunes existing duplicate URIs from persistence',
        () async {
      final duplicateList = [
        {'id': 'dup1', 'title': 'Track', 'uri': '/music/track.mp3'},
        {'id': 'dup2', 'title': 'Track', 'uri': '/music/track.mp3'},
        {'id': 'dup3', 'title': 'Track', 'uri': '/music/track.mp3'},
      ];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'local_music_imported_songs', jsonEncode(duplicateList));

      final cleaned = persistence.getImportedSongs();
      expect(cleaned.length, 1);
      expect(cleaned.first.id, 'dup1');
    });

    test('Shuffle by default preference', () async {
      expect(persistence.shuffleByDefault, isFalse);
      await persistence.setShuffleByDefault(true);
      expect(persistence.shuffleByDefault, isTrue);
    });
  });
}
