# Nursing Pulse

A Flutter app for tracking breastfeeding sessions and baby health data. Designed for new parents who want a simple, calm interface to log feeds, monitor diaper changes, and track baby weight over time.

## Features

### Home
- **Session timer** — tap the large circular button to start a nursing session; a live MM:SS counter and an animated progress ring update every second
- **Side selection** — choose Left or Right before starting; switching sides mid-session automatically closes the current segment and opens a new one
- **Daily stats** — total nursing minutes for the day and today's diaper count shown at a glance
- **Next feed suggestion** — calculates the recommended next feed time based on the last session end time and the configured feed interval

### Stats
- **Today's summary** — total nursing time formatted as hours and minutes
- **Lateral balance card** — visual bar showing the left/right time split with percentages and durations
- **Session history** — list of today's sessions; long-press any entry to edit its end time via a bottom sheet
- **Insights** — average session duration and night feed count (midnight–6 AM)
- **Nursing history chart** — 7-day bar chart of daily nursing minutes overlaid with diaper counts
- **Weight chart** — line chart of all recorded weight entries

### Baby
- **Diaper logging** — three quick-tap buttons (Wet / Dirty / Both) open a sheet with type selection and time picker; entries can be deleted
- **Weight tracking** — log weight in kg or grams; the latest entry card shows the trend (gain/loss) compared to the previous entry with a color indicator

### Settings
- **Baby profile** — name, birth date, and a customizable feed interval slider (1–6 h in 30-minute steps); the recommended range is derived automatically from the baby's age
- **Notifications** — toggle the persistent foreground notification timer and the floating overlay badge independently
- **Language** — switch between English, Turkish, and Dutch; or follow the system locale
- **Clear stats** — wipe all session, diaper, and weight data after a confirmation dialog

### Foreground service & overlay (Android)
When a nursing session is active, the app runs a foreground service that ticks every second and keeps the notification timer updated. A floating overlay badge appears over other apps showing the elapsed time with Open and Finish buttons.

## Supported platforms

| Platform | Status |
|----------|--------|
| Android  | Primary target |
| Windows  | Supported (desktop window opens at 576×1024) |
| Web / iOS | Not tested |

## Tech stack

- Flutter 3.44 / Dart 3.11
- [`flutter_foreground_task`](https://pub.dev/packages/flutter_foreground_task) — background timer and notification
- [`flutter_overlay_window`](https://pub.dev/packages/flutter_overlay_window) — floating badge over other apps
- [`fl_chart`](https://pub.dev/packages/fl_chart) — nursing history and weight charts
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) — local persistence for all data
- [`screenshot`](https://pub.dev/packages/screenshot) — dev-only screen capture
- [`google_fonts`](https://pub.dev/packages/google_fonts) — Plus Jakarta Sans typeface

## Getting started

```bash
flutter pub get
flutter run
```

Android requires the foreground service and notification permissions granted at runtime. The overlay badge additionally requires the "Draw over other apps" permission.

## Dev tools

In debug builds only:

- **Screenshot** — tap the app icon in the header to capture the current screen and save it to `screenshots/` in the project root
- **Seed data** — Settings → [DEV] → "Seed 6 Months of Data" fills the database with realistic mock sessions, diapers, and weights
