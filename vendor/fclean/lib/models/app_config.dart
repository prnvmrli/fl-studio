class AppConfig {
  const AppConfig({this.clean = const CleanConfig()});

  final CleanConfig clean;

  static const defaults = AppConfig();
}

class CleanConfig {
  const CleanConfig({
    this.gradle = true,
    this.xcode = true,
    this.cocoapods = true,
    this.trash = false,
  });

  final bool gradle;
  final bool xcode;
  final bool cocoapods;
  final bool trash;
}
