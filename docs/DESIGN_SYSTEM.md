# Design System

## Colors (Dark primary)
```dart
// Approximate YTM-inspired tokens
static const Color background = Color(0xFF030303);
static const Color surface = Color(0xFF121212);
static const Color surfaceElevated = Color(0xFF1A1A1A);
static const Color surfaceCard = Color(0xFF181818);
static const Color primary = Color(0xFFFF0000);       // accent / play
static const Color onPrimary = Colors.white;
static const Color textPrimary = Color(0xFFFFFFFF);
static const Color textSecondary = Color(0xFFB3B3B3);
static const Color textTertiary = Color(0xFF808080);
static const Color divider = Color(0xFF2A2A2A);
static const Color error = Color(0xFFCF6679);
```

Light theme (optional secondary): inverted surfaces with careful contrast.

## Typography
- Display / large titles: 22–28, w600–w700
- Title: 16–18, w600
- Body: 14–15, w400–w500
- Caption / secondary: 12–13, w400
- Prefer system font (Roboto on Android, SF on iOS) or Google Fonts Roboto if bundled.

## Spacing Scale
4, 8, 12, 16, 20, 24, 32, 40, 48

## Radii
- Small (chips, buttons): 8
- Medium (cards, rows): 12
- Large (sheets, art): 16–20
- Full / pill: 999

## Artwork
- Thumbnail (list): 48–56 dp square, radius 4–8
- Card (carousel): 140–180 dp, radius 8–12
- Now Playing large: ~ min(screenWidth – 48, 360), radius 12–16
- Fallback: generated monogram or neutral icon on surface color.

## Icons
- 24 dp standard, 28–32 for primary player controls.
- Stroke weight consistent with Material Icons or custom outlined set.

## Animation
- Mini ↔ Full expansion: 320–400 ms, Curves.easeOutCubic or custom spring.
- Page transitions: 250–300 ms.
- Button feedback: 100–150 ms.
- Respect MediaQuery.disableAnimations / reduce motion.

## Breakpoints
- Compact: < 600
- Medium: 600–840
- Expanded: > 840 (tablet adjustments for grids).

## Component States
Every interactive component must define: enabled, pressed, focused, disabled, loading, error, empty.
