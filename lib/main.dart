import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/constants/hive_boxes.dart';
import 'data/models/category.dart';
import 'data/models/category_budget.dart';
import 'data/models/expense.dart';
import 'data/models/monthly_budget.dart';
import 'data/repositories/category_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(MonthlyBudgetAdapter());
  Hive.registerAdapter(CategoryBudgetAdapter());

  await Future.wait([
    Hive.openBox<Expense>(HiveBoxes.expenses),
    Hive.openBox<Category>(HiveBoxes.categories),
    Hive.openBox<MonthlyBudget>(HiveBoxes.monthlyBudgets),
    Hive.openBox<CategoryBudget>(HiveBoxes.categoryBudgets),
  ]);

  CategoryRepository().seedIfEmpty();

  runApp(const ProviderScope(child: GastosApp()));
}
