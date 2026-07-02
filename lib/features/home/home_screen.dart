import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/providers.dart';
import 'home_notifier.dart';
import 'widgets/amount_display.dart';
import 'widgets/category_selector.dart';
import 'widgets/monthly_progress_banner.dart';
import 'widgets/numpad_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);
    final categories = ref.watch(categoriesProvider);
    final totalSpent = ref.watch(currentMonthTotalProvider);
    final budget = ref.watch(currentMonthBudgetProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MonthlyProgressBanner(totalSpent: totalSpent, budget: budget),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const Gap(20),
                    // Amount display
                    AmountDisplay(amountString: form.amountString),
                    const Gap(16),
                    // Category selector
                    CategorySelector(
                      categories: categories,
                      selectedId: form.categoryId,
                      onSelect: notifier.selectCategory,
                    ),
                    const Gap(8),
                    // Note button
                    _NoteButton(note: form.note, onTap: () => _showNoteSheet(context, ref, form.note)),
                    const Gap(12),
                    // NumPad
                    Expanded(
                      child: NumPadWidget(
                        onDigit: notifier.appendDigit,
                        onTripleZero: notifier.appendTripleZero,
                        onBackspace: notifier.backspace,
                        onClear: notifier.clearAmount,
                      ),
                    ),
                    const Gap(8),
                    // Save button
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: form.justSaved
                          ? _SavedFeedback(scheme: scheme)
                          : FilledButton(
                              key: const ValueKey('save'),
                              onPressed: form.canSave ? notifier.save : null,
                              child: const Text(AppStrings.save),
                            ),
                    ),
                    const Gap(12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteSheet(BuildContext context, WidgetRef ref, String? currentNote) {
    final controller = TextEditingController(text: currentNote ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16, 20, 16,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nota', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Gap(12),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 2,
              decoration: const InputDecoration(hintText: AppStrings.noteHint),
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(homeNotifierProvider.notifier).setNote(null);
                      Navigator.pop(ctx);
                    },
                    child: const Text(AppStrings.removeNote),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      ref.read(homeNotifierProvider.notifier)
                          .setNote(controller.text.trim());
                      Navigator.pop(ctx);
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

class _NoteButton extends StatelessWidget {
  final String? note;
  final VoidCallback onTap;

  const _NoteButton({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasNote = note != null && note!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              hasNote ? Icons.edit_note_rounded : Icons.add_rounded,
              size: 18,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
            const Gap(8),
            Expanded(
              child: Text(
                hasNote ? note! : AppStrings.addNote,
                style: TextStyle(
                  fontSize: 13,
                  color: hasNote
                      ? scheme.onSurface.withValues(alpha: 0.8)
                      : scheme.onSurface.withValues(alpha: 0.4),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedFeedback extends StatelessWidget {
  final ColorScheme scheme;

  const _SavedFeedback({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('saved'),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.green.shade500.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green.shade500, size: 22),
          const Gap(8),
          Text(
            '¡Gasto guardado!',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.green.shade600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
