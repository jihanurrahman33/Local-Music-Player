# Test Plan

## Unit Tests
- Queue operations (add, remove, reorder, play-next, clear)
- Shuffle / unshuffle (preserve current index correctly)
- Repeat modes (off / all / one)
- Playback state machine transitions
- Metadata fallbacks (missing title/artist/art)
- Playlist add/remove/reorder
- Search matching (case-insensitive, multi-field)
- Missing-file reconciliation logic
- Preference serialization

## Widget Tests
- Home renders sections / empty state
- SongRow displays correctly + overflow menu
- MiniPlayer shows art/title/play state; tap expands
- Full player controls call handler methods
- Queue list reorderable + remove
- Permission denied / empty library screens
- Theme / text scale basic checks

## Integration / Device Tests (when emulator/device available)
- Request media permission → library populates
- Play real fixture MP3/FLAC → position advances
- Background / lock-screen controls
- Seek, next, previous, shuffle, repeat
- App kill & restore (history, playlists)
- Corrupted / deleted file handling

## Fixtures
- Generate or include short royalty-free / CC0 audio files under `test/fixtures/`
- Mock MediaLibraryRepository for pure unit/widget tests

## CI Expectations
- `flutter analyze` clean
- `flutter test` (unit + widget) green
- Format check
- Build APK / iOS (where runners support)

## Known Environment Limitations (this sandbox)
- No physical device or full Android emulator with media library.
- Limited RAM (~1.2 GB) may affect heavy JADX or large builds.
- Runtime verification of background audio and system UI will be documented as “pending device test”.
