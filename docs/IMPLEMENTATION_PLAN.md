# Implementation Plan

## Phase 0 – Project Foundation (current)
- [x] Flutter project created (3.24.5 / Dart 3.5.4)
- [x] Docs skeleton (PRODUCT_SPEC, REFERENCE_ANALYSIS, ARCHITECTURE, DESIGN_SYSTEM)
- [ ] pubspec dependencies (just_audio, audio_service, riverpod, drift, on_audio_query / file_picker, permission_handler, etc.)
- [ ] Core theme + design tokens
- [ ] Basic router (go_router or Navigator 2)
- [ ] Android / iOS permission & background audio scaffolding

## Phase 1 – Vertical Slice (highest value)
1. Domain models (Song, Album, Artist, Playlist, PlaybackState)
2. Media library service (Android MediaStore path first; iOS import stub)
3. AudioHandler with just_audio + audio_service (play/pause/seek/next/prev/queue/shuffle/repeat)
4. Home screen (placeholder sections + real data when library available)
5. Persistent mini-player (observes handler)
6. Full Now Playing screen + basic expansion transition
7. Queue sheet
8. Basic song row + artwork widgets

## Phase 2 – Library & Search
- Full Library tabs (Songs/Albums/Artists/Playlists/Favorites)
- Search with debounce
- Album / Artist detail screens
- Sorting & filtering

## Phase 3 – Playlists & Persistence
- Drift schema + migrations
- Playlist CRUD, reorder, favorites, history
- Missing-file reconciliation

## Phase 4 – Polish & Platform
- Advanced mini-player gesture + Hero/shared-element transition
- Background playback verification & notification config
- Empty / permission / error states
- Settings screen
- Performance (lazy lists, artwork cache, isolate scanning)
- Accessibility & safe areas

## Phase 5 – Tests & Release Prep
- Unit + widget tests for core logic
- Integration tests with fixture audio
- README, license review, final validation report

## Priority Order for Coding
1. Dependencies + theme
2. Models + AudioHandler skeleton
3. Mini-player + Now Playing UI
4. Library discovery
5. Home + Library screens
6. Queue + playlists
7. Animations & polish
8. Tests

Each increment must be analyzable (`flutter analyze`) and have at least smoke tests where feasible.
