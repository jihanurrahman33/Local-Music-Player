import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../shared/models/song.dart';

/// Single authoritative AudioHandler connecting just_audio with system audio_service.
class MusicAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  MusicAudioHandler() {
    _init();
  }

  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist =
      ConcatenatingAudioSource(children: []);

  AudioPlayer get player => _player;

  Future<void> _init() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(0.5);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              _player.pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
              _player.play();
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });

      session.becomingNoisyEventStream.listen((_) {
        _player.pause();
      });
    } catch (e) {
      debugPrint('AudioSession configuration skipped: $e');
    }

    // Forward player playback events to AudioService
    _player.playbackEventStream.listen((event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.setShuffleMode,
          MediaAction.setRepeatMode,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });

    // Forward sequence state changes (current item & queue)
    _player.sequenceStateStream.listen((sequenceState) {
      final sequence = sequenceState?.sequence ?? [];
      final items = sequence.map((s) => s.tag as MediaItem).toList();
      queue.add(items);

      if (sequenceState?.currentSource != null) {
        mediaItem.add(sequenceState!.currentSource!.tag as MediaItem);
      } else if (items.isEmpty) {
        mediaItem.add(null);
      }
    });

    try {
      await _player.setAudioSource(_playlist, preload: false);
    } catch (e) {
      debugPrint('Error attaching initial playlist: $e');
    }
  }

  AudioSource _createAudioSource(MediaItem item) {
    final uriStr = item.extras?['uri'] as String? ?? item.id;
    Uri uri;
    if (uriStr.startsWith('http://') ||
        uriStr.startsWith('https://') ||
        uriStr.startsWith('content://')) {
      uri = Uri.parse(uriStr);
    } else if (uriStr.startsWith('asset://') || uriStr.startsWith('asset:')) {
      uri = Uri.parse(uriStr);
    } else {
      uri = Uri.file(uriStr);
    }
    return AudioSource.uri(uri, tag: item);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else {
      await _player.seekToPrevious();
    }
  }

  @override
  Future<void> skipToQueueItem(int index) =>
      _player.seek(Duration.zero, index: index);

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        await _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all ||
        shuffleMode == AudioServiceShuffleMode.group;
    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
    if (enabled) {
      await _player.shuffle();
    }
    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await _playlist.add(_createAudioSource(mediaItem));
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    await _playlist.addAll(mediaItems.map(_createAudioSource).toList());
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    await _playlist.insert(index, _createAudioSource(mediaItem));
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index >= 0 && index < _playlist.length) {
      await _playlist.removeAt(index);
    }
  }

  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    if (oldIndex >= 0 &&
        oldIndex < _playlist.length &&
        newIndex >= 0 &&
        newIndex < _playlist.length) {
      await _playlist.move(oldIndex, newIndex);
    }
  }

  /// High level helper: Play a song with an optional context queue
  Future<void> playSong(Song song,
      {List<Song>? queue, int initialIndex = 0}) async {
    final songs = (queue != null && queue.isNotEmpty) ? queue : [song];
    final targetIndex = (queue != null && queue.isNotEmpty)
        ? queue.indexWhere((s) => s.id == song.id)
        : 0;
    final resolvedIndex = targetIndex >= 0 ? targetIndex : initialIndex;

    final mediaItems = songs.map((s) => s.toMediaItem()).toList();
    final sources = mediaItems.map(_createAudioSource).toList();

    await _player.stop();
    await _playlist.clear();
    await _playlist.addAll(sources);

    try {
      await _player.seek(Duration.zero, index: resolvedIndex);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing audio source: $e');
    }
  }

  /// Play this song right after the current playing song
  Future<void> playNext(Song song) async {
    final item = song.toMediaItem();
    final currentIndex = _player.currentIndex ?? -1;
    final insertIndex = currentIndex >= 0 ? currentIndex + 1 : _playlist.length;
    await insertQueueItem(insertIndex, item);
  }

  /// Append this song to the end of the queue
  Future<void> addToQueue(Song song) async {
    await addQueueItem(song.toMediaItem());
  }

  /// Clear all tracks from the queue
  Future<void> clearQueue() async {
    await _player.stop();
    await _playlist.clear();
    mediaItem.add(null);
  }

  /// Toggle play / pause state
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  /// Dispose player resources
  Future<void> dispose() async {
    await _player.dispose();
  }
}
