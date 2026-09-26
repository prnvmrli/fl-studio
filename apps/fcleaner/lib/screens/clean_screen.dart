import 'dart:io';

import 'package:fclean/fclean.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/clean_provider.dart';
import '../providers/scan_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_chip.dart';

class CleanScreen extends StatefulWidget {
  const CleanScreen({super.key, this.onNavigateToAnalytics});

  final VoidCallback? onNavigateToAnalytics;

  @override
  State<CleanScreen> createState() => _CleanScreenState();
}

class _CleanScreenState extends State<CleanScreen> {
  CleanupCategory? _filterCategory;
  String _activeRoot = '';

  Future<void> _startScan(String root) async {
    setState(() => _activeRoot = root);
    final clean = context.read<CleanProvider>();
    final scan = context.read<ScanProvider>();
    final settings = context.read<SettingsProvider>();

    clean.config = settings.appConfig;
    clean.discoverTargets(root: root);
    scan.scan([root]);
  }

  void _stopScan() {
    context.read<ScanProvider>().cancelScan();
    context.read<CleanProvider>().reset();
    setState(() => _activeRoot = '');
  }

  @override
  Widget build(BuildContext context) {
    final clean = context.watch<CleanProvider>();
    final scan = context.watch<ScanProvider>();
    final theme = Theme.of(context);
    final isScanning =
        clean.state == CleanState.discovering ||
        scan.state == ScanState.scanning;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Scan & Clean', style: theme.textTheme.headlineLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Discover Flutter project build artifacts, caches, and reclaim disk space safely.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (isScanning)
                OutlinedButton.icon(
                  onPressed: _stopScan,
                  icon: const Icon(Icons.stop_rounded, size: 18),
                  label: const Text('Stop Scan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.dangerRed,
                    side: const BorderSide(color: AppTheme.dangerRed),
                  ),
                )
              else if (clean.state == CleanState.ready ||
                  clean.state == CleanState.done) ...[
                // Dry run toggle pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDarkElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        clean.dryRun
                            ? Icons.visibility_rounded
                            : Icons.delete_outline_rounded,
                        size: 16,
                        color: clean.dryRun
                            ? AppTheme.systemOrange
                            : AppTheme.accentTeal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        clean.dryRun ? 'Dry Run (Safe)' : 'Live Delete',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: clean.dryRun
                              ? AppTheme.systemOrange
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: clean.dryRun,
                        onChanged: (v) => clean.dryRun = v,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // ── Phase 1: Location picker (Idle) ──────────────────────────────
          if (clean.state == CleanState.idle && !isScanning) ...[
            Row(
              children: [
                Expanded(
                  child: _ScanOptionCard(
                    icon: Icons.folder_copy_rounded,
                    title: 'Current Workspace',
                    subtitle: Directory.current.path,
                    badge: 'Local',
                    onTap: () => _startScan(Directory.current.path),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ScanOptionCard(
                    icon: Icons.drive_folder_upload_rounded,
                    title: 'Choose Directory',
                    subtitle: 'Pick any Flutter project or repo',
                    badge: 'Custom',
                    onTap: () async {
                      final result = await FilePicker.platform
                          .getDirectoryPath();
                      if (result != null && context.mounted) {
                        _startScan(result);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ScanOptionCard(
                    icon: Icons.home_repair_service_rounded,
                    title: 'Home & Caches',
                    subtitle: Platform.environment['HOME'] ?? '~',
                    badge: 'System',
                    onTap: () {
                      final home = Platform.environment['HOME'];
                      if (home != null) _startScan(home);
                    },
                  ),
                ),
              ],
            ),
          ],

          // ── Phase 2: Scanning in progress ─────────────────────────────────
          if (isScanning && clean.state != CleanState.ready) ...[
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppTheme.accentTeal,
                          backgroundColor: Color(0x2600BFA5),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scan.entries.isEmpty
                                  ? 'Analyzing targets in $_activeRoot...'
                                  : 'Scanning... ${scan.entries.length} items found',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              scan.currentPath.isEmpty
                                  ? _activeRoot
                                  : scan.currentPath,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatBytes(scan.totalBytes),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      backgroundColor: Color(0x1A00BFA5),
                      color: AppTheme.accentTeal,
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Phase 3: Cleaning in progress ─────────────────────────────────
          if (clean.state == CleanState.cleaning) ...[
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppTheme.accentTeal,
                          backgroundColor: Color(0x2600BFA5),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clean.dryRun
                                  ? 'Dry run simulation in progress...'
                                  : 'Cleaning selected targets...',
                              style: theme.textTheme.titleMedium,
                            ),
                            if (clean.currentTargetLabel != null)
                              Text(
                                clean.currentTargetLabel!,
                                style: theme.textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '${clean.cleanedCount}/${clean.selectedIds.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: clean.selectedIds.isEmpty
                          ? 0
                          : clean.cleanedCount / clean.selectedIds.length,
                      backgroundColor: const Color(0x1A00BFA5),
                      color: AppTheme.accentTeal,
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Phase 4: Done summary ─────────────────────────────────────────
          if (clean.state == CleanState.done && clean.summary != null) ...[
            _CleanupSummaryCard(
              summary: clean.summary!,
              dryRun: clean.dryRun,
              onReset: () {
                clean.reset();
                scan.reset();
                setState(() => _activeRoot = '');
              },
              onNavigateToAnalytics: widget.onNavigateToAnalytics,
            ),
            const SizedBox(height: 16),
          ],

          // ── Phase 5: Ready / Target list ──────────────────────────────────
          if (clean.state == CleanState.ready) ...[
            if (clean.targets.isEmpty)
              Expanded(
                child: Center(
                  child: GlassContainer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 64,
                          color: AppTheme.successGreen,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Cleanup Targets Found',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Everything is squeaky clean in this directory.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            clean.reset();
                            scan.reset();
                            setState(() => _activeRoot = '');
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Scan Another Location'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              // Action & filter bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Target stats + Primary action buttons
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${clean.targets.length} targets discovered',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${clean.selectedIds.length} of ${clean.targets.length} selected • ${formatBytes(clean.totalSelectedBytes)} reclaimable',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.accentTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _startScan(
                          _activeRoot.isEmpty
                              ? Directory.current.path
                              : _activeRoot,
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Rescan'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: clean.selectedIds.isEmpty
                            ? null
                            : () => _confirmAndClean(context, clean),
                        icon: Icon(
                          clean.dryRun
                              ? Icons.visibility_rounded
                              : Icons.cleaning_services_rounded,
                          size: 18,
                        ),
                        label: Text(
                          clean.dryRun
                              ? 'Preview (${formatBytes(clean.totalSelectedBytes)})'
                              : 'Clean (${formatBytes(clean.totalSelectedBytes)})',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Secondary row: Category filter chips + Select / Deselect All
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildCategoryFilterPill(
                            label: 'All',
                            category: null,
                            count: clean.targets.length,
                          ),
                          for (final cat in clean.targetsByCategory.keys)
                            _buildCategoryFilterPill(
                              label: cat.name.toUpperCase(),
                              category: cat,
                              count: clean.targetsByCategory[cat]!.length,
                            ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: clean.selectAll,
                            icon: const Icon(
                              Icons.select_all_rounded,
                              size: 16,
                            ),
                            label: const Text('Select All'),
                          ),
                          const SizedBox(width: 4),
                          TextButton.icon(
                            onPressed: clean.deselectAll,
                            icon: const Icon(Icons.deselect_rounded, size: 16),
                            label: const Text('Deselect All'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Targets list
              Expanded(
                child: ListView(
                  children: [
                    for (final category in clean.targetsByCategory.keys)
                      if (_filterCategory == null ||
                          _filterCategory == category) ...[
                        _CategoryHeader(
                          category: category,
                          targets: clean.targetsByCategory[category]!,
                          selectedIds: clean.selectedIds,
                          onSelectCategory: () =>
                              clean.selectCategory(category),
                        ),
                        ...clean.targetsByCategory[category]!.map((target) {
                          return _TargetTile(
                            target: target,
                            selected: clean.selectedIds.contains(target.id),
                            size: clean.targetSizes[target.id] ?? 0,
                            onToggle: () => clean.toggleTarget(target.id),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                  ],
                ),
              ),
            ],
          ],

          if (clean.state == CleanState.error)
            GlassContainer(
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppTheme.dangerRed,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      clean.errorMessage ?? 'Operation failed',
                      style: const TextStyle(color: AppTheme.dangerRed),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      clean.reset();
                      scan.reset();
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterPill({
    required String label,
    required CleanupCategory? category,
    required int count,
  }) {
    final isSelected = _filterCategory == category;
    return InkWell(
      onTap: () => setState(() => _filterCategory = category),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentTeal.withValues(alpha: 0.2)
              : AppTheme.cardDarkElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentTeal.withValues(alpha: 0.6)
                : AppTheme.borderDark,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppTheme.accentTeal : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndClean(
    BuildContext context,
    CleanProvider clean,
  ) async {
    final settingsProvider = context.read<SettingsProvider>();

    if (clean.dryRun) {
      await clean.cleanSelected();
      if (clean.summary != null) {
        settingsProvider.addCleanupRecord(
          CleanupRecord(
            timestamp: DateTime.now(),
            bytesReclaimed: clean.summary!.reclaimedBytes,
            targetsDeleted: clean.summary!.deletedCount,
            targetsSkipped: clean.summary!.skippedCount,
            wasDryRun: true,
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Cleanup'),
        content: Text(
          'This will permanently delete ${clean.selectedIds.length} item(s) '
          '(~${formatBytes(clean.totalSelectedBytes)}). This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await clean.cleanSelected();
      if (clean.summary != null) {
        settingsProvider.addCleanupRecord(
          CleanupRecord(
            timestamp: DateTime.now(),
            bytesReclaimed: clean.summary!.reclaimedBytes,
            targetsDeleted: clean.summary!.deletedCount,
            targetsSkipped: clean.summary!.skippedCount,
            wasDryRun: false,
          ),
        );
      }
    }
  }
}

class _ScanOptionCard extends StatefulWidget {
  const _ScanOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  @override
  State<_ScanOptionCard> createState() => _ScanOptionCardState();
}

class _ScanOptionCardState extends State<_ScanOptionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.cardDarkElevated : AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? AppTheme.accentTeal.withValues(alpha: 0.5)
                  : AppTheme.borderDark,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppTheme.accentTeal.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(widget.icon, color: AppTheme.accentTeal, size: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: Text(
                      widget.badge,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.category,
    required this.targets,
    required this.selectedIds,
    required this.onSelectCategory,
  });

  final CleanupCategory category;
  final List<CleanupTarget> targets;
  final Set<String> selectedIds;
  final VoidCallback onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final selectedCount = targets
        .where((t) => selectedIds.contains(t.id))
        .length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CategoryChip(category: category),
          const SizedBox(width: 12),
          Text(
            '$selectedCount / ${targets.length} selected',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          TextButton(
            onPressed: onSelectCategory,
            child: const Text('Select all in category'),
          ),
        ],
      ),
    );
  }
}

class _TargetTile extends StatefulWidget {
  const _TargetTile({
    required this.target,
    required this.selected,
    required this.size,
    required this.onToggle,
  });

  final CleanupTarget target;
  final bool selected;
  final int size;
  final VoidCallback onToggle;

  @override
  State<_TargetTile> createState() => _TargetTileState();
}

class _TargetTileState extends State<_TargetTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.selected
                ? AppTheme.accentTeal.withValues(alpha: 0.08)
                : _hovered
                ? AppTheme.cardDarkElevated
                : AppTheme.cardDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.selected
                  ? AppTheme.accentTeal.withValues(alpha: 0.3)
                  : AppTheme.borderDark,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: widget.selected,
                onChanged: (_) => widget.onToggle(),
              ),
              const SizedBox(width: 8),
              Icon(
                widget.target.destructive
                    ? Icons.warning_amber_rounded
                    : Icons.folder_rounded,
                size: 18,
                color: widget.target.destructive
                    ? AppTheme.systemOrange
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.target.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      widget.target.path,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatBytes(widget.size),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: widget.size > 100 * 1024 * 1024
                      ? AppTheme.dangerRed
                      : widget.size > 10 * 1024 * 1024
                      ? AppTheme.systemOrange
                      : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CleanupSummaryCard extends StatelessWidget {
  const _CleanupSummaryCard({
    required this.summary,
    required this.dryRun,
    required this.onReset,
    this.onNavigateToAnalytics,
  });

  final CleanupSummary summary;
  final bool dryRun;
  final VoidCallback onReset;
  final VoidCallback? onNavigateToAnalytics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                dryRun ? Icons.visibility_rounded : Icons.check_circle_rounded,
                color: dryRun ? AppTheme.systemOrange : AppTheme.successGreen,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                dryRun ? 'Dry Run Simulation Complete' : 'Cleanup Complete!',
                style: theme.textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SummaryMetric(
                label: 'Space Reclaimed',
                value: formatBytes(summary.reclaimedBytes),
                color: AppTheme.accentTeal,
              ),
              const SizedBox(width: 32),
              _SummaryMetric(
                label: 'Deleted',
                value: '${summary.deletedCount}',
                color: AppTheme.successGreen,
              ),
              const SizedBox(width: 32),
              _SummaryMetric(
                label: 'Skipped',
                value: '${summary.skippedCount}',
                color: AppTheme.textSecondary,
              ),
              const Spacer(),
              if (onNavigateToAnalytics != null) ...[
                OutlinedButton.icon(
                  onPressed: onNavigateToAnalytics,
                  icon: const Icon(Icons.pie_chart_rounded, size: 18),
                  label: const Text('View Analytics'),
                ),
                const SizedBox(width: 12),
              ],
              ElevatedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Scan Again'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
