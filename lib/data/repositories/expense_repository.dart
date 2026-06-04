import 'package:hive/hive.dart';
import '../models/expense.dart';
import '../../core/constants/hive_boxes.dart';

class ExpenseRepository {
  Box<Expense> get _box => Hive.box<Expense>(HiveBoxes.expenses);

  void add(Expense expense) => _box.put(expense.id, expense);

  void delete(String id) => _box.delete(id);

  List<Expense> getAll() {
    return _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Expense> getByMonth(int year, int month) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    return _box.values
        .where((e) => !e.date.isBefore(start) && e.date.isBefore(end))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double totalByMonth(int year, int month) =>
      getByMonth(year, month).fold(0.0, (s, e) => s + e.amount);

  Map<String, double> totalByCategoryForMonth(int year, int month) {
    final result = <String, double>{};
    for (final e in getByMonth(year, month)) {
      result[e.categoryId] = (result[e.categoryId] ?? 0) + e.amount;
    }
    return result;
  }

  Map<int, double> totalByDayForMonth(int year, int month) {
    final result = <int, double>{};
    for (final e in getByMonth(year, month)) {
      result[e.date.day] = (result[e.date.day] ?? 0) + e.amount;
    }
    return result;
  }
}
