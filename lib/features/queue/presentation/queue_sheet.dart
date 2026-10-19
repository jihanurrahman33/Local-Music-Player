import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../../player/presentation/player_providers.dart';

class QueueSheet extends ConsumerWidget {
  const QueueSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.85,
        child: QueueSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(queueSongsProvider);
    final currentSong = ref.watch(currentSongProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final audioHandler = ref.watch(audioHandlerProvider);
    final shuffleMode = ref.watch(shuffleModeProvider);

    final isShuffle = shuffleMode == AudioServiceShuffleMode.all;

    return Column(
      children: [
        // Top handle
        Container(
          width: 36,
          height: 4,
          margin: const EdgeInsets.only(top: 8, bottom: 4),
          decoration: BoxDecoration(
            color: AppColors.textTertiary.withAlpha(100),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
          child: Row(
            children: [
              Text(
                'Up Next',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${queue.length}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color:
                      isShuffle ? AppColors.primary : AppColors.textSecondary,
                ),
                tooltip: isShuffle ? 'Shuffle enabled' : 'Shuffle queue',
                onPressed: () {
                  audioHandler.setShuffleMode(
                    isShuffle
                        ? AudioServiceShuffleMode.none
                        : AudioServiceShuffleMode.all,
                  );
                },
              ),
              if (queue.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_all,
                      color: AppColors.textSecondary),
                  tooltip: 'Clear queue',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surfaceElevated,
                        title: const Text('Clear queue?'),
                        content: const Text(
                            'All upcoming tracks will be removed from playback.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await audioHandler.clearQueue();
                    }
                  },
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Queue List
        Expanded(
          child: queue.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.queue_music,
                          size: 56, color: AppColors.textTertiary),
                      SizedBox(height: 12),
                      Text(
                        'Queue is empty',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Play a song or add tracks to get started',
                        style: TextStyle(
                            color: AppColors.textTertiary, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: queue.length,
                  onReorderItem: (oldIndex, newIndex) {
                    audioHandler.moveQueueItem(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final song = queue[index];
                    final isCurrent = currentSong?.id == song.id;

                    return Dismissible(
                      key: ValueKey('queue_${song.id}_$index'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: AppColors.error,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        audioHandler.removeQueueItemAt(index);
                      },
                      child: ListTile(
                        key: ValueKey('item_${song.id}_$index'),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 2),
                        leading: Stack(
                          alignment: Alignment.center,
                          children: [
                            ArtworkImage(
                              artworkUri: song.artworkUri,
                              size: 44,
                              borderRadius: 4,
                            ),
                            if (isCurrent)
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(120),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  isPlaying ? Icons.equalizer : Icons.pause,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          song.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isCurrent
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          song.displayArtist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 20),
                              color: AppColors.textTertiary,
                              onPressed: () {
                                audioHandler.removeQueueItemAt(index);
                              },
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle,
                                  color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                        onTap: () {
                          audioHandler.skipToQueueItem(index);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
