# Reference Analysis: YouTube Music UI/UX (v9.x era, 2025–2026)

**Source of observations**: Public knowledge of YouTube Music Android/iOS UI, aapt-derived package metadata from provided APK (com.google.android.apps.youtube.music 9.41.52), and publicly documented design references.  
**Note**: Full visual pixel measurements from the APK were limited by sandbox memory constraints on JADX. Observations below distinguish **verified** (from public screenshots / known design language) vs **approximated**.

## Overall Visual Language
- **Primary background**: Near-black (`#030303` / `#0F0F0F`). Cards slightly elevated (`#121212`–`#1A1A1A`).
- **Accent**: Strong red (`#FF0000` / YouTube red family) used sparingly for primary CTAs and play indicators.
- **Text**: White primary, medium grey secondary (`#AAAAAA`–`#B3B3B3`), muted tertiary.
- **Typography**: Roboto / system sans, clear hierarchy (title 16–20sp medium/bold, body 14sp, caption 12sp).
- **Artwork**: Square album art with modest corner radius (8–12 dp). Large art in Now Playing with soft radial glow / blurred backdrop derived from dominant colors of the artwork.
- **Elevation**: Subtle; preference for flat dark surfaces + soft shadows on floating elements (mini-player, sheets).

## Navigation
- Bottom navigation bar (Home, Explore/Library, Library or Search depending on version).
- Search often accessible from top app bar or dedicated tab.
- Mini-player sits **above** the bottom navigation when content is playing.
- System status bar and navigation bar typically dark / transparent with light icons.

## Home
- Vertical scroll of horizontal carousels (“Quick picks”, “Recently played”, “Albums for you”, etc.).
- Section headers with optional “See all”.
- Cards are artwork-dominant; title + subtitle below or overlaid lightly.
- Empty state encourages library scan / permission.

## Library
- Tabbed or segmented: Songs | Albums | Artists | Playlists.
- List rows for songs (art thumbnail left, title, artist, duration or overflow menu).
- Grid for albums/artists (2–3 columns depending on width).
- Sorting controls and search within library.

## Now Playing (Full)
- Dominant large centered/nearly-full-width artwork.
- Title + artist below art (or overlaid on lower art region).
- Progress bar with current / remaining time.
- Primary controls: previous | play/pause (large circular or filled) | next.
- Secondary: shuffle, repeat, queue, favorite, more actions.
- Optional lyrics / related content shelf below.
- Background often a darkened, blurred, color-extracted version of the current artwork.

## Mini-player
- Compact bar: small square art (left) | title + artist (center, ellipsis) | play/pause (+ optional next).
- Tap expands to full player with shared-element / Hero-style artwork transition and surface expansion.
- Drag up to expand; drag down or swipe to dismiss (with velocity thresholds).
- Remains synchronized across all tabs; does not recreate on tab change.

## Queue / Up Next
- Bottom sheet or full-screen list.
- Current track highlighted.
- Reorderable (drag handles).
- Actions: play now, remove, clear, shuffle.

## Interactions & Animation (high priority)
- Mini ↔ Full player: coordinated artwork scale/position + surface height + opacity of secondary controls. Duration ~300–450 ms, ease-out or custom curves. Gesture-driven with spring/physics.
- Horizontal carousels with snap / momentum.
- Subtle pressed states and ripple (Material 3 style but dark-themed).
- Seek bar interactive with live preview.
- Haptic feedback on key actions (optional, respect system settings).

## Platform Notes from APK
- Package: `com.google.android.apps.youtube.music`
- Version observed: 9.41.52 (versionCode 94152230)
- minSdk 26, target/compile around 36–37
- Permissions include media, foreground service (media playback), Bluetooth, notifications, etc.
- Heavy use of split APKs / language packs (not relevant for our pure-Flutter app).

## Design Tokens to Capture (see DESIGN_SYSTEM.md)
- Colors, typography scale, spacing (4/8/12/16/24/32), radii (4/8/12/16/24/full), icon sizes, animation durations/curves, breakpoints.

**Assumptions vs Observed**: Exact pixel values for margins, exact red hex, and precise spring parameters are approximated from public references and common Material 3 + YTM patterns. Runtime comparison against a real device screenshot is recommended for final polish.
