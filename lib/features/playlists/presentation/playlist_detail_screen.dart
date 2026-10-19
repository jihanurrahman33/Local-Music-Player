import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../../../shared/widgets/song_tile.dart';
import '../../library/presentation/library_providers.dart';
import '../../player/presentation/player_providers.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    final playlist = playlists.where((p) => p.id == playlistId).firstOrNull;

    if (playlist == null) {
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
            'Playlist not found',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final audioHandler = ref.watch(audioHandlerProvider);
    final persistence = ref.watch(persistenceServiceProvider);
    final songs = playlist.songs;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Rename playlist',
            onPressed: () =>
                _renameDialog(context, ref, playlist.id, playlist.name),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete playlist',
            onPressed: () =>
                _deleteDialog(context, ref, playlist.id, playlist.name),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  ArtworkImage(
                    artworkUri: playlist.artworkUri,
                    size: 180,
                    borderRadius: 12,
                    iconSize: 64,
                    fallbackIcon: Icons.queue_music,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    playlist.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${songs.length} tracks',
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (songs.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No songs in this playlist yet.\nAdd songs from the library or player options menu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = songs[index];
                  return Dismissible(
                    key: ValueKey('pl_song_${song.id}_$index'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: AppColors.error,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) async {
                      await persistence.removeSongFromPlaylist(
                          playlist.id, song.id);
                      ref.read(libraryNotifierProvider.notifier).load();
                    },
                    child: SongTile(
                      song: song,
                      playlist: songs,
                      showArtwork: true,
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

  void _renameDialog(
      BuildContext context, WidgetRef ref, String id, String currentName) {
    final controller = TextEditingController(text: currentName);
    void submit(BuildContext ctx) async {
      final newName = controller.text.trim();
      if (newName.isNotEmpty) {
        await ref.read(persistenceServiceProvider).renamePlaylist(id, newName);
        ref.read(libraryNotifierProvider.notifier).load();
        if (ctx.mounted) Navigator.pop(ctx);
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Rename playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => submit(ctx),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => submit(ctx),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteDialog(
      BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text('Delete "$name"?'),
        content: const Text(
            'This will delete the playlist. The audio files will remain on your device.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await ref.read(persistenceServiceProvider).deletePlaylist(id);
              ref.read(libraryNotifierProvider.notifier).load();
              if (ctx.mounted) {
                Navigator.pop(ctx); // Dialog
                Navigator.of(context).pop(); // Screen
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
