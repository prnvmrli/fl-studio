import 'package:fclean/fclean.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/scan_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final theme = Theme.of(context);

    if (scan.entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analytics', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Run a scan first to see space breakdown analytics.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.pie_chart_rounded,
                    size: 80,
                    color: AppTheme.textTertiary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No scan data available',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final byKind = scan.entriesByKind;
    final kindColors = {
      ScanEntryKind.flutterProject: AppTheme.flutterBlue,
      ScanEntryKind.folder: AppTheme.systemOrange,
      ScanEntryKind.cache: AppTheme.pubCachePurple,
      ScanEntryKind.archive: AppTheme.dangerRed,
    };
    final kindLabels = {
      ScanEntryKind.flutterProject: 'Projects',
      ScanEntryKind.folder: 'Build Folders',
      ScanEntryKind.cache: 'Caches',
      ScanEntryKind.archive: 'Archives',
    };

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Analytics', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Space breakdown from your last scan (${scan.entries.length} items, ${formatBytes(scan.totalBytes)} total).',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Donut chart
                Expanded(
                  flex: 2,
                  child: GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('By Category', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 24),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 60,
                              sections: byKind.entries.map((entry) {
                                final bytes = entry.value.fold(
                                  0,
                                  (s, e) => s + e.bytes,
                                );
                                final pct = scan.totalBytes > 0
                                    ? bytes / scan.totalBytes * 100
                                    : 0.0;
                                return PieChartSectionData(
                                  value: bytes.toDouble(),
                                  color: kindColors[entry.key]!,
                                  radius: 40,
                                  title: '${pct.toStringAsFixed(1)}%',
                                  titleStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Legend
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: byKind.entries.map((entry) {
                            final bytes = entry.value.fold(
                              0,
                              (s, e) => s + e.bytes,
                            );
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: kindColors[entry.key],
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${kindLabels[entry.key]} (${formatBytes(bytes)})',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Top items bar chart
                Expanded(
                  flex: 3,
                  child: GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top 15 Largest',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: _TopItemsChart(
                            entries: scan.entries.take(15).toList(),
                            maxBytes: scan.entries.isEmpty
                                ? 1
                                : scan.entries.first.bytes,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopItemsChart extends StatelessWidget {
  const _TopItemsChart({required this.entries, required this.maxBytes});

  final List<ScanEntry> entries;
  final int maxBytes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final pct = maxBytes > 0 ? entry.bytes / maxBytes : 0.0;
        final name = entry.path.split('/').last;
        final color = entry.bytes > 100 * 1024 * 1024
            ? AppTheme.dangerRed
            : entry.bytes > 10 * 1024 * 1024
            ? AppTheme.systemOrange
            : AppTheme.accentTeal;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formatBytes(entry.bytes),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: color.withValues(alpha: 0.1),
                  color: color,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
