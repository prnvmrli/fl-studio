<p align="center">
  <img src="assets/logo.png" alt="FCleaner Logo" width="120" style="border-radius: 24px;" />
</p>

# FCleaner

<p align="center">
  <strong>Modern, blazing-fast Flutter desktop application for reclaiming disk space from Flutter build artifacts, SDK caches, and development clutter.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-00BFA5" alt="Platforms" />
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License" />
</p>

---

## Overview

Over months of mobile and web development, Flutter projects silently accumulate tens of gigabytes of ephemeral `build/` outputs, `.dart_tool/` caches, Gradle dependency stores, Xcode `DerivedData`, and CocoaPods caches. 

**FCleaner** gives developers a sleek, intuitive GUI to visualize where space is going, simulate cleanup runs safely with zero risk, and reclaim gigabytes with a single click.

---

## ✨ Features

### 1. ⚡ Dashboard
- **System Cache Overview**: Live status cards tracking Gradle cache, Xcode DerivedData, Android build cache, CocoaPods cache, and `pub-cache`.
- **Quick Actions**: One-click shortcuts to start scanning, jump to analytics, or check tooling health.
- **Cleanup History**: Persistent log of previous cleanups showing reclaimed gigabytes, timestamps, and target counts.

### 2. 🔍 Unified Scan & Clean
- **Flexible Scope Selection**:
  - **Current Workspace**: Scans your active project or monorepo.
  - **Choose Directory**: Native file picker to target any repository or folder.
  - **Home & Caches**: Scans global development caches (`~/.gradle`, `~/Library/Developer/Xcode/DerivedData`, CocoaPods, etc.).
- **Live Traversal Stream**: Real-time progress updates with current scanned path, item count, and running byte total.
- **Interactive Review & Filtering**:
  - Filter targets by category: `ALL`, `FLUTTER`, `ANDROID`, `APPLE`, `SYSTEM`, `PUBCACHE`.
  - Batch **Select All** / **Deselect All** with live recalculation of reclaimable space.
  - Granular target rows with size color-coding (>100 MB in red, >10 MB in orange) and safety badges.
- **Safety First**:
  - **Dry Run Mode**: Test-drive cleanup simulations without touching the disk.
  - **Confirmation Dialogs**: Safety warnings with item count and byte tally before permanent deletion.

### 3. 📊 Analytics
- **Category Donut Chart**: Visual distribution of space across Flutter projects, build folders, caches, and archives via `fl_chart`.
- **Top Space Consumers**: Ranked breakdown of the largest directories and artifacts found during the scan.

### 4. 🩺 System Doctor
- **Tooling Health Checklist**: Diagnostic verification for required developer CLI tools:
  - Flutter SDK & Dart SDK
  - Android SDK (`adb`)
  - CocoaPods (`pod`)
  - Homebrew (`brew`)
  - FVM (Flutter Version Management)
  - Xcode (`xcodebuild` on macOS)
- **Desktop Environment PATH Enrichment**: Enriches process execution to discover Homebrew (`/opt/homebrew`), FVM, and user-specific binary paths even within macOS desktop app sandbox boundaries.

### 5. ⚙️ Settings
- **Target Category Toggles**: Enable/disable automatic discovery for Gradle, Xcode, CocoaPods, or Trash.
- **Theme Preferences**: Sleek cyber-dark theme with custom glassmorphism.
- **History Management**: View and clear past cleanup run records.

### 6. 🎛️ Native macOS WidgetKit Support
- **Live Desktop & Notification Center Widgets**: Monitor developer cache buildup (Xcode DerivedData, Gradle, Pub Cache, CocoaPods) right on your macOS desktop without having to open the app.
- **Multiple Sizes**:
  - **Small (`systemSmall`)**: At-a-glance reclaimable space metric and cache health status.
  - **Medium (`systemMedium`)**: Total reclaimable metric paired with color-coded status badges for individual cache categories.
  - **Large (`systemLarge`)**: Itemized storage list showing exact cache footprints with quick deep-link buttons.
- **Interactive Deep Links**: Clicking any widget directly opens FCleaner to the corresponding view (`Scan & Clean`, `Analytics`, or `Dashboard`).
- **Reactive Background Sync**: Automatically updates timelines via `WidgetSyncService` whenever the desktop app performs a scan, cleans targets, or updates cache estimates.

---

## 🏗️ Architecture

FCleaner is architected with a decoupled, reactive Provider pattern and native Swift WidgetKit extensions:

```
apps/fcleaner/
├── lib/
│   ├── app.dart                   # Root shell with animated sidebar navigation
│   ├── main.dart                  # Provider wiring & Material root
│   ├── providers/                 # State management
│   │   ├── clean_provider.dart    # Target discovery, selection state, & deletion runner
│   │   ├── scan_provider.dart     # Directory stream scanner & Analytics feeder
│   │   ├── doctor_provider.dart   # CLI diagnostic runner
│   │   └── settings_provider.dart # User preferences & persistent history
│   ├── screens/                   # Core application views
│   │   ├── dashboard_screen.dart  # Caches overview & quick actions
│   │   ├── clean_screen.dart      # Unified Scan & Clean interactive view
│   │   ├── analytics_screen.dart  # Donut & bar chart visualizations
│   │   ├── doctor_screen.dart     # Environment diagnostic checklist
│   │   └── settings_screen.dart   # Configuration toggles & cleanup history
│   ├── services/                  # Native platform bridges
│   │   └── widget_sync_service.dart # Bi-directional bridge for macOS WidgetKit
│   ├── theme/                     # Glassmorphic cyber-dark theme & design tokens
│   └── widgets/                   # Reusable UI components (SidebarNav, CategoryChip, etc.)
├── macos/
│   ├── FCleanerWidget/            # Native SwiftUI WidgetKit extension target
│   │   ├── FCleanerWidget.swift   # Timeline provider & widget definition
│   │   ├── FCleanerWidgetViews.swift # Small, Medium, & Large SwiftUI widget designs
│   │   ├── WidgetDataProvider.swift  # Swift data loader & cache parser
│   │   └── Info.plist             # Widget extension bundle configuration
│   └── Runner/                    # Host macOS Flutter desktop runner & AppDelegate
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev) (v3.24+ recommended)
- macOS, Linux, or Windows desktop build tools enabled (`flutter config --enable-macos-desktop`)

### Running Locally

```bash
# From workspace root
cd apps/fcleaner

# Get dependencies
flutter pub get

# Run in debug mode (macOS desktop)
flutter run -d macos
```

### Building Release

```bash
# macOS application bundle
flutter build macos --release
```

### 🧩 Adding macOS Widgets

1. Build or run the macOS app so macOS registers the embedded widget extension:
   ```bash
   flutter build macos --debug
   ```
2. Open the **macOS Widget Gallery**:
   - Right-click an empty area on your **Desktop** and select **Edit Widgets...**, or
   - Click the date/time in the menu bar to open **Notification Center**, scroll down, and click **Edit Widgets**.
3. Locate **FCleaner** in the left sidebar list of widget providers.
4. Pick your desired widget size (**Small**, **Medium**, or **Large**) and drag it onto your Desktop or Notification Center.
5. Launching FCleaner or running scans will dynamically update your desktop widget in real time!

---

## 🛡️ Safety Guarantees

FCleaner adheres to strict safety guidelines to protect user data:

1. **Path Safety**: Protected system directories (e.g., root filesystem, user documents, system libraries) cannot be deleted.
2. **Contents-Only Protection**: For cache folders like `DerivedData` or `.gradle/caches`, only ephemeral contents are purged, leaving the directory structure intact.
3. **Dry-Run by Default**: Simulation mode allows verifying affected files and calculated space savings prior to execution.
4. **Destructive Tagging**: Any non-cache deletion (such as project `build/` directories) is explicitly labeled with visual warnings.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
