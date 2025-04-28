import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum IncidentType { emergency, route, report }

/// Card widget to display incident information
class IncidentCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String time;
  final IncidentType type;

  const IncidentCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.type,
  });

  Color get _typeColor {
    switch (type) {
      case IncidentType.emergency:
        return Colors.red;
      case IncidentType.route:
        return AppColors.safeZone;
      case IncidentType.report:
        return Colors.orange;
    }
  }

  IconData get _typeIcon {
    switch (type) {
      case IncidentType.emergency:
        return Icons.warning_rounded;
      case IncidentType.route:
        return Icons.route;
      case IncidentType.report:
        return Icons.report_problem;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_typeIcon, color: _typeColor, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              date,
              style: TextStyle(
                color:Colors.black,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
