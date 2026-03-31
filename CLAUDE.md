# Gamma — Bike Tracker

Android cycling tracker app built with Flutter. Local-only, no backend, no accounts.

## Stack

- **Framework:** Flutter (Android target only)
- **Storage:** SQLite via `sqflite`
- **Maps:** OpenStreetMap via `flutter_map` (no API key)
- **BLE:** optional cadence sensor support

## Project Structure (target)

```
lib/
  main.dart
  app.dart                  # MaterialApp, theme, bottom nav
  screens/
    activity/               # Screen 1 — live ride tracking
    history/                # Screen 2.1 — ride list
    history_detail/         # Screen 2.2 — ride detail
    statistics/             # Screen 3 — aggregated stats
  models/                   # Ride, TrackPoint, etc.
  services/
    gps_service.dart
    ble_service.dart
    database_service.dart
  widgets/                  # shared UI components
```

## Design System

- **Theme:** Dark only. Background `#0f0f0f`, surface cards slightly lighter.
- **Accent:** Green `#34d367` (active states, CTAs, live indicators). Also seen as `#1AFF8C` in History screen borders/text.
- **Typography:** default Flutter/Material sizes; key sizes from spec: 10 dp labels, 11 dp units, 12 dp values (weight 500), 14 dp headers, 18 dp metric values.
- **No light theme.** Do not add `ThemeMode` switching.

## Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Activity | `/activity` | Live GPS tracking, 2×2 metric cards, pause/stop controls |
| History | `/history` | Monthly-grouped ride list, collapsible sections, pinned total bar |
| History Detail | `/history/:id` | Map panel, 2×3 metric grid, elevation chart, splits table |
| Statistics | `/statistics` | Period selector (week/month/year), hero distance card, 4 metric cards, personal records |

## Data Model

```dart
Ride {
  id, name, startTime,
  totalDistance (km), avgSpeed (km/h), maxSpeed (km/h),
  duration, movingTime, elevationGain (m),
  cadence (rpm, nullable),
  trackPoints: List<TrackPoint>
}

TrackPoint { lat, lng, speed, timestamp, altitude }
```

## Key Constraints

- **Local only.** No network calls except OSM tile fetches. No analytics, no crash reporting.
- **APK size target:** under 20 MB. OSM tiles cached on demand, not bundled.
- **Android only.** No iOS code, no platform conditionals for iOS.
- **Cadence is optional.** Hide cadence metric cards when no BLE sensor was connected during the ride.
- Stop ride requires confirmation dialog before saving.

## Navigation

Persistent `BottomNavigationBar` with three tabs: Activity, History, Statistics. Active tab highlighted in green with a small green dot indicator.
