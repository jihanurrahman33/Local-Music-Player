import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_music_player/app/app.dart';
import 'package:local_music_player/features/library/presentation/library_providers.dart';
import 'package:local_music_player/features/player/presentation/player_providers.dart';
import 'package:local_music_player/services/audio_handler.dart';
import 'package:local_music_player/services/persistence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App root smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final persistence = await PersistenceService.init();
    final audioHandler = MusicAudioHandler();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceServiceProvider.overrideWithValue(persistence),
          audioHandlerProvider.overrideWithValue(audioHandler),
        ],
        child: const LocalMusicApp(),
      ),
    );

    await tester.pump();
    expect(find.byType(LocalMusicApp), findsOneWidget);
  });
}
