import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/audio_handler.dart';
import '../../../shared/models/song.dart';

/// Global AudioHandler provider. Initialized at startup and overridden in tests.
final audioHandlerProvider = Provider<MusicAudioHandler>((ref) {
  throw UnimplementedError(
      'audioHandlerProvider must be overridden with initialized instance');
});

/// PlaybackState stream from AudioHandler
final playbackStateStreamProvider = StreamProvider<PlaybackState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.playbackState;
});

/// Current MediaItem stream from AudioHandler
final currentMediaItemStreamProvider = StreamProvider<MediaItem?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.mediaItem;
});

/// Current playing Song (converted from current MediaItem)
final currentSongProvider = Provider<Song?>((ref) {
  final mediaItemAsync = ref.watch(currentMediaItemStreamProvider);
  final item = mediaItemAsync.value;
  if (item == null) return null;
  return Song.fromMediaItem(item);
});

/// Current Queue MediaItems stream
final queueStreamProvider = StreamProvider<List<MediaItem>>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.queue;
});

/// Current Queue as domain Song list
final queueSongsProvider = Provider<List<Song>>((ref) {
  final queueAsync = ref.watch(queueStreamProvider);
  final items = queueAsync.value ?? [];
  return items.map((item) => Song.fromMediaItem(item)).toList();
});

/// Fine-grained selector for isPlaying to avoid full subtree rebuilds
final isPlayingProvider = Provider<bool>((ref) {
  final playbackStateAsync = ref.watch(playbackStateStreamProvider);
  return playbackStateAsync.value?.playing ?? false;
});

/// Current playback processing state
final processingStateProvider = Provider<AudioProcessingState>((ref) {
  final playbackStateAsync = ref.watch(playbackStateStreamProvider);
  return playbackStateAsync.value?.processingState ?? AudioProcessingState.idle;
});

/// Current repeat mode
final repeatModeProvider = Provider<AudioServiceRepeatMode>((ref) {
  final playbackStateAsync = ref.watch(playbackStateStreamProvider);
  return playbackStateAsync.value?.repeatMode ?? AudioServiceRepeatMode.none;
});

/// Current shuffle mode
final shuffleModeProvider = Provider<AudioServiceShuffleMode>((ref) {
  final playbackStateAsync = ref.watch(playbackStateStreamProvider);
  return playbackStateAsync.value?.shuffleMode ?? AudioServiceShuffleMode.none;
});

/// Live position stream (emitted during playback)
final positionStreamProvider = StreamProvider<Duration>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.positionStream;
});

/// Live duration stream
final durationStreamProvider = StreamProvider<Duration?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.durationStream;
});

/// Buffered position stream
final bufferedPositionStreamProvider = StreamProvider<Duration>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.bufferedPositionStream;
});
