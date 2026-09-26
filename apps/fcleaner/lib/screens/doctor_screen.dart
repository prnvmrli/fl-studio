import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/doctor_provider.dart';
import '../theme/app_theme.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doc = context.read<DoctorProvider>();
      if (doc.checks.isEmpty) doc.run();
    });
  }

  @override
  Widget build(BuildContext context) {
    final doc = context.watch<DoctorProvider>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Doctor', style: theme.textTheme.headlineLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Check which development tools are available on your system.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: doc.loading ? null : doc.run,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (doc.loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(color: AppTheme.accentTeal),
              ),
            )
          else if (doc.checks.isNotEmpty) ...[
            // Summary bar
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    doc.availableCount == doc.totalCount
                        ? Icons.check_circle_rounded
                        : Icons.warning_amber_rounded,
                    color: doc.availableCount == doc.totalCount
                        ? AppTheme.successGreen
                        : AppTheme.systemOrange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${doc.availableCount} / ${doc.totalCount} tools available',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView.separated(
                itemCount: doc.checks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final check = doc.checks[index];
                  return _DoctorCheckTile(
                    name: check.name,
                    available: check.available,
                    message: check.message,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DoctorCheckTile extends StatelessWidget {
  const _DoctorCheckTile({
    required this.name,
    required this.available,
    required this.message,
  });

  final String name;
  final bool available;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (available ? AppTheme.successGreen : AppTheme.dangerRed)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              available ? Icons.check_rounded : Icons.close_rounded,
              size: 20,
              color: available ? AppTheme.successGreen : AppTheme.dangerRed,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: available
                        ? AppTheme.textSecondary
                        : AppTheme.dangerRed.withValues(alpha: 0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (available ? AppTheme.successGreen : AppTheme.dangerRed)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              available ? 'Available' : 'Missing',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: available ? AppTheme.successGreen : AppTheme.dangerRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
