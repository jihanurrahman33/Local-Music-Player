import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'features/library/presentation/library_providers.dart';
import 'features/player/presentation/player_providers.dart';
import 'services/audio_handler.dart';
import 'services/persistence_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Persistence Service
  final persistenceService = await PersistenceService.init();

  // Initialize AudioService and authoritative MusicAudioHandler
  late final MusicAudioHandler audioHandler;
  try {
    audioHandler = await AudioService.init<MusicAudioHandler>(
      builder: () => MusicAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.localmusicplayer.channel.audio',
        androidNotificationChannelName: 'Music Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
      ),
    );
  } catch (e) {
    debugPrint('AudioService.init fallback to direct MusicAudioHandler: $e');
    audioHandler = MusicAudioHandler();
  }

  runApp(
    ProviderScope(
      overrides: [
        persistenceServiceProvider.overrideWithValue(persistenceService),
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const LocalMusicApp(),
    ),
  );
}
