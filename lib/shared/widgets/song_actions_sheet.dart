import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../features/library/presentation/library_providers.dart';
import '../../features/player/presentation/player_providers.dart';
import '../models/song.dart';
import 'artwork_image.dart';

class SongActionsSheet extends ConsumerWidget {
  const SongActionsSheet({super.key, required this.song});

  final Song song;

  static void show(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SongActionsSheet(song: song),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.any((s) => s.id == song.id);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withAlpha(100),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Song Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                ArtworkImage(
                  artworkUri: song.artworkUri,
                  size: 52,
                  borderRadius: 6,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${song.displayArtist} • ${song.displayAlbum}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Actions
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Play now'),
            onTap: () {
              Navigator.pop(context);
              audioHandler.playSong(song);
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_play),
            title: const Text('Play next'),
            onTap: () {
              Navigator.pop(context);
              audioHandler.playNext(song);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Playing next')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.queue_music),
            title: const Text('Add to queue'),
            onTap: () {
              Navigator.pop(context);
              audioHandler.addToQueue(song);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to queue')),
              );
            },
          ),
          ListTile(
            leading: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? AppColors.primary : null),
            title: Text(isFav ? 'Remove from favorites' : 'Add to favorites'),
            onTap: () {
              Navigator.pop(context);
              ref
                  .read(libraryNotifierProvider.notifier)
                  .toggleFavorite(song.id);
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Add to playlist'),
            onTap: () {
              Navigator.pop(context);
              _showAddToPlaylistDialog(context, ref);
            },
          ),
          if (song.album != null && song.album!.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.album_outlined),
              title: const Text('Go to album'),
              onTap: () {
                Navigator.pop(context);
                final albumKey = Uri.encodeComponent(song.displayAlbum);
                context.push('/album/$albumKey');
              },
            ),
          if (song.artist != null && song.artist!.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Go to artist'),
              onTap: () {
                Navigator.pop(context);
                final artistKey = Uri.encodeComponent(song.displayArtist);
                context.push('/artist/$artistKey');
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, WidgetRef ref) {
    final persistence = ref.read(persistenceServiceProvider);
    final playlists = persistence.getPlaylists();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: const Text('Add to playlist'),
          content: SizedBox(
            width: double.maxFinite,
            child: playlists.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No playlists yet. Create one below!'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    itemBuilder: (_, index) {
                      final pl = playlists[index];
                      return ListTile(
                        leading: const Icon(Icons.queue_music),
                        title: Text(pl.name),
                        subtitle: Text('${pl.songIds.length} tracks'),
                        onTap: () async {
                          await persistence.addSongToPlaylist(pl.id, song.id);
                          ref.read(libraryNotifierProvider.notifier).load();
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added to ${pl.name}')),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showCreatePlaylistDialog(context, ref);
              },
              child: const Text('New Playlist'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    void submit(BuildContext ctx) async {
      final name = controller.text.trim();
      final playlistName = name.isEmpty ? 'New Playlist' : name;
      final persistence = ref.read(persistenceServiceProvider);
      final newPl = await persistence.createPlaylist(playlistName);
      await persistence.addSongToPlaylist(newPl.id, song.id);
      ref.read(libraryNotifierProvider.notifier).load();
      if (ctx.mounted) {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Created playlist $playlistName')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: const Text('New playlist'),
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
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => submit(ctx),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
