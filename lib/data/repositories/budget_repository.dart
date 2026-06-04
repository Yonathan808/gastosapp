import 'package:hive/hive.dart';
import '../models/monthly_budget.dart';
import '../models/category_budget.dart';
import '../../core/constants/hive_boxes.dart';

class BudgetRepository {
  Box<MonthlyBudget> get _budgetBox =>
      Hive.box<MonthlyBudget>(HiveBoxes.monthlyBudgets);
  Box<CategoryBudget> get _catBox =>
      Hive.box<CategoryBudget>(HiveBoxes.categoryBudgets);

  MonthlyBudget? getMonthlyBudget(String monthKey) => _budgetBox.get(monthKey);

  void setMonthlyBudget(String monthKey, double? limit) {
    if (limit == null) {
      _budgetBox.delete(monthKey);
    } else {
      _budgetBox.put(monthKey, MonthlyBudget(
        id: monthKey,
        overallLimit: limit,
        updatedAt: DateTime.now(),
      ));
    }
  }

  List<CategoryBudget> getCategoryBudgets(String monthKey) {
    return _catBox.values
        .where((b) => b.monthKey == monthKey)
        .toList();
  }

  void setCategoryBudget(String categoryId, String monthKey, double limit) {
    final id = '$categoryId-$monthKey';
    _catBox.put(id, CategoryBudget(
      id: id, categoryId: categoryId, monthKey: monthKey, limit: limit,
    ));
  }

  void removeCategoryBudget(String categoryId, String monthKey) {
    _catBox.delete('$categoryId-$monthKey');
  }
}
