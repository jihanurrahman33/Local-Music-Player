import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../features/player/presentation/player_providers.dart';
import '../models/song.dart';
import 'artwork_image.dart';
import 'song_actions_sheet.dart';

class SongTile extends ConsumerWidget {
  const SongTile({
    super.key,
    required this.song,
    this.playlist,
    this.onTap,
    this.showArtwork = true,
    this.trailing,
  });

  final Song song;
  final List<Song>? playlist;
  final VoidCallback? onTap;
  final bool showArtwork;
  final Widget? trailing;

  String _formatDuration(Duration? d) {
    if (d == null || d.inSeconds <= 0) return '';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final isCurrent = currentSong?.id == song.id;

    final durationStr = _formatDuration(song.duration);
    final subtitleText = durationStr.isNotEmpty
        ? '${song.displayArtist} • $durationStr'
        : song.displayArtist;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: showArtwork
          ? Stack(
              alignment: Alignment.center,
              children: [
                ArtworkImage(
                  artworkUri: song.artworkUri,
                  size: 48,
                  borderRadius: 6,
                ),
                if (isCurrent)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(120),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isPlaying ? Icons.equalizer : Icons.pause,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
              ],
            )
          : null,
      title: Text(
        song.displayTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isCurrent ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
            ),
      ),
      subtitle: Text(
        subtitleText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
      trailing: trailing ??
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onPressed: () => SongActionsSheet.show(context, song),
          ),
      onTap: onTap ??
          () {
            ref.read(audioHandlerProvider).playSong(
                  song,
                  queue: playlist,
                );
          },
    );
  }
}
