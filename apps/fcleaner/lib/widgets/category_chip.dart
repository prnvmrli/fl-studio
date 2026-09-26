import 'package:fclean/fclean.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.category});

  final CleanupCategory category;

  @override
  Widget build(BuildContext context) {
    final label = _label;
    final color = _color;

    return Container(
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
  }

  String get _label => switch (category) {
    CleanupCategory.flutter => 'FLUTTER',
    CleanupCategory.android => 'ANDROID',
    CleanupCategory.apple => 'APPLE',
    CleanupCategory.system => 'SYSTEM',
    CleanupCategory.pubCache => 'PUB',
  };

  Color get _color => switch (category) {
    CleanupCategory.flutter => AppTheme.flutterBlue,
    CleanupCategory.android => AppTheme.androidGreen,
    CleanupCategory.apple => AppTheme.appleGray,
    CleanupCategory.system => AppTheme.systemOrange,
    CleanupCategory.pubCache => AppTheme.pubCachePurple,
  };
}

class ScanKindChip extends StatelessWidget {
  const ScanKindChip({super.key, required this.kind});

  final ScanEntryKind kind;

  @override
  Widget build(BuildContext context) {
    final label = switch (kind) {
      ScanEntryKind.flutterProject => 'PROJECT',
      ScanEntryKind.folder => 'BUILD',
      ScanEntryKind.cache => 'CACHE',
      ScanEntryKind.archive => 'ARCHIVE',
    };
    final color = switch (kind) {
      ScanEntryKind.flutterProject => AppTheme.flutterBlue,
      ScanEntryKind.folder => AppTheme.systemOrange,
      ScanEntryKind.cache => AppTheme.pubCachePurple,
      ScanEntryKind.archive => AppTheme.dangerRed,
    };

    return Container(
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
  }
}
