import 'package:flutter/material.dart';

class NumPadWidget extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onTripleZero;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  const NumPadWidget({
    super.key,
    required this.onDigit,
    required this.onTripleZero,
    required this.onBackspace,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(context, ['1', '2', '3']),
        const SizedBox(height: 4),
        _row(context, ['4', '5', '6']),
        const SizedBox(height: 4),
        _row(context, ['7', '8', '9']),
        const SizedBox(height: 4),
        Row(
          children: [
            _key(context, label: '000', onTap: onTripleZero),
            const SizedBox(width: 4),
            _key(context, label: '0', onTap: () => onDigit('0')),
            const SizedBox(width: 4),
            _key(context, icon: Icons.backspace_outlined, onTap: onBackspace, onLongPress: onClear),
          ],
        ),
      ],
    );
  }

  Widget _row(BuildContext context, List<String> digits) {
    return Row(
      children: [
        for (int i = 0; i < digits.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          _key(context, label: digits[i], onTap: () => onDigit(digits[i])),
        ]
      ],
    );
  }

  Widget _key(
    BuildContext context, {
    String? label,
    IconData? icon,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 58,
            child: Center(
              child: label != null
                  ? Text(
                      label,
                      style: TextStyle(
                        fontSize: label.length > 1 ? 18 : 22,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurface,
                      ),
                    )
                  : Icon(icon, size: 22, color: scheme.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}
