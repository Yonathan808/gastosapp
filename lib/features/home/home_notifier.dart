import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/expense.dart';
import '../../providers/providers.dart' hide triggerRefresh;

class HomeFormState {
  final String amountString;
  final String? categoryId;
  final String? note;
  final bool justSaved;

  const HomeFormState({
    this.amountString = '0',
    this.categoryId,
    this.note,
    this.justSaved = false,
  });

  double get amount => double.tryParse(amountString) ?? 0;
  bool get canSave => amount > 0 && categoryId != null;

  HomeFormState copyWith({
    String? amountString,
    String? categoryId,
    String? note,
    bool? justSaved,
    bool clearNote = false,
  }) =>
      HomeFormState(
        amountString: amountString ?? this.amountString,
        categoryId: categoryId ?? this.categoryId,
        note: clearNote ? null : (note ?? this.note),
        justSaved: justSaved ?? this.justSaved,
      );
}

class HomeNotifier extends Notifier<HomeFormState> {
  @override
  HomeFormState build() {
    final cats = ref.read(categoriesProvider);
    return HomeFormState(categoryId: cats.isNotEmpty ? cats.first.id : null);
  }

  void appendDigit(String digit) {
    final current = state.amountString == '0' ? '' : state.amountString;
    if ('$current$digit'.length > 10) return;
    state = state.copyWith(amountString: '$current$digit');
  }

  void appendTripleZero() {
    final current = state.amountString == '0' ? '' : state.amountString;
    if ('${current}000'.length > 10) return;
    final next = current.isEmpty ? '0' : '${current}000';
    state = state.copyWith(amountString: next);
  }

  void backspace() {
    if (state.amountString.length <= 1) {
      state = state.copyWith(amountString: '0');
    } else {
      state = state.copyWith(
        amountString: state.amountString.substring(0, state.amountString.length - 1),
      );
    }
  }

  void selectCategory(String id) => state = state.copyWith(categoryId: id);

  void clearAmount() => state = state.copyWith(amountString: '0');

  void setNote(String? text) =>
      state = state.copyWith(note: text, clearNote: text == null || text.isEmpty);

  void save() {
    if (!state.canSave) return;
    final expense = Expense(
      id: const Uuid().v4(),
      amount: state.amount,
      categoryId: state.categoryId!,
      date: DateTime.now(),
      note: state.note?.isNotEmpty == true ? state.note : null,
      createdAt: DateTime.now(),
    );
    ref.read(expenseRepoProvider).add(expense);
    ref.read(refreshProvider.notifier).update((n) => n + 1);
    final cats = ref.read(categoriesProvider);
    state = HomeFormState(
      categoryId: cats.isNotEmpty ? cats.first.id : null,
      justSaved: true,
    );
    // Reset justSaved after short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (state.justSaved) state = state.copyWith(justSaved: false);
    });
  }
}

final homeNotifierProvider =
    NotifierProvider<HomeNotifier, HomeFormState>(HomeNotifier.new);
