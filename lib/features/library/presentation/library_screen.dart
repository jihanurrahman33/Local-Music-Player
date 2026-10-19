import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../../../shared/widgets/song_tile.dart';
import '../../player/presentation/player_providers.dart';
import 'library_providers.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(songsProvider);
    final albums = ref.watch(albumsProvider);
    final artists = ref.watch(artistsProvider);
    final playlists = ref.watch(playlistsProvider);
    final favorites = ref.watch(favoritesProvider);
    final audioHandler = ref.watch(audioHandlerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Text('Library',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.file_open_outlined),
                    tooltip: 'Import audio files',
                    onPressed: () {
                      ref.read(libraryNotifierProvider.notifier).importFiles();
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
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'Songs (${songs.length})'),
                Tab(text: 'Albums (${albums.length})'),
                Tab(text: 'Artists (${artists.length})'),
                Tab(text: 'Playlists (${playlists.length})'),
                Tab(text: 'Favorites (${favorites.length})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Songs
                  songs.isEmpty
                      ? _EmptyTab(
                          icon: Icons.music_note,
                          message: 'No songs found in local storage',
                          actionLabel: 'Import Audio Files',
                          onAction: () => ref
                              .read(libraryNotifierProvider.notifier)
                              .importFiles(),
                        )
                      : CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 12, 16, 8),
                                child: Row(
                                  children: [
                                    FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            AppColors.surfaceHighlight,
                                        foregroundColor: AppColors.textPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      onPressed: () async {
                                        final shuffled = [...songs]..shuffle();
                                        await audioHandler.playSong(
                                            shuffled.first,
                                            queue: shuffled);
                                      },
                                      icon: const Icon(Icons.shuffle, size: 18),
                                      label: const Text('Shuffle all'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, i) => SongTile(
                                  song: songs[i],
                                  playlist: songs,
                                ),
                                childCount: songs.length,
                              ),
                            ),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 90)),
                          ],
                        ),

                  // Tab 2: Albums
                  albums.isEmpty
                      ? const _EmptyTab(
                          icon: Icons.album_outlined,
                          message: 'No albums found in library',
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.76,
                          ),
                          itemCount: albums.length,
                          itemBuilder: (context, i) {
                            final alb = albums[i];
                            return GestureDetector(
                              onTap: () {
                                final albumKey =
                                    Uri.encodeComponent(alb.displayTitle);
                                context.push('/album/$albumKey');
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: ArtworkImage(
                                      artworkUri: alb.artworkUri,
                                      size: double.infinity,
                                      borderRadius: 8,
                                      fallbackIcon: Icons.album,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    alb.displayTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    '${alb.displayArtist} • ${alb.songCount} tracks',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                  // Tab 3: Artists
                  artists.isEmpty
                      ? const _EmptyTab(
                          icon: Icons.person_outline,
                          message: 'No artists found in library',
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: artists.length,
                          itemBuilder: (context, i) {
                            final art = artists[i];
                            return GestureDetector(
                              onTap: () {
                                final artistKey =
                                    Uri.encodeComponent(art.displayName);
                                context.push('/artist/$artistKey');
                              },
                              child: Column(
                                children: [
                                  ClipOval(
                                    child: ArtworkImage(
                                      artworkUri: art.artworkUri,
                                      size: 130,
                                      borderRadius: 65,
                                      fallbackIcon: Icons.person,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    art.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    '${art.songCount} tracks',
                                    style: const TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                  // Tab 4: Playlists
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Row(
                            children: [
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () =>
                                    _createPlaylistDialog(context, ref),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('New playlist'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (playlists.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyTab(
                            icon: Icons.queue_music,
                            message: 'No playlists created yet',
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final pl = playlists[i];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                leading: ArtworkImage(
                                  artworkUri: pl.artworkUri,
                                  size: 48,
                                  borderRadius: 6,
                                  fallbackIcon: Icons.queue_music,
                                ),
                                title: Text(pl.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text('${pl.songCount} tracks',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary)),
                                trailing: const Icon(Icons.chevron_right,
                                    color: AppColors.textTertiary),
                                onTap: () => context.push('/playlist/${pl.id}'),
                              );
                            },
                            childCount: playlists.length,
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 90)),
                    ],
                  ),

                  // Tab 5: Favorites
                  favorites.isEmpty
                      ? const _EmptyTab(
                          icon: Icons.favorite_border,
                          message:
                              'No favorites marked yet.\nTap the heart icon on any track.',
                        )
                      : ListView.builder(
                          itemCount: favorites.length,
                          itemBuilder: (context, i) {
                            return SongTile(
                              song: favorites[i],
                              playlist: favorites,
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createPlaylistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    void submit(BuildContext ctx) async {
      final name = controller.text.trim();
      final playlistName = name.isEmpty ? 'New Playlist' : name;
      await ref.read(persistenceServiceProvider).createPlaylist(playlistName);
      ref.read(libraryNotifierProvider.notifier).load();
      if (ctx.mounted) Navigator.pop(ctx);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Create playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => submit(ctx),
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => submit(ctx),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                style:
                    FilledButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
