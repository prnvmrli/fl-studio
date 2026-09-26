String formatBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var size = bytes.toDouble();
  var unit = 0;

  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit++;
  }

  if (unit == 0) return '$bytes ${units[unit]}';
  return '${size.toStringAsFixed(size >= 10 ? 1 : 2)} ${units[unit]}';
}
