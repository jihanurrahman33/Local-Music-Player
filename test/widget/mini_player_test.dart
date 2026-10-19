import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_music_player/features/player/presentation/mini_player.dart';
import 'package:local_music_player/features/player/presentation/player_providers.dart';
import 'package:local_music_player/services/audio_handler.dart';
import 'package:local_music_player/shared/models/song.dart';

class MockMusicAudioHandler extends MusicAudioHandler {
  // In-memory mock for widget testing without platform audio channels
}

void main() {
  testWidgets('MiniPlayer is hidden when currentSong is null', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentSongProvider.overrideWithValue(null),
          isPlayingProvider.overrideWithValue(false),
          audioHandlerProvider.overrideWithValue(MockMusicAudioHandler()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: MiniPlayer(),
          ),
        ),
      ),
    );

    expect(find.byType(MiniPlayer), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.play_arrow), findsNothing);
  });

  testWidgets('MiniPlayer displays song title, artist, and playback controls',
      (tester) async {
    const testSong = Song(
      id: 'song_test_1',
      title: 'Midnight City',
      artist: 'M83',
      album: 'Hurry Up, We\'re Dreaming',
      duration: Duration(seconds: 243),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentSongProvider.overrideWithValue(testSong),
          isPlayingProvider.overrideWithValue(true),
          positionStreamProvider
              .overrideWith((ref) => Stream.value(const Duration(seconds: 60))),
          durationStreamProvider.overrideWith(
              (ref) => Stream.value(const Duration(seconds: 243))),
          audioHandlerProvider.overrideWithValue(MockMusicAudioHandler()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: MiniPlayer(),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Midnight City'), findsOneWidget);
    expect(find.text('M83'), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.skip_next), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
