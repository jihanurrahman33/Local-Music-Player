import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_music_player/features/library/presentation/album_detail_screen.dart';
import 'package:local_music_player/features/library/presentation/artist_detail_screen.dart';
import 'package:local_music_player/features/library/presentation/library_providers.dart';
import 'package:local_music_player/features/player/presentation/player_providers.dart';
import 'package:local_music_player/features/playlists/presentation/playlist_detail_screen.dart';
import 'package:local_music_player/services/audio_handler.dart';
import 'package:local_music_player/services/persistence_service.dart';
import 'package:local_music_player/shared/models/album.dart';
import 'package:local_music_player/shared/models/artist.dart';
import 'package:local_music_player/shared/models/playlist.dart';
import 'package:local_music_player/shared/models/song.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const song1 = Song(
    id: 's1',
    title: 'Wish You Were Here',
    artist: 'Pink Floyd',
    album: 'Wish You Were Here',
    duration: Duration(minutes: 5, seconds: 34),
  );

  const testAlbum = Album(
    id: 'alb_1',
    title: 'Wish You Were Here',
    artist: 'Pink Floyd',
    songs: [song1],
  );

  const testArtist = Artist(
    id: 'art_1',
    name: 'Pink Floyd',
    songs: [song1],
  );

  const testPlaylist = Playlist(
    id: 'pl_1',
    name: 'Classic Rock',
    songCount: 1,
    songs: [song1],
  );

  late PersistenceService persistence;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    persistence = await PersistenceService.init();
  });

  testWidgets('AlbumDetailScreen renders album details correctly',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          albumsProvider.overrideWithValue([testAlbum]),
          audioHandlerProvider.overrideWithValue(MusicAudioHandler()),
          currentSongProvider.overrideWithValue(null),
          isPlayingProvider.overrideWithValue(false),
          favoritesProvider.overrideWithValue([]),
        ],
        child: const MaterialApp(
          home: AlbumDetailScreen(albumTitle: 'Wish You Were Here'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Wish You Were Here'), findsWidgets);
    expect(find.text('Pink Floyd'), findsWidgets);
    expect(find.text('1 tracks • 5 mins'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Shuffle'), findsOneWidget);
  });

  testWidgets(
      'AlbumDetailScreen renders graceful fallback when album not found',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          albumsProvider.overrideWithValue([]),
          audioHandlerProvider.overrideWithValue(MusicAudioHandler()),
          currentSongProvider.overrideWithValue(null),
          isPlayingProvider.overrideWithValue(false),
          favoritesProvider.overrideWithValue([]),
        ],
        child: const MaterialApp(
          home: AlbumDetailScreen(albumTitle: 'Nonexistent Album'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Album not found'), findsOneWidget);
  });

  testWidgets('ArtistDetailScreen renders artist details correctly',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          artistsProvider.overrideWithValue([testArtist]),
          albumsProvider.overrideWithValue([testAlbum]),
          audioHandlerProvider.overrideWithValue(MusicAudioHandler()),
          currentSongProvider.overrideWithValue(null),
          isPlayingProvider.overrideWithValue(false),
          favoritesProvider.overrideWithValue([]),
        ],
        child: const MaterialApp(
          home: ArtistDetailScreen(artistName: 'Pink Floyd'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Pink Floyd'), findsWidgets);
    expect(find.text('1 songs • 1 albums'), findsOneWidget);
    expect(find.text('Wish You Were Here'), findsWidgets);
  });

  testWidgets(
      'ArtistDetailScreen renders graceful fallback when artist not found',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          artistsProvider.overrideWithValue([]),
          albumsProvider.overrideWithValue([]),
          audioHandlerProvider.overrideWithValue(MusicAudioHandler()),
          currentSongProvider.overrideWithValue(null),
          isPlayingProvider.overrideWithValue(false),
          favoritesProvider.overrideWithValue([]),
        ],
        child: const MaterialApp(
          home: ArtistDetailScreen(artistName: 'Unknown Artist'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Artist not found'), findsOneWidget);
  });

  testWidgets('PlaylistDetailScreen renders playlist details correctly',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playlistsProvider.overrideWithValue([testPlaylist]),
          audioHandlerProvider.overrideWithValue(MusicAudioHandler()),
          currentSongProvider.overrideWithValue(null),
          isPlayingProvider.overrideWithValue(false),
          persistenceServiceProvider.overrideWithValue(persistence),
          favoritesProvider.overrideWithValue([]),
        ],
        child: const MaterialApp(
          home: PlaylistDetailScreen(playlistId: 'pl_1'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Classic Rock'), findsOneWidget);
    expect(find.text('1 tracks'), findsOneWidget);
    expect(find.text('Wish You Were Here'), findsOneWidget);
  });

  testWidgets(
      'PlaylistDetailScreen renders graceful fallback when playlist not found',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playlistsProvider.overrideWithValue([]),
          audioHandlerProvider.overrideWithValue(MusicAudioHandler()),
          currentSongProvider.overrideWithValue(null),
          isPlayingProvider.overrideWithValue(false),
          persistenceServiceProvider.overrideWithValue(persistence),
          favoritesProvider.overrideWithValue([]),
        ],
        child: const MaterialApp(
          home: PlaylistDetailScreen(playlistId: 'pl_missing'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Playlist not found'), findsOneWidget);
  });
}
