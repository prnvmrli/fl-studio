import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SidebarNav extends StatelessWidget {
  const SidebarNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _destinations = [
    (icon: Icons.dashboard_rounded, label: 'Dashboard'),
    (icon: Icons.cleaning_services_rounded, label: 'Scan & Clean'),
    (icon: Icons.pie_chart_rounded, label: 'Analytics'),
    (icon: Icons.medical_services_rounded, label: 'Doctor'),
    (icon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: AppTheme.cardDark,
        border: Border(right: BorderSide(color: AppTheme.borderDark, width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Logo / Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accentTeal, AppTheme.accentCyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.cleaning_services_rounded,
                    color: AppTheme.surfaceDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'FCleaner',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _destinations.length,
              itemBuilder: (context, index) {
                final dest = _destinations[index];
                final selected = index == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _NavItem(
                    icon: dest.icon,
                    label: dest.label,
                    selected: selected,
                    onTap: () => onDestinationSelected(index),
                  ),
                );
              },
            ),
          ),
          // Version footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('v0.1.0', style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
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
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.selected
                ? AppTheme.accentTeal.withValues(alpha: 0.12)
                : _hovered
                ? AppTheme.cardDarkElevated
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: widget.selected
                ? Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: widget.selected
                    ? AppTheme.accentTeal
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: widget.selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: widget.selected
                        ? AppTheme.accentTeal
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
