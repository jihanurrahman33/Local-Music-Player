import 'package:flutter_test/flutter_test.dart';
import 'package:local_music_player/shared/models/song.dart';

void main() {
  group('Song Model Tests', () {
    test('Song defaults and fallback getters', () {
      const song = Song(id: '1', title: '');
      expect(song.displayTitle, 'Unknown Title');
      expect(song.displayArtist, 'Unknown Artist');
      expect(song.displayAlbum, 'Unknown Album');
      expect(song.isFavorite, isFalse);
      expect(song.playCount, 0);
    });

    test('Song display getters with real metadata', () {
      const song = Song(
        id: '2',
        title: 'Starboy',
        artist: 'The Weeknd',
        album: 'Starboy',
        duration: Duration(seconds: 230),
      );
      expect(song.displayTitle, 'Starboy');
      expect(song.displayArtist, 'The Weeknd');
      expect(song.displayAlbum, 'Starboy');
      expect(song.duration?.inSeconds, 230);
    });

    test('Song copyWith correctly overrides fields', () {
      const song = Song(id: '3', title: 'Old Title', artist: 'Artist A');
      final updated =
          song.copyWith(title: 'New Title', isFavorite: true, playCount: 5);

      expect(updated.id, '3');
      expect(updated.title, 'New Title');
      expect(updated.artist, 'Artist A');
      expect(updated.isFavorite, isTrue);
      expect(updated.playCount, 5);
    });

    test('Song toMediaItem and fromMediaItem roundtrip', () {
      const original = Song(
        id: '4',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        album: 'After Hours',
        duration: Duration(seconds: 200),
        uri: '/path/to/song.mp3',
        trackNumber: 9,
        year: 2020,
        genre: 'Synthwave',
        isFavorite: true,
      );

      final mediaItem = original.toMediaItem();
      expect(mediaItem.id, '4');
      expect(mediaItem.title, 'Blinding Lights');
      expect(mediaItem.artist, 'The Weeknd');
      expect(mediaItem.album, 'After Hours');
      expect(mediaItem.duration?.inSeconds, 200);

      final reconstructed = Song.fromMediaItem(mediaItem);
      expect(reconstructed.id, original.id);
      expect(reconstructed.title, original.title);
      expect(reconstructed.artist, original.artist);
      expect(reconstructed.album, original.album);
      expect(reconstructed.uri, original.uri);
      expect(reconstructed.trackNumber, original.trackNumber);
      expect(reconstructed.year, original.year);
      expect(reconstructed.genre, original.genre);
      expect(reconstructed.isFavorite, isTrue);
    });

    test('Song equality and hashCode', () {
      const s1 = Song(id: 'same', title: 'Title A');
      const s2 = Song(id: 'same', title: 'Title B');
      const s3 = Song(id: 'different', title: 'Title A');

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));
    });
  });
}
