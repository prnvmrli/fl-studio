class CleanupTarget {
  const CleanupTarget({
    required this.id,
    required this.label,
    required this.path,
    required this.category,
    this.destructive = true,
    this.contentsOnly = false,
    this.command,
  });

  final String id;
  final String label;
  final String path;
  final CleanupCategory category;
  final bool destructive;
  final bool contentsOnly;
  final List<String>? command;
}

enum CleanupCategory { flutter, android, apple, system, pubCache }
