# Local Music Player

A premium, **offline-first local music player** for Android, iOS, and Web, inspired by the visual language, navigation, and interaction patterns of YouTube Music.

**100% Local & Privacy-Preserving.** All music comes exclusively from files on your device. No accounts, no streaming APIs, no cloud backends, no telemetry, no tracking.

---

## Features

- **YouTube Music-Inspired UI/UX**:
  - Deep dark theme (`#030303` background, `#121212` elevated surfaces, accent red `#FF0000`).
  - Persistent Mini-player with real-time progress indicator, play/pause, and skip controls.
  - Immersive Now Playing screen with large artwork shadow glow, interactive scrubber, repeat (off / all / one), and shuffle.
  - Up Next / Queue modal bottom sheet with reordering, swipe-to-remove, and clear queue actions.
- **Local Media Discovery & Ingestion**:
  - **Android**: Automatic MediaStore scanning via `on_audio_query` with runtime permission handling (supports Android 13+ `READ_MEDIA_AUDIO` and legacy storage).
  - **iOS & Desktop & Web**: User-initiated document/file import via `file_picker` (supports `.mp3`, `.m4a`, `.wav`, `.flac`, `.aac`, `.ogg`, `.opus`).
  - Graceful fallbacks for missing ID3 tags and album artwork.
  - Missing-file reconciliation on startup and refresh.
- **Library Organization**:
  - Browse by **Songs**, **Albums**, **Artists**, **Playlists**, and **Favorites**.
  - Album Detail screen with tracklist, total duration, and play/shuffle actions.
  - Artist Detail screen with artist discography, albums carousel, and songs list.
- **Playlists & Listening History**:
  - Create, rename, delete custom playlists and reorder tracks.
  - One-tap favorites toggle with instant persistence.
  - Listening history tracking ("Listen again" and "Quick picks / Most played").
  - Clear listening history from Settings.
- **Search**:
  - Multi-field search across song titles, artists, albums, and genres.
- **Background Playback & System Integration**:
  - Powered by `just_audio` + `audio_service` + `audio_session`.
  - Android Media notification with lock-screen playback controls and ongoing foreground service.
  - iOS background audio capability (`UIBackgroundModes: audio`).
  - Audio focus management (ducks on notifications, pauses on incoming calls / headphone disconnect).

---

## Architecture

The project follows a **feature-first, layered architecture**:

```
lib/
├── app/                  # Application root, routing (go_router)
├── core/                 # Theme, colors, permissions, design tokens
├── features/
│   ├── home/             # Home screen, carousels, quick picks
│   ├── library/          # Songs, Albums, Artists tabs & detail screens
│   ├── player/           # Mini-player & Now Playing screens, providers
│   ├── playlists/        # Playlist detail & management
│   ├── queue/            # Up Next / Queue modal sheet
│   ├── search/           # Multi-category search
│   └── settings/         # Library refresh, import, privacy, history
├── services/
│   ├── audio_handler.dart       # Authoritative BaseAudioHandler
│   ├── media_library_service.dart# MediaStore & document import service
│   └── persistence_service.dart # SharedPreferences local storage
└── shared/
    ├── models/           # Song, Album, Artist, Playlist models
    └── widgets/          # SongTile, ArtworkImage, SongActionsSheet, Scaffold
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.24.5` / Dart `^3.5.4`
- Android SDK (API 26+) / Xcode (iOS 12+) / Google Chrome

### Installation & Run

1. Clone or navigate to the repository directory:
   ```bash
   cd local_music_player
   ```

2. Fetch dependencies:
   ```bash
   flutter pub get
   ```

3. Run static analysis:
   ```bash
   flutter analyze
   ```

4. Run all unit and widget tests:
   ```bash
   flutter test
   ```

5. Launch application on a device:
   ```bash
   # Android
   flutter run -d android

   # iOS
   flutter run -d ios

   # Chrome (Web)
   flutter run -d chrome
   ```

---

## Testing

The project has comprehensive unit and widget tests covering domain logic, persistence, and UI rendering:

```bash
flutter test
```

### Test Suites Included:
- `test/unit/song_model_test.dart`: Serialization, `toMediaItem()`, `fromMediaItem()`, fallback tags, copyWith.
- `test/unit/album_and_artist_test.dart`: Album, Artist, Playlist domain models.
- `test/unit/persistence_service_test.dart`: Favorites toggle, Playlists CRUD & reordering, History & Play counts, Imported songs.
- `test/unit/media_library_service_test.dart`: Library grouping, search algorithms, multi-field matching.
- `test/widget/mini_player_test.dart`: MiniPlayer visibility, playback states, progress line.
- `test/widget/home_screen_test.dart`: Empty library states, populated carousels, action triggers.
- `test/widget/library_screen_test.dart`: TabBar navigation across Songs, Albums, Artists, Playlists, Favorites.
- `test/widget_test.dart`: Root smoke test.

---

## Platform Limitations & Notes

- **Android**: Full access to device music library requires granting storage / audio permissions. Android 13+ automatically prompts for `READ_MEDIA_AUDIO` and `POST_NOTIFICATIONS`.
- **iOS**: Apple sandboxing restricts third-party apps from scanning the general filesystem. Users import audio files or directories through the document picker via the "Import files" button.
- **Web**: MediaStore scanning and local filesystem paths are not available in browser sandboxes. Use the "Import audio files" button to load audio files directly into memory for playback.

---

## Documentation

Full specification and architecture design documents are available in `docs/`:
- [PRODUCT_SPEC.md](docs/PRODUCT_SPEC.md)
- [REFERENCE_ANALYSIS.md](docs/REFERENCE_ANALYSIS.md)
- [ARCHITECTURE.md](docs/ARCHITECTURE.md)
- [DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md)
- [IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md)
- [TEST_PLAN.md](docs/TEST_PLAN.md)
- [VALIDATION_REPORT.md](docs/VALIDATION_REPORT.md)

---

## License

MIT License. See [LICENSE](LICENSE) for details.
