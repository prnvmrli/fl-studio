# Releasing

This workspace uses Melos for versioning, changelog generation, and publishing.

## Version All

Version the root workspace and all packages:

```sh
fvm dart run melos version --all
```

This includes the private root package. Melos updates package versions, package changelogs, the root workspace changelog, creates a release commit, and creates tags.

## Publish

Validate all publishable packages except the private root package:

```sh
fvm dart run melos publish --no-private
```

Publish all publishable packages except the private root package:

```sh
fvm dart run melos publish --no-private --no-dry-run
```

Validate one package:

```sh
fvm dart run melos publish --scope=android_system_chrome
```

Publish one package:

```sh
fvm dart run melos publish --scope=android_system_chrome --no-dry-run
```

`melos publish` is a dry run by default. Add `--no-dry-run` only when you are ready to publish.
