import 'package:hive/hive.dart';

class MonthlyBudget {
  final String id; // "2026-05"
  final double? overallLimit;
  final DateTime updatedAt;

  const MonthlyBudget({
    required this.id,
    this.overallLimit,
    required this.updatedAt,
  });
}

class MonthlyBudgetAdapter extends TypeAdapter<MonthlyBudget> {
  @override
  final int typeId = 2;

  @override
  MonthlyBudget read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return MonthlyBudget(
      id: fields[0] as String,
      overallLimit: fields[1] as double?,
      updatedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyBudget obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.overallLimit)
      ..writeByte(2)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyBudgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
