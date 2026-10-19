import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../../../shared/widgets/song_tile.dart';
import '../../player/presentation/player_providers.dart';
import 'library_providers.dart';

class ArtistDetailScreen extends ConsumerWidget {
  const ArtistDetailScreen({super.key, required this.artistName});

  final String artistName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artists = ref.watch(artistsProvider);
    final decodedName = Uri.decodeComponent(artistName).toLowerCase();
    final artist = artists
        .where((a) =>
            a.displayName.toLowerCase() == decodedName || a.id == artistName)
        .firstOrNull;

    if (artist == null) {
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
            'Artist not found',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final audioHandler = ref.watch(audioHandlerProvider);
    final songs = artist.songs;
    final albums = ref
        .watch(albumsProvider)
        .where((a) => a.displayArtist == artist.displayName)
        .toList();

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
                  // Circular Artist Artwork
                  ClipOval(
                    child: ArtworkImage(
                      artworkUri: artist.artworkUri,
                      size: 160,
                      borderRadius: 80,
                      iconSize: 64,
                      fallbackIcon: Icons.person,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    artist.displayName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${songs.length} songs • ${albums.length} albums',
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
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
                  if (albums.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Albums',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: albums.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final alb = albums[i];
                          return GestureDetector(
                            onTap: () {
                              final albumKey =
                                  Uri.encodeComponent(alb.displayTitle);
                              context.push('/album/$albumKey');
                            },
                            child: SizedBox(
                              width: 110,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ArtworkImage(
                                    artworkUri: alb.artworkUri,
                                    size: 110,
                                    borderRadius: 8,
                                    fallbackIcon: Icons.album,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    alb.displayTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),
                                  Text(
                                    '${alb.songCount} tracks',
                                    style: const TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Songs',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
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
                  showArtwork: true,
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
