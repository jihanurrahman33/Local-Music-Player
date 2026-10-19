import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../../../shared/widgets/song_actions_sheet.dart';
import '../../../shared/widgets/song_tile.dart';
import '../../player/presentation/player_providers.dart';
import 'library_providers.dart';

class AlbumDetailScreen extends ConsumerWidget {
  const AlbumDetailScreen({super.key, required this.albumTitle});

  final String albumTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(albumsProvider);
    final decodedTitle = Uri.decodeComponent(albumTitle).toLowerCase();
    final album = albums
        .where((a) =>
            a.displayTitle.toLowerCase() == decodedTitle || a.id == albumTitle)
        .firstOrNull;

    if (album == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'Album not found',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final audioHandler = ref.watch(audioHandlerProvider);
    final songs = album.songs;

    Duration totalDuration = Duration.zero;
    for (final s in songs) {
      if (s.duration != null) {
        totalDuration += s.duration!;
      }
    }
    final totalMinutes = totalDuration.inMinutes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  // Album Art
                  ArtworkImage(
                    artworkUri: album.artworkUri,
                    size: 200,
                    borderRadius: 12,
                    iconSize: 72,
                    fallbackIcon: Icons.album,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    album.displayTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    album.displayArtist,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${songs.length} tracks • $totalMinutes mins',
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  // Play & Shuffle Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: songs.isEmpty
                            ? null
                            : () => audioHandler.playSong(songs.first,
                                queue: songs),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.divider),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: songs.isEmpty
                            ? null
                            : () async {
                                final shuffled = [...songs]..shuffle();
                                await audioHandler.playSong(shuffled.first,
                                    queue: shuffled);
                              },
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Shuffle'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = songs[index];
                return SongTile(
                  song: song,
                  playlist: songs,
                  showArtwork: false,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (song.trackNumber != null && song.trackNumber! > 0)
                            ? '${song.trackNumber}'
                            : '${index + 1}',
                        style: const TextStyle(
                            color: AppColors.textTertiary, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.more_vert,
                            color: AppColors.textSecondary),
                        onPressed: () => SongActionsSheet.show(context, song),
                      ),
                    ],
                  ),
                );
              },
              childCount: songs.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
    );
  }
}
