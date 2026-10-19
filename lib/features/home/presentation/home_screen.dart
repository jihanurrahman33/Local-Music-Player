import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/platform/permission_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/album.dart';
import '../../../shared/models/artist.dart';
import '../../../shared/models/song.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../../../shared/widgets/song_tile.dart';
import '../../library/presentation/library_providers.dart';
import '../../player/presentation/player_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryNotifierProvider);
    final songs = ref.watch(songsProvider);
    final albums = ref.watch(albumsProvider);
    final artists = ref.watch(artistsProvider);
    final recentlyPlayed = ref.watch(recentlyPlayedProvider);
    final mostPlayed = ref.watch(mostPlayedProvider);
    final recentlyAdded = ref.watch(recentlyAddedProvider);
    final audioHandler = ref.watch(audioHandlerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceElevated,
          onRefresh: () async {
            await ref
                .read(libraryNotifierProvider.notifier)
                .load(refresh: true);
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.play_circle_fill,
                          color: AppColors.primary, size: 30),
                      const SizedBox(width: 8),
                      Text(
                        'Music',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.file_open_outlined),
                        tooltip: 'Import audio files',
                        onPressed: () {
                          ref
                              .read(libraryNotifierProvider.notifier)
                              .importFiles();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh library',
                        onPressed: () {
                          ref
                              .read(libraryNotifierProvider.notifier)
                              .load(refresh: true);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              if (libraryAsync.isLoading && songs.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (songs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyLibraryState(
                    onScan: () async {
                      final granted =
                          await PermissionService.requestMediaPermission();
                      if (granted) {
                        ref
                            .read(libraryNotifierProvider.notifier)
                            .load(refresh: true);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Permission required to scan local media'),
                              action: SnackBarAction(
                                label: 'Settings',
                                onPressed: () =>
                                    PermissionService.openSettings(),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    onImport: () {
                      ref.read(libraryNotifierProvider.notifier).importFiles();
                    },
                  ),
                )
              else ...[
                // Section: Listen Again (Recently played)
                if (recentlyPlayed.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Listen again',
                      onSeeAll: () => context.go('/library'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 196,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: recentlyPlayed.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, i) {
                          final song = recentlyPlayed[i];
                          return _SongCard(
                            song: song,
                            onTap: () => audioHandler.playSong(song,
                                queue: recentlyPlayed),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Section: Quick Picks (Most played)
                if (mostPlayed.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Quick picks',
                      subtitle: 'Most played by you',
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 196,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: mostPlayed.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, i) {
                          final song = mostPlayed[i];
                          return _SongCard(
                            song: song,
                            onTap: () =>
                                audioHandler.playSong(song, queue: mostPlayed),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Section: Albums
                if (albums.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Albums',
                      onSeeAll: () => context.go('/library'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 196,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: albums.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, i) {
                          final alb = albums[i];
                          return _AlbumCard(
                            album: alb,
                            onTap: () {
                              final albumKey =
                                  Uri.encodeComponent(alb.displayTitle);
                              context.push('/album/$albumKey');
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Section: Artists
                if (artists.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Artists',
                      onSeeAll: () => context.go('/library'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 175,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: artists.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, i) {
                          final art = artists[i];
                          return _ArtistCard(
                            artist: art,
                            onTap: () {
                              final artistKey =
                                  Uri.encodeComponent(art.displayName);
                              context.push('/artist/$artistKey');
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Section: Recently Added (List)
                if (recentlyAdded.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Recently added',
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = recentlyAdded[index];
                        return SongTile(
                          song: song,
                          playlist: recentlyAdded,
                        );
                      },
                      childCount: recentlyAdded.take(10).length,
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 90)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.onSeeAll,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 13),
                ),
              ],
            ],
          ),
          const Spacer(),
          if (onSeeAll != null)
            InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  'More',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  const _SongCard({required this.song, required this.onTap});

  final Song song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArtworkImage(
              artworkUri: song.artworkUri,
              size: 140,
              borderRadius: 8,
              iconSize: 48,
              fallbackIcon: Icons.music_note,
            ),
            const SizedBox(height: 8),
            Text(
              song.displayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 2),
            Text(
              song.displayArtist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.album, required this.onTap});

  final Album album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArtworkImage(
              artworkUri: album.artworkUri,
              size: 140,
              borderRadius: 8,
              iconSize: 48,
              fallbackIcon: Icons.album,
            ),
            const SizedBox(height: 8),
            Text(
              album.displayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 2),
            Text(
              album.displayArtist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistCard extends StatelessWidget {
  const _ArtistCard({required this.artist, required this.onTap});

  final Artist artist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        child: Column(
          children: [
            ClipOval(
              child: ArtworkImage(
                artworkUri: artist.artworkUri,
                size: 110,
                borderRadius: 55,
                iconSize: 44,
                fallbackIcon: Icons.person,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              artist.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 2),
            Text(
              '${artist.songCount} tracks',
              style:
                  const TextStyle(color: AppColors.textTertiary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLibraryState extends StatelessWidget {
  const _EmptyLibraryState({required this.onScan, required this.onImport});

  final VoidCallback onScan;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.music_note,
                  size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Music Library',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Listen to local songs stored on your device.\nNo accounts, no ads, 100% offline.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: onScan,
              icon: const Icon(Icons.search),
              label: const Text('Scan Local Storage',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.divider),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: onImport,
              icon: const Icon(Icons.file_open_outlined),
              label: const Text('Import Audio Files'),
            ),
          ],
        ),
      ),
    );
  }
}
