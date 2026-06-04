import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../data/models/monthly_budget.dart';

class MonthlyProgressBanner extends StatelessWidget {
  final double totalSpent;
  final MonthlyBudget? budget;

  const MonthlyProgressBanner({
    super.key,
    required this.totalSpent,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final monthLabel = '${AppStrings.monthName(now.month)} ${now.year}';
    final limit = budget?.overallLimit;

    if (limit == null) {
      return _Banner(
        scheme: scheme,
        left: monthLabel,
        right: totalSpent.toCOP(),
        progress: null,
        color: scheme.primaryContainer,
        onSurface: scheme.onPrimaryContainer,
      );
    }

    final ratio = (totalSpent / limit).clamp(0.0, 1.0);
    final Color barColor;
    final String statusText;

    if (ratio >= 1.0) {
      barColor = scheme.error;
      statusText = AppStrings.budgetExceeded;
    } else if (ratio >= 0.9) {
      barColor = Colors.orange.shade600;
      statusText = 'Casi en el límite';
    } else if (ratio >= 0.7) {
      barColor = Colors.amber.shade600;
      statusText = '${(ratio * 100).toStringAsFixed(0)}% gastado';
    } else {
      barColor = Colors.green.shade500;
      statusText = '${(ratio * 100).toStringAsFixed(0)}% gastado';
    }

    return _Banner(
      scheme: scheme,
      left: monthLabel,
      right: '${totalSpent.toCOPShort()} / ${limit.toCOPShort()}',
      progress: ratio,
      color: barColor.withValues(alpha: 0.12),
      onSurface: scheme.onSurface,
      barColor: barColor,
      statusText: statusText,
    );
  }
}

class _Banner extends StatelessWidget {
  final ColorScheme scheme;
  final String left;
  final String right;
  final double? progress;
  final Color color;
  final Color onSurface;
  final Color? barColor;
  final String? statusText;

  const _Banner({
    required this.scheme,
    required this.left,
    required this.right,
    required this.progress,
    required this.color,
    required this.onSurface,
    this.barColor,
    this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(left,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: onSurface)),
              Text(right,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: onSurface)),
            ],
          ),
          if (progress != null) ...[
            const Gap(8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: scheme.outline.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(barColor!),
                minHeight: 6,
              ),
            ),
            const Gap(4),
            Text(
              statusText!,
              style: TextStyle(
                  fontSize: 11,
                  color: barColor!.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}
