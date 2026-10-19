import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../../../shared/widgets/song_actions_sheet.dart';
import '../../library/presentation/library_providers.dart';
import '../../queue/presentation/queue_sheet.dart';
import 'player_providers.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  double? _dragValue;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = ref.watch(currentSongProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final audioHandler = ref.watch(audioHandlerProvider);
    final repeatMode = ref.watch(repeatModeProvider);
    final shuffleMode = ref.watch(shuffleModeProvider);

    final positionAsync = ref.watch(positionStreamProvider);
    final durationAsync = ref.watch(durationStreamProvider);

    final position = positionAsync.value ?? Duration.zero;
    final duration =
        durationAsync.value ?? currentSong?.duration ?? Duration.zero;

    final isShuffle = shuffleMode == AudioServiceShuffleMode.all;
    final favorites = ref.watch(favoritesProvider);
    final isFavorite =
        currentSong != null && favorites.any((s) => s.id == currentSong.id);

    final screenWidth = MediaQuery.of(context).size.width;
    final artworkSize = min(screenWidth - 64, 340.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: (currentSong == null)
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.music_off,
                        size: 64, color: AppColors.textTertiary),
                    const SizedBox(height: 16),
                    const Text('No song currently playing',
                        style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to library'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Top bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () =>
                              SongActionsSheet.show(context, currentSong),
                        ),
                      ],
                    ),
                  ),

                  // Large Artwork with soft shadow
                  Expanded(
                    child: Center(
                      child: Container(
                        width: artworkSize,
                        height: artworkSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(120),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: ArtworkImage(
                          artworkUri: currentSong.artworkUri,
                          size: artworkSize,
                          borderRadius: 16,
                          iconSize: 84,
                          fallbackIcon: Icons.album,
                        ),
                      ),
                    ),
                  ),

                  // Song Title & Artist
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          currentSong.displayTitle,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentSong.displayArtist,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Progress Bar & Durations
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14),
                            activeTrackColor: AppColors.primary,
                            thumbColor: AppColors.primary,
                            inactiveTrackColor: AppColors.surfaceHighlight,
                          ),
                          child: Slider(
                            min: 0.0,
                            max: max(duration.inMilliseconds.toDouble(), 1.0),
                            value: (_dragValue ??
                                    position.inMilliseconds.toDouble())
                                .clamp(
                                    0.0,
                                    max(duration.inMilliseconds.toDouble(),
                                        1.0)),
                            onChanged: (val) {
                              setState(() {
                                _dragValue = val;
                              });
                            },
                            onChangeEnd: (val) {
                              audioHandler
                                  .seek(Duration(milliseconds: val.round()));
                              setState(() {
                                _dragValue = null;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_dragValue != null
                                    ? Duration(
                                        milliseconds: _dragValue!.round())
                                    : position),
                                style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Playback Controls
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Shuffle
                        IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            size: 26,
                            color: isShuffle
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          onPressed: () {
                            audioHandler.setShuffleMode(
                              isShuffle
                                  ? AudioServiceShuffleMode.none
                                  : AudioServiceShuffleMode.all,
                            );
                          },
                        ),
                        // Previous
                        IconButton(
                          icon: const Icon(Icons.skip_previous, size: 38),
                          color: AppColors.textPrimary,
                          onPressed: () => audioHandler.skipToPrevious(),
                        ),
                        // Play / Pause
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: AppColors.textPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 42,
                              color: Colors.black,
                            ),
                            onPressed: () => audioHandler.togglePlayPause(),
                          ),
                        ),
                        // Next
                        IconButton(
                          icon: const Icon(Icons.skip_next, size: 38),
                          color: AppColors.textPrimary,
                          onPressed: () => audioHandler.skipToNext(),
                        ),
                        // Repeat
                        IconButton(
                          icon: Icon(
                            repeatMode == AudioServiceRepeatMode.one
                                ? Icons.repeat_one
                                : Icons.repeat,
                            size: 26,
                            color: repeatMode != AudioServiceRepeatMode.none
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          onPressed: () {
                            final next = switch (repeatMode) {
                              AudioServiceRepeatMode.none =>
                                AudioServiceRepeatMode.all,
                              AudioServiceRepeatMode.all =>
                                AudioServiceRepeatMode.one,
                              _ => AudioServiceRepeatMode.none,
                            };
                            audioHandler.setRepeatMode(next);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Bottom Action bar (Favorite & Up Next Queue)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 4, 28, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 26,
                          ),
                          onPressed: () {
                            ref
                                .read(libraryNotifierProvider.notifier)
                                .toggleFavorite(currentSong.id);
                          },
                        ),
                        TextButton.icon(
                          onPressed: () => QueueSheet.show(context),
                          icon: const Icon(Icons.queue_music,
                              color: AppColors.textSecondary, size: 22),
                          label: const Text(
                            'UP NEXT',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
