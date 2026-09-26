import 'package:fclean/fclean.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

Widget _chip(String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );

class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.category});

  final CleanupCategory category;

  (String, Color) get _data => switch (category) {
        CleanupCategory.flutter => ('FLUTTER', AppTheme.flutterBlue),
        CleanupCategory.android => ('ANDROID', AppTheme.androidGreen),
        CleanupCategory.apple => ('APPLE', AppTheme.appleGray),
        CleanupCategory.system => ('SYSTEM', AppTheme.systemOrange),
        CleanupCategory.pubCache => ('PUB', AppTheme.pubCachePurple),
      };

  @override
  Widget build(BuildContext context) {
    final (label, color) = _data;
    return _chip(label, color);
  }
}

class ScanKindChip extends StatelessWidget {
  const ScanKindChip({super.key, required this.kind});

  final ScanEntryKind kind;

  (String, Color) get _data => switch (kind) {
        ScanEntryKind.flutterProject => ('PROJECT', AppTheme.flutterBlue),
        ScanEntryKind.folder => ('BUILD', AppTheme.systemOrange),
        ScanEntryKind.cache => ('CACHE', AppTheme.pubCachePurple),
        ScanEntryKind.archive => ('ARCHIVE', AppTheme.dangerRed),
      };

  @override
  Widget build(BuildContext context) {
    final (label, color) = _data;
    return _chip(label, color);
  }
}
