import 'package:flutter_test/flutter_test.dart';
import 'package:local_music_player/shared/models/album.dart';
import 'package:local_music_player/shared/models/artist.dart';
import 'package:local_music_player/shared/models/playlist.dart';
import 'package:local_music_player/shared/models/song.dart';

void main() {
  group('Album Model Tests', () {
    test('Album fallback display fields', () {
      const album = Album(id: 'a1', title: '');
      expect(album.displayTitle, 'Unknown Album');
      expect(album.displayArtist, 'Unknown Artist');
    });

    test('Album with songs copyWith', () {
      const song = Song(id: 's1', title: 'Song 1');
      const album =
          Album(id: 'a2', title: 'My Album', songs: [song], songCount: 1);
      expect(album.songs.length, 1);
      final copy = album.copyWith(title: 'New Album');
      expect(copy.title, 'New Album');
      expect(copy.songCount, 1);
    });
  });

  group('Artist Model Tests', () {
    test('Artist fallback displayName', () {
      const artist = Artist(id: 'art1', name: '');
      expect(artist.displayName, 'Unknown Artist');
    });

    test('Artist equality and copyWith', () {
      const a1 = Artist(id: 'art2', name: 'Queen');
      const a2 = Artist(id: 'art2', name: 'Queen Band');
      expect(a1, equals(a2));

      final updated = a1.copyWith(songCount: 10, albumCount: 3);
      expect(updated.songCount, 10);
      expect(updated.albumCount, 3);
    });
  });

  group('Playlist Model Tests', () {
    test('Playlist fallback displayName', () {
      const pl = Playlist(id: 'p1', name: '');
      expect(pl.displayName, 'Untitled Playlist');
    });

    test('Playlist copyWith and equality', () {
      const pl1 = Playlist(id: 'p2', name: 'Chill Vibes');
      const pl2 = Playlist(id: 'p2', name: 'Chill Vibes 2');
      expect(pl1, equals(pl2));

      final updated = pl1.copyWith(name: 'Workout Mix', songCount: 5);
      expect(updated.name, 'Workout Mix');
      expect(updated.songCount, 5);
    });
  });
}
