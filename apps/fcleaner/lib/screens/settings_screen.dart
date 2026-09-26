import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: ListView(
        children: [
          Text('Settings', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Configure cleanup behavior and app preferences.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Cleanup config
          Text('Cleanup Targets', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          _SettingsCard(
            children: [
              _ToggleRow(
                icon: Icons.build_rounded,
                iconColor: AppTheme.androidGreen,
                title: 'Gradle Cache',
                subtitle: 'Android build cache (~/.gradle/caches)',
                value: settings.cleanConfig.gradle,
                onChanged: settings.setGradle,
              ),
              const Divider(color: AppTheme.borderDark, height: 1),
              _ToggleRow(
                icon: Icons.apple_rounded,
                iconColor: AppTheme.appleGray,
                title: 'Xcode DerivedData',
                subtitle: 'iOS/macOS build artifacts',
                value: settings.cleanConfig.xcode,
                onChanged: settings.setXcode,
              ),
              const Divider(color: AppTheme.borderDark, height: 1),
              _ToggleRow(
                icon: Icons.apps_rounded,
                iconColor: AppTheme.pubCachePurple,
                title: 'CocoaPods Cache',
                subtitle: 'iOS dependency cache',
                value: settings.cleanConfig.cocoapods,
                onChanged: settings.setCocoapods,
              ),
              const Divider(color: AppTheme.borderDark, height: 1),
              _ToggleRow(
                icon: Icons.delete_outline_rounded,
                iconColor: AppTheme.dangerRed,
                title: 'Trash / Recycle Bin',
                subtitle: 'Include system trash in cleanup',
                value: settings.cleanConfig.trash,
                onChanged: settings.setTrash,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // App preferences
          Text('Appearance', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          _SettingsCard(
            children: [
              _ToggleRow(
                icon: Icons.dark_mode_rounded,
                iconColor: AppTheme.accentCyan,
                title: 'Dark Mode',
                subtitle: 'Use dark color scheme',
                value: settings.isDarkMode,
                onChanged: settings.setDarkMode,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // History
          Text('Cleanup History', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${settings.history.length} cleanup sessions recorded',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (settings.history.isNotEmpty)
                            Text(
                              'Total reclaimed: ${_formatTotalBytes(settings.totalBytesReclaimed)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (settings.history.isNotEmpty)
                      TextButton(
                        onPressed: () => _confirmClearHistory(context),
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: AppTheme.dangerRed),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  String _formatTotalBytes(int bytes) {
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

  Future<void> _confirmClearHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('This will remove all cleanup session records.'),
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
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<SettingsProvider>().clearHistory();
    }
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
