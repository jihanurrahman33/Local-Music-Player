# Architecture

## High-level
Feature-first + clean-ish layers inside each feature.

```
lib/
├── app/                  # bootstrap, router, root widget
├── core/                 # theme, design_system, errors, logging, utils, platform
├── features/
│   ├── home/
│   ├── library/
│   ├── search/
│   ├── player/           # full + mini player UI + domain state
│   ├── queue/
│   ├── playlists/
│   └── settings/
├── shared/
│   ├── models/           # Song, Album, Artist, Playlist, etc.
│   └── widgets/          # reusable song rows, artwork, empty states...
└── services/             # audio_handler, media_library, persistence, etc.
```

## Key Abstractions
- **AudioHandler** (audio_service + just_audio): single source of truth for playback state, queue, position, shuffle/repeat.
- **MediaLibraryRepository**: abstracts Android MediaStore / iOS document picker + metadata extraction.
- **PlaylistRepository / Favorites / History**: local persistence (Drift preferred for relational + migrations).
- **Preferences**: simple key-value (shared_preferences or Drift).

## State Management
- Riverpod (recommended for testability and fine-grained rebuilds).
- Playback state exposed via streams / providers; UI selects only needed fields to avoid rebuild storms on position ticks.
- Separate providers for library, search results, playlists, player UI (expansion progress, etc.).

## Playback Independence
- Audio service lives outside widget tree lifecycle.
- Mini-player and full player both observe the same handler.
- Navigation does not dispose the player.

## Platform Differences
- Android: MediaStore query + READ_MEDIA_AUDIO / legacy storage permissions + foreground service for media.
- iOS: No free full-library scan; use file_picker / document picker for user-selected folders/files. Background audio capability required.

## Dependency Principles
- Prefer packages with active maintenance and clear licenses (MIT/BSD/Apache).
- just_audio + audio_service + audio_session for playback.
- on_audio_query (or equivalent MediaStore wrapper) for Android library; file_picker + metadata extractor for iOS/fallback.
- Drift for structured local data.
- cached_network_image not needed (local art only); use memory + disk cache for extracted artwork.
- No analytics, no crash-reporting SDKs that phone home by default.

## Testing Layers
- Unit: queue logic, shuffle, metadata fallbacks, repository contracts.
- Widget: screens, mini-player states, navigation.
- Integration: real file playback, permission flows (where emulator supports).
