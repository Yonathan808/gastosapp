import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/currency_extension.dart';
import '../../data/models/expense.dart';
import '../../providers/providers.dart';
import 'widgets/expense_list_tile.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String? _filterCategoryId;

  @override
  Widget build(BuildContext context) {
    final allExpenses = ref.watch(allExpensesProvider);
    final categories = ref.watch(categoriesProvider);
    final scheme = Theme.of(context).colorScheme;

    final filtered = _filterCategoryId == null
        ? allExpenses
        : allExpenses.where((e) => e.categoryId == _filterCategoryId).toList();

    final grouped = groupBy(filtered, (Expense e) =>
        DateTime(e.date.year, e.date.month, e.date.day));

    final sortedDays = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                AppStrings.tabHistory,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Category filter chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'Todos',
                    selected: _filterCategoryId == null,
                    color: scheme.primary,
                    onTap: () => setState(() => _filterCategoryId = null),
                  ),
                  ...categories.map((cat) => _FilterChip(
                    label: cat.name,
                    selected: _filterCategoryId == cat.id,
                    color: Color(cat.colorValue),
                    onTap: () => setState(() =>
                        _filterCategoryId = _filterCategoryId == cat.id ? null : cat.id),
                  )),
                ],
              ),
            ),
            const Gap(8),
            // Expenses list
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sortedDays.length,
                      itemBuilder: (context, i) {
                        final day = sortedDays[i];
                        final dayExpenses = grouped[day]!;
                        final dayTotal = dayExpenses.fold(0.0, (s, e) => s + e.amount);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _dayLabel(day),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: scheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  Text(
                                    dayTotal.toCOP(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: scheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...dayExpenses.map((expense) {
                              final cat = categories.firstWhereOrNull(
                                  (c) => c.id == expense.categoryId);
                              return ExpenseListTile(
                                expense: expense,
                                category: cat,
                                onDelete: () => _deleteExpense(context, ref, expense),
                              );
                            }),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteExpense(BuildContext context, WidgetRef ref, Expense expense) {
    ref.read(expenseRepoProvider).delete(expense.id);
    triggerRefresh(ref);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.deleteExpenseMsg),
        action: SnackBarAction(
          label: AppStrings.undo,
          onPressed: () {
            ref.read(expenseRepoProvider).add(expense);
            triggerRefresh(ref);
          },
        ),
      ),
    );
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (d == today) return 'Hoy';
    if (d == yesterday) return 'Ayer';
    return DateFormat('EEEE d MMM', 'es').format(d);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: selected ? Border.all(color: color.withValues(alpha: 0.5)) : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 56, color: scheme.onSurface.withValues(alpha: 0.2)),
          const Gap(16),
          Text(
            AppStrings.noExpenses,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
