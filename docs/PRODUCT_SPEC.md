# Product Specification: Local Music Player (YouTube Music Inspired)

## 1. Overview
A premium, offline-first local music player for Android and iOS, inspired by the visual language, navigation, and interaction patterns of YouTube Music. All music is sourced exclusively from files on the user's device. No accounts, no cloud, no streaming services, no YouTube integration.

## 2. Goals
- Recreate the familiar YouTube Music experience for local files.
- Deliver polished UI/UX with dark theme primary, smooth animations (especially mini-player ↔ full player), and responsive layouts.
- Provide reliable background playback with system media controls.
- Support large libraries with good performance.
- Be fully open-source ready with clear documentation and tests.

## 3. Non-Goals / Constraints
- No YouTube / Google services integration.
- No backend, accounts, or online catalogs.
- No uploading of user media or history.
- Core features must work fully offline.
- Do not copy proprietary logos, trademarks, or assets.

## 4. Target Platforms
- Android (API 26+ preferred; handle MediaStore permissions correctly across versions).
- iOS (user-initiated import via document picker / Files app; respect sandbox).

## 5. Core User Journeys
1. Grant media permission (or import files) → see Home with local content sections.
2. Browse Library (Songs / Albums / Artists / Playlists / Favorites).
3. Search local library with live results.
4. Play a track → mini-player appears; expand to full Now Playing.
5. Manage queue, shuffle, repeat, favorites, playlists.
6. Background playback + lock-screen / notification controls.
7. Settings for library refresh, preferences, privacy info.

## 6. Key Screens (must implement)
- Home (sections: Recently played, Recently added, Most played, Albums, Artists, Playlists)
- Library / Explore (tabs or sections for Songs, Albums, Artists, Playlists, Favorites)
- Search
- Now Playing (full)
- Persistent Mini-player
- Queue / Up Next
- Album detail
- Artist detail
- Playlist detail + create/edit
- Song contextual actions
- Settings

## 7. Acceptance Criteria Summary
See IMPLEMENTATION_PLAN.md and TEST_PLAN.md for detailed criteria. Visual fidelity to YTM reference is a primary requirement alongside functional correctness and reliability.

## 8. Branding
- App name: "Local Music" or "Pulse Local" / user-chosen neutral name (TBD in README).
- Original icons and generated sample artwork only.
- Clear privacy statement: everything stays on device.
