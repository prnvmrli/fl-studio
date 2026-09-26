# fclean Usage

`fclean` is a Dart CLI for safely scanning, analyzing, and cleaning Flutter build artifacts, local caches, and development clutter.

## Install / Run Locally

From this package directory:

```sh
dart run bin/fclean.dart <command>
```

After activating globally from pub.dev or a local path:

```sh
fclean <command>
```

## Global Help

```sh
fclean --help
fclean help <command>
```

Examples:

```sh
fclean help clean
fclean help cache
fclean help cache gc
```

## `clean`

Cleans Flutter build folders and development caches.

```sh
fclean clean
```

Useful options:

```sh
fclean clean --dry-run
fclean clean --yes
fclean clean --path ~/Projects/my_app
fclean clean --include flutter
fclean clean --include flutter --include android
fclean clean --verbose
```

Flags:

- `--dry-run`: shows what would be cleaned without deleting anything.
- `--yes`, `-y`: skips confirmation prompts.
- `--path`, `-p`: chooses the Flutter project or workspace path to scan.
- `--include`: limits cleanup to categories: `flutter`, `android`, `apple`, `system`.
- `--interactive`, `-i`: opens the guided menu.
- `--verbose`, `-v`: shows debug-level logging.

By default, `clean` can discover:

- Flutter `build` folders
- `.dart_tool`
- `.symlinks`
- Gradle caches
- Android build caches
- Xcode DerivedData
- CocoaPods cache
- Temporary files
- Trash, only when enabled by config or selected interactively

## `clean --interactive`

Starts a guided menu similar to a shell-script cleaner.

```sh
fclean clean --interactive
```

The tool first asks which directory to scan:

- Current directory
- Custom directory
- Whole system

Then it shows these options:

```text
1. Clean Flutter build folders
2. Run flutter clean on projects
3. Clean Gradle cache
4. Clean CocoaPods
5. Clean Xcode DerivedData
6. Clean Android build cache
7. Clean iOS simulators
8. Clean Homebrew cache
9. Empty Trash
10. Clean temporary files
11. Run flutter pub cache gc
12. Full cleanup
13. Show largest folders
14. Toggle dry run mode
0. Exit
```

Recommended safe preview:

```sh
fclean clean --interactive --dry-run
```

Whole-system scans automatically skip protected folders such as system, application, volume, and private OS directories.

## `scan`

Scans a directory for cleanup candidates.

```sh
fclean scan
```

Examples:

```sh
fclean scan --path ~/Projects
fclean scan --path ~/Projects --depth 4
fclean scan --verbose
```

Flags:

- `--path`, `-p`: root directory to scan. Defaults to the current directory.
- `--depth`: maximum recursive scan depth. Defaults to `6`.
- `--verbose`, `-v`: shows detailed paths and debug output.

`scan` reports detected artifacts such as Flutter build folders, `.dart_tool`, app archives, cache folders, and Flutter project roots.

## `analyze`

Shows a higher-level storage report.

```sh
fclean analyze
```

Examples:

```sh
fclean analyze --path ~/Projects
fclean analyze --top 20
fclean analyze --path ~/Projects --top 15
```

Flags:

- `--path`, `-p`: root directory to analyze. Defaults to the current directory.
- `--top`: number of largest entries to show. Defaults to `10`.
- `--verbose`, `-v`: shows debug-level logging.

`analyze` helps find:

- Largest cleanup candidates
- Large `.apk`, `.aab`, and `.ipa` files
- Flutter projects
- Cache directory sizes

## `doctor`

Checks whether common Flutter development tools are installed and available.

```sh
fclean doctor
```

It checks:

- Flutter SDK
- Dart SDK
- Android SDK / `adb`
- Xcode, on macOS
- CocoaPods
- Homebrew
- FVM

The command exits successfully when all expected checks pass. Missing tools are reported with warnings.

## `cache gc`

Runs Flutter pub cache garbage collection and reports cache sizes first.

```sh
fclean cache gc
```

Examples:

```sh
fclean cache gc --dry-run
fclean cache gc --yes
fclean cache gc --verbose
```

Flags:

- `--dry-run`: shows cache sizes without running garbage collection.
- `--yes`, `-y`: skips the confirmation prompt.
- `--verbose`, `-v`: shows debug-level logging.

Internally this runs:

```sh
flutter pub cache gc
```

## `init`

Creates a `fclean.yaml` config file.

```sh
fclean init
```

Overwrite an existing config:

```sh
fclean init --force
```

Generated config:

```yaml
clean:
  gradle: true
  xcode: true
  cocoapods: true
  trash: false
```

Config options:

- `gradle`: include Gradle cache cleanup.
- `xcode`: include Xcode DerivedData cleanup.
- `cocoapods`: include CocoaPods cache cleanup.
- `trash`: include trash cleanup in standard non-interactive cleaning.

## Safety Notes

`fclean` is designed to avoid dangerous deletion behavior:

- Destructive actions require confirmation unless `--yes` is used.
- `--dry-run` previews cleanup without deleting files.
- Protected system paths are skipped.
- Temporary directories and trash are cleaned by deleting their contents, not the parent directory itself.
- Recursive scans skip common protected folders.

## Recommended Workflows

Weekly Flutter cleanup:

```sh
fclean clean --include flutter --dry-run
fclean clean --include flutter
fclean cache gc
```

Monthly local development cleanup:

```sh
fclean analyze --path ~/Projects --top 20
fclean clean --interactive --dry-run
fclean clean --interactive
```

CI-safe preview:

```sh
fclean scan --path .
fclean clean --path . --include flutter --dry-run --yes
```
