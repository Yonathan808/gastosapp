import 'package:intl/intl.dart';

extension CopFormatter on num {
  String toCOP() {
    final n = NumberFormat('#,##0', 'es_CO');
    return '\$ ${n.format(this)}';
  }

  String toCOPShort() {
    if (this >= 1000000) return '\$ ${(this / 1000000).toStringAsFixed(1)}M';
    if (this >= 1000) return '\$ ${(this / 1000).toStringAsFixed(0)}K';
    return toCOP();
  }
}
