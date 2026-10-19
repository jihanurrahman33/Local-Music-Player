import 'package:flutter_test/flutter_test.dart';
import 'package:local_music_player/services/media_library_service.dart';
import 'package:local_music_player/services/persistence_service.dart';
import 'package:local_music_player/shared/models/song.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PersistenceService persistence;
  late MediaLibraryService mediaService;

  final sampleSongs = [
    const Song(
      id: 's1',
      title: 'Bohemian Rhapsody',
      artist: 'Queen',
      album: 'A Night at the Opera',
      duration: Duration(seconds: 354),
      trackNumber: 11,
    ),
    const Song(
      id: 's2',
      title: 'Love of My Life',
      artist: 'Queen',
      album: 'A Night at the Opera',
      duration: Duration(seconds: 219),
      trackNumber: 9,
    ),
    const Song(
      id: 's3',
      title: 'Billie Jean',
      artist: 'Michael Jackson',
      album: 'Thriller',
      duration: Duration(seconds: 294),
      genre: 'Pop',
    ),
  ];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    persistence = await PersistenceService.init();
    await persistence.saveImportedSongs(sampleSongs);
    mediaService = MediaLibraryService(persistence);
    await mediaService.loadLibrary();
  });

  group('MediaLibraryService - Grouping', () {
    test('Groups songs into albums correctly', () {
      final albums = mediaService.getAlbums();
      expect(albums.length, 2);

      final queenAlbum =
          albums.firstWhere((a) => a.displayTitle == 'A Night at the Opera');
      expect(queenAlbum.songCount, 2);
      expect(queenAlbum.displayArtist, 'Queen');

      final mjAlbum = albums.firstWhere((a) => a.displayTitle == 'Thriller');
      expect(mjAlbum.songCount, 1);
      expect(mjAlbum.displayArtist, 'Michael Jackson');
    });

    test('Groups songs into artists correctly', () {
      final artists = mediaService.getArtists();
      expect(artists.length, 2);

      final queen = artists.firstWhere((a) => a.displayName == 'Queen');
      expect(queen.songCount, 2);
      expect(queen.albumCount, 1);

      final mj = artists.firstWhere((a) => a.displayName == 'Michael Jackson');
      expect(mj.songCount, 1);
    });
  });

  group('MediaLibraryService - Search', () {
    test('Search finds songs by title', () {
      final result = mediaService.search('Bohemian');
      expect(result.songs.length, 1);
      expect(result.songs.first.title, 'Bohemian Rhapsody');
    });

    test('Search finds songs by artist name', () {
      final result = mediaService.search('Queen');
      expect(result.songs.length, 2);
      expect(result.artists.length, 1);
      expect(result.artists.first.displayName, 'Queen');
    });

    test('Search finds songs by album name', () {
      final result = mediaService.search('Thriller');
      expect(result.songs.length, 1);
      expect(result.albums.length, 1);
      expect(result.albums.first.displayTitle, 'Thriller');
    });

    test('Case-insensitive search matching', () {
      final result = mediaService.search('bIlLiE jEaN');
      expect(result.songs.length, 1);
      expect(result.songs.first.id, 's3');
    });

    test('Empty search query returns empty results', () {
      final result = mediaService.search('   ');
      expect(result.isEmpty, isTrue);
      expect(result.songs, isEmpty);
      expect(result.albums, isEmpty);
      expect(result.artists, isEmpty);
    });
  });
}
