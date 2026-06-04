import 'package:intl/intl.dart';

extension CopFormatter on num {
  String toCOP() {
    return NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    ).format(this);
  }

  String toCOPShort() {
    if (this >= 1000000) return '\$${(this / 1000000).toStringAsFixed(1)}M';
    if (this >= 1000) return '\$${(this / 1000).toStringAsFixed(0)}K';
    return toCOP();
  }
}
