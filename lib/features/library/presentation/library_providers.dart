import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/media_library_service.dart';
import '../../../services/persistence_service.dart';
import '../../../shared/models/album.dart';
import '../../../shared/models/artist.dart';
import '../../../shared/models/playlist.dart';
import '../../../shared/models/song.dart';

final persistenceServiceProvider = Provider<PersistenceService>((ref) {
  throw UnimplementedError('persistenceServiceProvider must be overridden');
});

final mediaLibraryServiceProvider = Provider<MediaLibraryService>((ref) {
  final persistence = ref.watch(persistenceServiceProvider);
  return MediaLibraryService(persistence);
});

/// Notifier to manage library loading and updates
class LibraryStateNotifier extends StateNotifier<AsyncValue<List<Song>>> {
  LibraryStateNotifier(this._mediaService) : super(const AsyncValue.loading()) {
    load();
  }

  final MediaLibraryService _mediaService;

  Future<void> load({bool refresh = false}) async {
    state = const AsyncValue.loading();
    try {
      final songs = await _mediaService.loadLibrary(refresh: refresh);
      state = AsyncValue.data(songs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> importFiles() async {
    try {
      await _mediaService.importFiles();
      state = AsyncValue.data(_mediaService.cachedSongs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite(String songId) async {
    await _mediaService.toggleFavorite(songId);
    state = AsyncValue.data(_mediaService.cachedSongs);
  }

  Future<void> clearHistory() async {
    await _mediaService.clearHistory();
    state = AsyncValue.data(_mediaService.cachedSongs);
  }
}

final libraryNotifierProvider =
    StateNotifierProvider<LibraryStateNotifier, AsyncValue<List<Song>>>((ref) {
  final service = ref.watch(mediaLibraryServiceProvider);
  return LibraryStateNotifier(service);
});

final songsProvider = Provider<List<Song>>((ref) {
  final asyncSongs = ref.watch(libraryNotifierProvider);
  return asyncSongs.value ?? [];
});

final albumsProvider = Provider<List<Album>>((ref) {
  ref.watch(libraryNotifierProvider);
  final service = ref.watch(mediaLibraryServiceProvider);
  return service.getAlbums();
});

final artistsProvider = Provider<List<Artist>>((ref) {
  ref.watch(libraryNotifierProvider);
  final service = ref.watch(mediaLibraryServiceProvider);
  return service.getArtists();
});

final playlistsProvider = Provider<List<Playlist>>((ref) {
  ref.watch(libraryNotifierProvider);
  final service = ref.watch(mediaLibraryServiceProvider);
  return service.getPlaylists();
});

final favoritesProvider = Provider<List<Song>>((ref) {
  ref.watch(libraryNotifierProvider);
  final service = ref.watch(mediaLibraryServiceProvider);
  return service.getFavorites();
});

final recentlyPlayedProvider = Provider<List<Song>>((ref) {
  ref.watch(libraryNotifierProvider);
  final service = ref.watch(mediaLibraryServiceProvider);
  return service.getRecentlyPlayed();
});

final mostPlayedProvider = Provider<List<Song>>((ref) {
  ref.watch(libraryNotifierProvider);
  final service = ref.watch(mediaLibraryServiceProvider);
  return service.getMostPlayed();
});

final recentlyAddedProvider = Provider<List<Song>>((ref) {
  ref.watch(libraryNotifierProvider);
  final service = ref.watch(mediaLibraryServiceProvider);
  return service.getRecentlyAdded();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<SearchResults>((ref) {
  final query = ref.watch(searchQueryProvider);
  ref.watch(libraryNotifierProvider);
  final service = ref.watch(mediaLibraryServiceProvider);
  return service.search(query);
});
