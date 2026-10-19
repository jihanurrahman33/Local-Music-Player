import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_music_player/features/library/presentation/library_providers.dart';
import 'package:local_music_player/features/library/presentation/library_screen.dart';
import 'package:local_music_player/features/player/presentation/player_providers.dart';
import 'package:local_music_player/services/audio_handler.dart';
import 'package:local_music_player/shared/models/song.dart';

void main() {
  testWidgets('LibraryScreen renders all 5 tabs and responds to tab switching',
      (tester) async {
    const testSong = Song(
      id: 'lib_s1',
      title: 'Comfortably Numb',
      artist: 'Pink Floyd',
      album: 'The Wall',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          songsProvider.overrideWithValue([testSong]),
          albumsProvider.overrideWithValue([]),
          artistsProvider.overrideWithValue([]),
          playlistsProvider.overrideWithValue([]),
          favoritesProvider.overrideWithValue([]),
          audioHandlerProvider.overrideWithValue(MusicAudioHandler()),
          currentSongProvider.overrideWithValue(null),
          isPlayingProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(
          home: LibraryScreen(),
        ),
      ),
    );

    await tester.pump();

    // Verify tabs
    expect(find.text('Songs (1)'), findsOneWidget);
    expect(find.text('Albums (0)'), findsOneWidget);
    expect(find.text('Artists (0)'), findsOneWidget);
    expect(find.text('Playlists (0)'), findsOneWidget);
    expect(find.text('Favorites (0)'), findsOneWidget);

    // Verify song tile in Songs tab
    expect(find.text('Comfortably Numb'), findsOneWidget);
    expect(find.text('Pink Floyd'), findsOneWidget);

    // Tap Albums tab
    await tester.tap(find.text('Albums (0)'));
    await tester.pumpAndSettle();

    expect(find.text('No albums found in library'), findsOneWidget);
  });
}
