import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/currency_extension.dart';
import '../../data/models/category.dart';
import '../../data/models/category_budget.dart';
import '../../data/repositories/category_repository.dart';
import '../../providers/providers.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final monthlyBudget = ref.watch(currentMonthBudgetProvider);
    final categoryBudgets = ref.watch(currentMonthCategoryBudgetsProvider);
    final expenses = ref.watch(currentMonthExpensesProvider);
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final monthLabel = '${AppStrings.monthName(now.month)} ${now.year}';

    final totalSpent = expenses.fold(0.0, (s, e) => s + e.amount);
    final catTotals = <String, double>{};
    for (final e in expenses) {
      catTotals[e.categoryId] = (catTotals[e.categoryId] ?? 0) + e.amount;
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                '${AppStrings.tabBudgets} · $monthLabel',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Overall budget card
            _OverallBudgetCard(
              totalSpent: totalSpent,
              limit: monthlyBudget?.overallLimit,
              scheme: scheme,
              onEdit: () => _showBudgetSheet(
                context,
                ref,
                label: AppStrings.overallLimitTitle,
                currentLimit: monthlyBudget?.overallLimit,
                onSave: (val) {
                  ref.read(budgetRepoProvider).setMonthlyBudget(
                      AppStrings.monthKey(DateTime.now()), val);
                  triggerRefresh(ref);
                },
              ),
            ),
            const Gap(20),
            Text(
              AppStrings.categoryBudgets,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Gap(12),
            ...categories.map((cat) {
              final budget = categoryBudgets
                  .where((b) => b.categoryId == cat.id)
                  .firstOrNull;
              final spent = catTotals[cat.id] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CategoryBudgetCard(
                  category: cat,
                  budget: budget,
                  spent: spent,
                  scheme: scheme,
                  onEdit: () => _showBudgetSheet(
                    context,
                    ref,
                    label: cat.name,
                    currentLimit: budget?.limit,
                    onSave: (val) {
                      if (val == null) {
                        ref.read(budgetRepoProvider).removeCategoryBudget(
                            cat.id, AppStrings.monthKey(DateTime.now()));
                      } else {
                        ref.read(budgetRepoProvider).setCategoryBudget(
                            cat.id, AppStrings.monthKey(DateTime.now()), val);
                      }
                      triggerRefresh(ref);
                    },
                  ),
                ),
              );
            }),
            const Gap(16),
          ],
        ),
      ),
    );
  }

  void _showBudgetSheet(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required double? currentLimit,
    required void Function(double?) onSave,
  }) {
    final controller = TextEditingController(
      text: currentLimit?.toStringAsFixed(0) ?? '',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(ctx)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const Gap(16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: AppStrings.limitLabel,
                prefixText: '\$ ',
              ),
            ),
            const Gap(16),
            Row(
              children: [
                if (currentLimit != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        onSave(null);
                        Navigator.pop(ctx);
                      },
                      child: const Text(AppStrings.removeLimit),
                    ),
                  ),
                if (currentLimit != null) const Gap(12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final val = double.tryParse(controller.text.trim());
                      if (val != null && val > 0) {
                        onSave(val);
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text(AppStrings.saveLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverallBudgetCard extends StatelessWidget {
  final double totalSpent;
  final double? limit;
  final ColorScheme scheme;
  final VoidCallback onEdit;

  const _OverallBudgetCard({
    required this.totalSpent,
    required this.limit,
    required this.scheme,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasLimit = limit != null;
    final ratio = hasLimit ? (totalSpent / limit!).clamp(0.0, 1.0) : null;
    final exceeded = hasLimit && totalSpent > limit!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: exceeded
            ? scheme.errorContainer
            : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.overallLimitTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: exceeded ? scheme.onErrorContainer : scheme.onPrimaryContainer,
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hasLimit ? AppStrings.editLimit : AppStrings.setLimit,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: exceeded ? scheme.onErrorContainer : scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalSpent.toCOP(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: exceeded ? scheme.onErrorContainer : scheme.onPrimaryContainer,
                ),
              ),
              if (hasLimit)
                Text(
                  '/ ${limit!.toCOP()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: exceeded
                        ? scheme.onErrorContainer.withValues(alpha: 0.7)
                        : scheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
          if (hasLimit) ...[
            const Gap(10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  exceeded ? scheme.error : scheme.primary,
                ),
                minHeight: 6,
              ),
            ),
            if (exceeded) ...[
              const Gap(6),
              Text(
                AppStrings.budgetExceeded,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onErrorContainer,
                ),
              ),
            ],
          ],
          if (!hasLimit) ...[
            const Gap(4),
            Text(
              'Toca "Establecer límite" para controlar tu mes',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryBudgetCard extends StatelessWidget {
  final Category category;
  final CategoryBudget? budget;
  final double spent;
  final ColorScheme scheme;
  final VoidCallback onEdit;

  const _CategoryBudgetCard({
    required this.category,
    required this.budget,
    required this.spent,
    required this.scheme,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = Color(category.colorValue);
    final hasLimit = budget != null;
    final ratio = hasLimit ? (spent / budget!.limit).clamp(0.0, 1.0) : null;
    final exceeded = hasLimit && spent > budget!.limit;

    Color barColor;
    if (!hasLimit) {
      barColor = catColor;
    } else if (exceeded) {
      barColor = scheme.error;
    } else if (ratio! >= 0.9) {
      barColor = Colors.orange.shade600;
    } else if (ratio >= 0.7) {
      barColor = Colors.amber.shade600;
    } else {
      barColor = Colors.green.shade500;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: exceeded
            ? Border.all(color: scheme.error.withValues(alpha: 0.4), width: 1.5)
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CategoryRepository.iconFor(category.iconName),
                  size: 18,
                  color: catColor,
                ),
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(
                      spent.toCOP(),
                      style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Text(
                      hasLimit ? budget!.limit.toCOPShort() : '+ Meta',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasLimit ? scheme.primary : scheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  if (exceeded)
                    Text(
                      AppStrings.budgetExceeded,
                      style: TextStyle(
                          fontSize: 10,
                          color: scheme.error,
                          fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ],
          ),
          if (hasLimit) ...[
            const Gap(10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: scheme.outline.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
