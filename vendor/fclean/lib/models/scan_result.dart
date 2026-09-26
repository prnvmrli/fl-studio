class ScanEntry {
  const ScanEntry({
    required this.path,
    required this.bytes,
    required this.kind,
  });

  final String path;
  final int bytes;
  final ScanEntryKind kind;
}

enum ScanEntryKind { folder, archive, flutterProject, cache }

class ScanResult {
  const ScanResult({required this.entries, required this.scannedRoots});

  final List<ScanEntry> entries;
  final List<String> scannedRoots;

  int get totalBytes => entries.fold(0, (sum, entry) => sum + entry.bytes);
}

class ScanProgress {
  const ScanProgress({
    required this.currentPath,
    required this.newEntries,
    required this.totalEntries,
    required this.totalBytes,
  });

  final String currentPath;
  final List<ScanEntry> newEntries;
  final int totalEntries;
  final int totalBytes;
}
