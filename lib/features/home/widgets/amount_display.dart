import 'package:flutter/material.dart';
import '../../../core/extensions/currency_extension.dart';

class AmountDisplay extends StatelessWidget {
  final String amountString;

  const AmountDisplay({super.key, required this.amountString});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final amount = double.tryParse(amountString) ?? 0;
    final isZero = amount == 0;

    return Text(
      isZero ? '\$ 0' : amount.toCOP(),
      style: TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.bold,
        color: isZero
            ? scheme.onSurface.withValues(alpha: 0.3)
            : scheme.onSurface,
        letterSpacing: -1,
      ),
    );
  }
}
