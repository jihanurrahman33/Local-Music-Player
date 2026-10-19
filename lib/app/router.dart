import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/library/presentation/album_detail_screen.dart';
import '../features/library/presentation/artist_detail_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/player/presentation/now_playing_screen.dart';
import '../features/playlists/presentation/playlist_detail_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../shared/widgets/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/library',
            name: 'library',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LibraryScreen()),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SearchScreen()),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
          GoRoute(
            path: '/album/:title',
            name: 'album-detail',
            pageBuilder: (context, state) {
              final title = state.pathParameters['title'] ?? '';
              return MaterialPage(child: AlbumDetailScreen(albumTitle: title));
            },
          ),
          GoRoute(
            path: '/artist/:name',
            name: 'artist-detail',
            pageBuilder: (context, state) {
              final name = state.pathParameters['name'] ?? '';
              return MaterialPage(child: ArtistDetailScreen(artistName: name));
            },
          ),
          GoRoute(
            path: '/playlist/:id',
            name: 'playlist-detail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return MaterialPage(child: PlaylistDetailScreen(playlistId: id));
            },
          ),
        ],
      ),
      GoRoute(
        path: '/now-playing',
        name: 'now-playing',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NowPlayingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
    ],
  );
});
