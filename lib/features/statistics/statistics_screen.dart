import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/currency_extension.dart';
import '../../data/models/category.dart';
import '../../providers/providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final expenses = ref.watch(selectedMonthExpensesProvider);
    final categoryTotals = ref.watch(selectedMonthCategoryTotalsProvider);
    final categories = ref.watch(categoriesProvider);
    final dailyTotals = ref.watch(selectedMonthDailyTotalsProvider);
    final scheme = Theme.of(context).colorScheme;

    final totalMonth = expenses.fold(0.0, (s, e) => s + e.amount);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.tabStats,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _MonthPicker(selectedMonth: selectedMonth, ref: ref),
                ],
              ),
            ),
            Expanded(
              child: expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart_rounded,
                              size: 56,
                              color: scheme.onSurface.withValues(alpha: 0.2)),
                          const Gap(16),
                          Text(
                            'Sin datos para este mes',
                            style: TextStyle(
                                color: scheme.onSurface.withValues(alpha: 0.4),
                                fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const Gap(8),
                        // Total card
                        _TotalCard(total: totalMonth, scheme: scheme),
                        const Gap(16),
                        // Pie chart
                        if (categoryTotals.isNotEmpty) ...[
                          Text('Por categoría',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const Gap(12),
                          _PieSection(
                            categoryTotals: categoryTotals,
                            categories: categories,
                            total: totalMonth,
                            scheme: scheme,
                          ),
                          const Gap(20),
                        ],
                        // Bar chart
                        if (dailyTotals.isNotEmpty) ...[
                          Text('Gasto diario',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const Gap(12),
                          _DailyBarChart(
                            dailyTotals: dailyTotals,
                            daysInMonth: _daysInMonth(selectedMonth),
                            scheme: scheme,
                          ),
                          const Gap(20),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  int _daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;
}

class _MonthPicker extends StatelessWidget {
  final DateTime selectedMonth;
  final WidgetRef ref;

  const _MonthPicker({required this.selectedMonth, required this.ref});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isCurrentMonth =
        selectedMonth.year == now.year && selectedMonth.month == now.month;

    return Row(
      children: [
        _NavBtn(
          icon: Icons.chevron_left_rounded,
          onTap: () {
            ref.read(selectedMonthProvider.notifier).update(
                  (d) => DateTime(d.year, d.month - 1),
                );
          },
          scheme: scheme,
        ),
        const Gap(4),
        Text(
          '${AppStrings.monthName(selectedMonth.month).substring(0, 3)} ${selectedMonth.year}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const Gap(4),
        _NavBtn(
          icon: Icons.chevron_right_rounded,
          onTap: isCurrentMonth
              ? null
              : () {
                  ref.read(selectedMonthProvider.notifier).update(
                        (d) => DateTime(d.year, d.month + 1),
                      );
                },
          scheme: scheme,
        ),
      ],
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final ColorScheme scheme;

  const _NavBtn({required this.icon, required this.onTap, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap == null
              ? scheme.onSurface.withValues(alpha: 0.3)
              : scheme.onSurface,
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double total;
  final ColorScheme scheme;

  const _TotalCard({required this.total, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total del mes',
              style: TextStyle(
                  color: scheme.onPrimaryContainer, fontWeight: FontWeight.w500)),
          Text(
            total.toCOP(),
            style: TextStyle(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class _PieSection extends StatefulWidget {
  final Map<String, double> categoryTotals;
  final List<Category> categories;
  final double total;
  final ColorScheme scheme;

  const _PieSection({
    required this.categoryTotals,
    required this.categories,
    required this.total,
    required this.scheme,
  });

  @override
  State<_PieSection> createState() => _PieSectionState();
}

class _PieSectionState extends State<_PieSection> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final sortedEntries = widget.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sections = sortedEntries.asMap().entries.map((entry) {
      final i = entry.key;
      final catId = entry.value.key;
      final amount = entry.value.value;
      final cat = widget.categories.firstWhere(
          (c) => c.id == catId,
          orElse: () => const Category(
              id: '', name: 'Otros', iconName: 'otros',
              colorValue: 0xFF78909C, isDefault: false, sortOrder: 99));
      final color = Color(cat.colorValue);
      final isTouched = i == _touchedIndex;

      return PieChartSectionData(
        value: amount,
        color: color,
        radius: isTouched ? 70 : 60,
        title: '${(amount / widget.total * 100).toStringAsFixed(0)}%',
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 3,
              centerSpaceRadius: 45,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = null;
                    } else {
                      _touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    }
                  });
                },
              ),
            ),
          ),
        ),
        const Gap(16),
        // Legend
        ...sortedEntries.map((entry) {
          final cat = widget.categories.firstWhere(
              (c) => c.id == entry.key,
              orElse: () => const Category(
                  id: '', name: 'Otros', iconName: 'otros',
                  colorValue: 0xFF78909C, isDefault: false, sortOrder: 99));
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(cat.colorValue),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const Gap(10),
                Expanded(child: Text(cat.name, style: const TextStyle(fontSize: 13))),
                Text(
                  entry.value.toCOP(),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _DailyBarChart extends StatelessWidget {
  final Map<int, double> dailyTotals;
  final int daysInMonth;
  final ColorScheme scheme;

  const _DailyBarChart({
    required this.dailyTotals,
    required this.daysInMonth,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = dailyTotals.values.isEmpty
        ? 1.0
        : dailyTotals.values.reduce((a, b) => a > b ? a : b);

    final groups = List.generate(daysInMonth, (i) {
      final day = i + 1;
      final val = dailyTotals[day] ?? 0;
      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: val,
            color: val > 0 ? scheme.primary : scheme.surfaceContainerHighest,
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          barGroups: groups,
          maxY: maxValue * 1.2,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                getTitlesWidget: (val, meta) {
                  if (val % 5 != 0) return const SizedBox.shrink();
                  return Text(val.toInt().toString(),
                      style: TextStyle(
                          fontSize: 10,
                          color: scheme.onSurface.withValues(alpha: 0.5)));
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toCOP(),
                  TextStyle(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
