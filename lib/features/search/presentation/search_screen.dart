import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../../../shared/widgets/song_tile.dart';
import '../../library/presentation/library_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search songs, albums, artists...',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.textSecondary),
                          onPressed: () {
                            _controller.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) {
                  ref.read(searchQueryProvider.notifier).state = val;
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: query.trim().isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search,
                                size: 64, color: AppColors.textTertiary),
                            const SizedBox(height: 16),
                            Text(
                              'Search your local library',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Find your favorite music by song title, artist, album, or genre.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  : searchResults.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.music_off,
                                    size: 56, color: AppColors.textTertiary),
                                const SizedBox(height: 16),
                                Text(
                                  'No results for "$query"',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Check the spelling or try searching for another artist or album.',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        )
                      : CustomScrollView(
                          slivers: [
                            // Artists Section
                            if (searchResults.artists.isNotEmpty) ...[
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 12, 16, 8),
                                  child: Text('Artists',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: SizedBox(
                                  height: 130,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: searchResults.artists.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 14),
                                    itemBuilder: (context, i) {
                                      final art = searchResults.artists[i];
                                      return GestureDetector(
                                        onTap: () {
                                          final artistKey = Uri.encodeComponent(
                                              art.displayName);
                                          context.push('/artist/$artistKey');
                                        },
                                        child: Column(
                                          children: [
                                            ClipOval(
                                              child: ArtworkImage(
                                                artworkUri: art.artworkUri,
                                                size: 80,
                                                borderRadius: 40,
                                                iconSize: 32,
                                                fallbackIcon: Icons.person,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            SizedBox(
                                              width: 90,
                                              child: Text(
                                                art.displayName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],

                            // Albums Section
                            if (searchResults.albums.isNotEmpty) ...[
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: Text('Albums',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: SizedBox(
                                  height: 160,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: searchResults.albums.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 14),
                                    itemBuilder: (context, i) {
                                      final alb = searchResults.albums[i];
                                      return GestureDetector(
                                        onTap: () {
                                          final albumKey = Uri.encodeComponent(
                                              alb.displayTitle);
                                          context.push('/album/$albumKey');
                                        },
                                        child: SizedBox(
                                          width: 110,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                alb.displayArtist,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],

                            // Songs Section
                            if (searchResults.songs.isNotEmpty) ...[
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: Text('Songs',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, i) {
                                    final song = searchResults.songs[i];
                                    return SongTile(
                                      song: song,
                                      playlist: searchResults.songs,
                                    );
                                  },
                                  childCount: searchResults.songs.length,
                                ),
                              ),
                            ],
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 90)),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
