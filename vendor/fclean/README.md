# fclean

`fclean` is a cross-platform Dart CLI for safely finding and removing Flutter build artifacts, development caches, and local system clutter.

## Commands

```sh
fclean scan
fclean analyze --top 15
fclean clean --interactive
fclean clean --dry-run
fclean clean --include flutter --yes
fclean cache gc
fclean doctor
fclean init
```

## Architecture

The package is split into thin command classes and reusable services:

- `lib/commands`: CLI argument parsing and orchestration.
- `lib/cleaners`: cleanup target discovery for Flutter, Android, Apple, and system files.
- `lib/services`: platform, filesystem, scanning, process, config, and terminal abstractions.
- `lib/models`: strongly typed result and config objects.
- `lib/utils`: byte formatting, path safety, and shared exceptions.

Destructive operations go through path validation, support `--dry-run`, and require confirmation unless `--yes` is provided.

## Interactive Cleaner

Use `fclean clean --interactive` for a guided menu:

1. Clean Flutter build folders
2. Run `flutter clean` on projects
3. Clean Gradle cache
4. Clean CocoaPods
5. Clean Xcode DerivedData
6. Clean Android build cache
7. Clean iOS simulators
8. Clean Homebrew cache
9. Empty Trash
10. Clean temporary files
11. Run `flutter pub cache gc`
12. Full cleanup
13. Show largest folders
14. Toggle dry run mode

The menu first asks whether to scan the current directory, a custom directory, or the whole system. Whole-system scans prune protected macOS/system folders automatically.

## Config

Run `fclean init` to create:

```yaml
clean:
  gradle: true
  xcode: true
  cocoapods: true
  trash: false
```

## Roadmap

TODO: JSON reports, CI mode, scheduled cleanups, telemetry hooks, plugin cleaners, GUI wrapper, and named config profiles.
