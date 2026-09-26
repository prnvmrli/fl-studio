# Workspace Rules & Guidelines

## Publishing Policy
- **`apps/`**: Contains end-user applications (e.g. `fcleaner`). Must **NEVER** be published to pub.dev. Always retain `publish_to: none` in their `pubspec.yaml`.
- **`vendor/`**: Contains internal or vendored libraries/tools (e.g. `fclean`). Must **NEVER** be published to pub.dev. Always retain `publish_to: none` in their `pubspec.yaml`.
- **`packages/`**: Only packages under `packages/**` are eligible to be versioned and published to pub.dev via Melos.

## Monorepo Architecture
- Managed with Flutter Workspaces and Melos.
- `workspace:` in root `pubspec.yaml` specifies `- packages/**`.
- `apps/` and `vendor/` are excluded from Melos workspace packages.
