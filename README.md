# ProxDeals — Track A: Mobile UI/UX Implementation & App Deployment


---

## Tech Stack

- **Language:** Swift 5
- **UI:** UIKit with a Storyboard (`Main.storyboard`), Auto Layout, tab-bar navigation
- **Min target:** iOS 26.4 (from the existing project settings)
- **Data:** Local mock JSON decoded with `Codable` through a small "mock API" layer
  (`DealsData`) that simulates async loading so real loading/empty/error states can be shown.
- **No third-party packages.** Everything uses the standard SDK (UIKit, MapKit, Foundation).

---

## Component structure

```
TabBarController
├── Deals (ViewController)
│     • Full-screen MapView (Locate button is a no-op for now, by design)
│     • Logo
│     • Sliding "deals panel" (dealsView) with a drag handle
│         - Search bar + Enter button
│         - Filter button  ──► FilterViewController (modal)
│         - Deals table (DealCell rows)  ──► DetailViewController (modal) on tap
│     • Loading spinner + empty/error overlay (MessageView)
└── Cart (CartViewController)
      • Saved items table (CartCell rows)
      • Empty state (MessageView)
      • Totals (price / tax / savings)
      • Tab badge = number of saved items

Shared state: SaveStore (singleton + NotificationCenter)
Data: DealsData (mock JSON) → Deal models → FilterOptions filters them
```

---

## Features implemented

- **Mock data & mock API** — 12 grocery deals decoded from JSON via `Codable`, served through
  an async `fetchDeals` call with a short delay.
- **Loading / empty / error states** — a spinner while loading; a friendly empty state with a
  "Clear filters" action when nothing matches; an error state with a "Retry" button. (You can
  force empty/error for a demo by setting `DealsData.demoMode`.)
- **Expandable deals panel** — drag the handle up to expand the panel to just below the logo,
  drag down to collapse. Snaps to the nearest position with a spring animation; velocity-aware.
- **Save button (☆ / ★)** — defaults to ☆, toggles to ★, and back. Saving anywhere updates the
  same deal everywhere (list, detail, cart) instantly.
- **Detail screen** — tap a deal to see image, name, store, price (with struck-through original),
  size, savings %, description, and a save button that stays in sync.
- **Filter screen** — filter by store, deal type, category, max price, and max distance; Apply
  updates the list; Clear resets everything. The Filter button shows an active-filter count.
- **Cart tab badge** — shows the saved count, hides at zero, updates automatically.
- **Cart screen** — lists saved items with totals, or a clean empty state when nothing is saved.

---

## How to run

1. Open `ProxDeals.xcodeproj` in Xcode.
2. Select an iPhone simulator (e.g. iPhone 15 and iPhone SE to check both sizes).
3. Press **Run** (⌘R).

The project uses Xcode's synchronized folders, so the new `.swift` files are picked up
automatically — no manual "Add Files" step.

### One-time wiring check
Most connections are already in the storyboard XML. Because IB connections are easy to get
out of sync, open `Main.storyboard` once and confirm the items listed in
**`WIRING_CHECKLIST.md`** are connected (it's a quick visual check in the Connections Inspector).

---

## UX decisions

- **Panel handle + drag** rather than a button, because a grab handle is the familiar iOS
  pattern for a pull-up sheet and signals "draggable" without instructions.
- **Strike-through original price + green "Save X%"** makes the value obvious at a glance — the
  core reason a deals app exists.
- **Star save** is a single, universally understood control, and syncing it everywhere avoids
  the confusing state where an item looks saved on one screen but not another.
- **Empty state is actionable** — when filters hide everything, the empty view offers a one-tap
  "Clear filters" instead of leaving the user stuck.
- **Image fallback** — if a product image is missing, the layout falls back to the Prox logo so
  rows never look broken.

---

## How this fits the real Prox app

- `DealsData.fetchDeals` is deliberately shaped like a real data call, so swapping the mock for a
  real Prox deals API is a one-function change; the UI states already handle slow/failed loads.
- `SaveStore` is the single source of truth for saved items; in production it would persist to
  disk or sync to the user's account, but the rest of the app wouldn't change.
- `FilterOptions` mirrors the kinds of filters a real grocery-savings app needs (store, category,
  price, distance), so it maps directly onto real catalog data.

---

## Deployment Readiness

### How I would test before release
- Unit-test the pure logic: `Deal.savingsPercent`, `FilterOptions.apply`, and `SaveStore` toggling.
  (A starter set of these tests is already included in `ProxDealsTests/ProxDealsTests.swift` —
  run them with ⌘U in Xcode.)
- Manual pass on the full flow: search → filter → open detail → save → check cart + badge.
- Verify the three data states by toggling `DealsData.demoMode` (normal / empty / error).
- Accessibility: VoiceOver labels on the star button, Dynamic Type, and color contrast on the
  green savings text.

### Devices / screen sizes to test
- A small phone (iPhone SE) and a large one (iPhone 15 Pro Max) to confirm the panel's expanded
  stop and the table layout hold up.
- Light and dark mode (the UI uses system colors, so it should adapt).
- Landscape behavior, or lock to portrait if that's the intended experience.

### Bugs / UX issues to check before shipping
- Panel drag limits on the smallest screens (handle reachable, panel not covering the logo).
- Save sync under fast tapping (no double-count in the badge).
- Empty/error copy is friendly and the retry path actually re-fetches.
- The Locate button + map are intentionally inert right now and would need real location
  permission handling and store pins before release.

### Preparing for the App Store
- An Apple Developer account, a unique bundle ID, and an App ID + provisioning profile.
- App icons (all sizes) and a launch screen (a `LaunchScreen.storyboard` is already present).
- App Privacy details (especially since MapKit/location would be used), and a privacy policy.
- Archive in Xcode → upload to **App Store Connect** → distribute a build via **TestFlight**
  for beta testing → submit for review with screenshots and metadata.

### Preparing for Google Play
- This is a native iOS project, so an Android version would need a separate build — either a
  rewrite in Kotlin/Jetpack Compose, or rebuilding the app in a cross-platform stack
  (React Native / Flutter / Expo) to share one codebase.
- Then: a Google Play Developer account, a signed Android App Bundle (.aab), a Play Console
  listing, content rating, data-safety form, and a staged/internal-testing rollout.

### Tools I would use
Xcode, App Store Connect, TestFlight for iOS; Android Studio + Google Play Console for Android;
Firebase (or similar) for crash reporting and analytics; and a CI service (Xcode Cloud / Fastlane)
to automate builds and TestFlight uploads.

---

## What I would improve with more time
- Persist saved items (and filters) across launches.
- Replace the mock images with real product art and add image caching.
- Make the Locate button and map functional with store pins and distance from the user.
- Add unit + UI tests and wire them into CI.
- Add subtle haptics and a saved/unsaved animation on the star.
