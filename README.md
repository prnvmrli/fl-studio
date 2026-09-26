# FL Studio 🎛️

<p align="center">
  <strong>Monorepo for developer utilities, desktop applications, and publishable Flutter packages.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Workspace-Melos-FF6F00?logo=dart&logoColor=white" alt="Melos" />
  <img src="https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License" />
</p>

---

## 📂 Repository Structure

```
fl_studio/
├── apps/                          # End-user applications
│   └── fcleaner/                  # Modern Flutter desktop app for system & project cleanup
│
├── packages/                      # Publishable open-source Flutter packages
│   ├── android_system_chrome/     # Native Android system navigation & status bar customization
│   └── flutter_notification_icons/# Notification icon handling utilities
│
└── vendor/                        # Core tools & backend engine libraries
    └── fclean/                    # Cross-platform Dart CLI & cleanup service engine
```

---

## 📦 Projects Overview

### Applications (`apps/`)

| App | Description | Platforms |
|---|---|---|
| <img src="apps/fcleaner/assets/logo.png" width="28" height="28" style="vertical-align: middle; border-radius: 6px;" /> [**FCleaner**](apps/fcleaner/) | Desktop disk cleanup & cache visualizer for Flutter developers with native macOS WidgetKit extensions. Reclaim disk space from `build/` folders, `.dart_tool/`, Gradle caches, and Xcode DerivedData with safe simulation, live stream scanning, and space analytics. | macOS, Linux, Windows |

### Packages (`packages/`)

| Package | Description | Version |
|---|---|---|
| [**android_system_chrome**](packages/android_system_chrome/) | Flutter plugin for managing Android system bar styling, colors, and translucent edge-to-edge UI. | `0.0.1` |
| [**flutter_notification_icons**](packages/flutter_notification_icons/) | Utilities for handling and customizing Flutter Android notification icons. | `0.0.1` |

### Engine & Vendor (`vendor/`)

| Tool | Description | Type |
|---|---|---|
| [**fclean**](vendor/fclean/) | Standalone Dart CLI and library for project cleaning, stream-based disk scanning, target discovery, and developer SDK diagnostics. | Dart CLI / Library |

---

## 🛠️ Development & Monorepo Workflows

This workspace is managed using [Melos](https://melos.invertase.io/) and Flutter Workspaces.

### Bootstrap Workspace

Install dependencies across all workspace packages and link local dependencies:

```bash
dart run melos bootstrap
```

### Static Analysis

Run `dart analyze` across all packages in the workspace:

```bash
dart run melos run analyze
# or manually
dart analyze packages/ apps/ vendor/
```

### Running the Desktop App

```bash
cd apps/fcleaner
flutter run -d macos
```

### Running the CLI Tool

```bash
cd vendor/fclean
dart run bin/fclean.dart scan
```

---

## 📄 License

Individual packages and applications in this repository are licensed under the MIT License — see respective directories for licensing details.