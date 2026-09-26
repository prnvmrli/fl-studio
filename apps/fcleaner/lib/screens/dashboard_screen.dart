import 'dart:io';

import 'package:fclean/fclean.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/scan_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-scan caches on load for summary cards
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanProvider>().scanCaches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: ListView(
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to FCleaner',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reclaim disk space by cleaning Flutter build artifacts, caches, and system clutter.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Quick action cards
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.cleaning_services_rounded,
                  title: 'Scan & Clean',
                  subtitle: 'Discover & reclaim space',
                  gradient: const [AppTheme.accentTeal, AppTheme.accentCyan],
                  onTap: () => widget.onNavigate(1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.pie_chart_rounded,
                  title: 'Analytics',
                  subtitle: 'Visualize disk usage',
                  gradient: const [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                  onTap: () => widget.onNavigate(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.medical_services_rounded,
                  title: 'Doctor',
                  subtitle: 'Check tool health',
                  gradient: const [Color(0xFFFF6D00), Color(0xFFFFAB00)],
                  onTap: () => widget.onNavigate(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Cache summary
          Text('System Caches', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          if (scan.cacheEntries.isEmpty)
            GlassContainer(
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading cache info...',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: scan.cacheEntries.map((entry) {
                return _CacheSummaryCard(entry: entry);
              }).toList(),
            ),

          const SizedBox(height: 32),

          // Cleanup history
          Text('Recent Cleanups', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          if (settings.history.isEmpty)
            GlassContainer(
              child: Row(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'No cleanup history yet. Run your first clean!',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else
            ...settings.history.take(10).map((record) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _HistoryTile(record: record),
              );
            }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: _hovered
              ? (Matrix4.identity()..setTranslationRaw(0.0, -2.0, 0.0))
              : Matrix4.identity(),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient
                  .map((c) => c.withValues(alpha: _hovered ? 0.25 : 0.15))
                  .toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.gradient.first.withValues(
                alpha: _hovered ? 0.5 : 0.25,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: widget.gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CacheSummaryCard extends StatelessWidget {
  const _CacheSummaryCard({required this.entry});

  final ScanEntry entry;

  @override
  Widget build(BuildContext context) {
    final name = entry.path.split(Platform.pathSeparator).last;
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconForCache(name), color: AppTheme.accentTeal, size: 28),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              formatBytes(entry.bytes),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForCache(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('gradle')) return Icons.build_rounded;
    if (lower.contains('derived') || lower.contains('xcode')) {
      return Icons.apple_rounded;
    }
    if (lower.contains('cocoapods') || lower.contains('pods')) {
      return Icons.apps_rounded;
    }
    if (lower.contains('pub')) return Icons.inventory_2_rounded;
    return Icons.folder_rounded;
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record});

  final CleanupRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            record.wasDryRun
                ? Icons.visibility_rounded
                : Icons.check_circle_rounded,
            color: record.wasDryRun
                ? AppTheme.systemOrange
                : AppTheme.successGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.wasDryRun ? 'Dry Run' : 'Cleanup',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '${record.targetsDeleted} cleaned · ${record.targetsSkipped} skipped',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatBytes(record.bytesReclaimed),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentTeal,
                ),
              ),
              Text(
                _formatDate(record.timestamp),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
