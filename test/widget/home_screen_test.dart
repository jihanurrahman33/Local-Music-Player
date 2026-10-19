import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_music_player/features/home/presentation/home_screen.dart';
import 'package:local_music_player/features/library/presentation/library_providers.dart';
import 'package:local_music_player/features/player/presentation/player_providers.dart';
import 'package:local_music_player/services/audio_handler.dart';
import 'package:local_music_player/shared/models/song.dart';

void main() {
  testWidgets('HomeScreen renders empty state with scan and import buttons',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryNotifierProvider
              .overrideWith((ref) => _EmptyLibraryNotifier()),
          songsProvider.overrideWithValue([]),
          albumsProvider.overrideWithValue([]),
          artistsProvider.overrideWithValue([]),
          recentlyPlayedProvider.overrideWithValue([]),
          mostPlayedProvider.overrideWithValue([]),
          recentlyAddedProvider.overrideWithValue([]),
          audioHandlerProvider.overrideWithValue(MusicAudioHandler()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Music'), findsOneWidget);
    expect(find.text('Your Music Library'), findsOneWidget);
    expect(find.text('Scan Local Storage'), findsOneWidget);
    expect(find.text('Import Audio Files'), findsOneWidget);
  });

  testWidgets('HomeScreen renders music sections when library has songs',
      (tester) async {
    const testSong = Song(
      id: 's_home_1',
      title: 'Get Lucky',
      artist: 'Daft Punk',
      album: 'Random Access Memories',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryNotifierProvider
              .overrideWith((ref) => _PopulatedLibraryNotifier([testSong])),
          songsProvider.overrideWithValue([testSong]),
          albumsProvider.overrideWithValue([]),
          artistsProvider.overrideWithValue([]),
          recentlyPlayedProvider.overrideWithValue([]),
          mostPlayedProvider.overrideWithValue([]),
          recentlyAddedProvider.overrideWithValue([testSong]),
          audioHandlerProvider.overrideWithValue(MusicAudioHandler()),
          currentSongProvider.overrideWithValue(null),
          isPlayingProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Music'), findsOneWidget);
    expect(find.text('Recently added'), findsOneWidget);
    expect(find.text('Get Lucky'), findsOneWidget);
    expect(find.text('Daft Punk'), findsOneWidget);
  });
}

class _EmptyLibraryNotifier extends StateNotifier<AsyncValue<List<Song>>>
    implements LibraryStateNotifier {
  _EmptyLibraryNotifier() : super(const AsyncValue.data([]));

  @override
  Future<void> load({bool refresh = false}) async {}

  @override
  Future<void> importFiles() async {}

  @override
  Future<void> toggleFavorite(String songId) async {}

  @override
  Future<void> clearHistory() async {}
}

class _PopulatedLibraryNotifier extends StateNotifier<AsyncValue<List<Song>>>
    implements LibraryStateNotifier {
  _PopulatedLibraryNotifier(List<Song> songs) : super(AsyncValue.data(songs));

  @override
  Future<void> load({bool refresh = false}) async {}

  @override
  Future<void> importFiles() async {}

  @override
  Future<void> toggleFavorite(String songId) async {}

  @override
  Future<void> clearHistory() async {}
}
