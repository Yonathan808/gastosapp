import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/category.dart';
import '../data/models/category_budget.dart';
import '../data/models/expense.dart';
import '../data/models/monthly_budget.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../core/constants/app_strings.dart';

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------

final expenseRepoProvider = Provider<ExpenseRepository>((_) => ExpenseRepository());
final categoryRepoProvider = Provider<CategoryRepository>((_) => CategoryRepository());
final budgetRepoProvider = Provider<BudgetRepository>((_) => BudgetRepository());

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

final themeProvider = StateProvider<bool>((_) => false); // false = light

// ---------------------------------------------------------------------------
// Reactivity: increment to force derived providers to re-read from Hive
// ---------------------------------------------------------------------------

final refreshProvider = StateProvider<int>((_) => 0);

void triggerRefresh(WidgetRef ref) =>
    ref.read(refreshProvider.notifier).update((n) => n + 1);

// ---------------------------------------------------------------------------
// Categories (static after seed — no refresh needed)
// ---------------------------------------------------------------------------

final categoriesProvider = Provider<List<Category>>((ref) {
  return ref.read(categoryRepoProvider).getAll();
});

// ---------------------------------------------------------------------------
// Expenses
// ---------------------------------------------------------------------------

final selectedMonthProvider = StateProvider<DateTime>((_) => DateTime.now());

final currentMonthExpensesProvider = Provider<List<Expense>>((ref) {
  ref.watch(refreshProvider);
  final now = DateTime.now();
  return ref.read(expenseRepoProvider).getByMonth(now.year, now.month);
});

final allExpensesProvider = Provider<List<Expense>>((ref) {
  ref.watch(refreshProvider);
  return ref.read(expenseRepoProvider).getAll();
});

final selectedMonthExpensesProvider = Provider<List<Expense>>((ref) {
  ref.watch(refreshProvider);
  final m = ref.watch(selectedMonthProvider);
  return ref.read(expenseRepoProvider).getByMonth(m.year, m.month);
});

final currentMonthTotalProvider = Provider<double>((ref) {
  return ref.watch(currentMonthExpensesProvider)
      .fold(0.0, (s, e) => s + e.amount);
});

final selectedMonthCategoryTotalsProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(selectedMonthExpensesProvider);
  final result = <String, double>{};
  for (final e in expenses) {
    result[e.categoryId] = (result[e.categoryId] ?? 0) + e.amount;
  }
  return result;
});

final selectedMonthDailyTotalsProvider = Provider<Map<int, double>>((ref) {
  ref.watch(refreshProvider);
  final m = ref.watch(selectedMonthProvider);
  return ref.read(expenseRepoProvider).totalByDayForMonth(m.year, m.month);
});

// ---------------------------------------------------------------------------
// Budgets
// ---------------------------------------------------------------------------

final currentMonthBudgetProvider = Provider<MonthlyBudget?>((ref) {
  ref.watch(refreshProvider);
  return ref.read(budgetRepoProvider)
      .getMonthlyBudget(AppStrings.monthKey(DateTime.now()));
});

final currentMonthCategoryBudgetsProvider = Provider<List<CategoryBudget>>((ref) {
  ref.watch(refreshProvider);
  return ref.read(budgetRepoProvider)
      .getCategoryBudgets(AppStrings.monthKey(DateTime.now()));
});
