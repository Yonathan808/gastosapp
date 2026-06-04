import 'package:hive/hive.dart';

class CategoryBudget {
  final String id; // "$categoryId-2026-05"
  final String categoryId;
  final String monthKey;
  final double limit;

  const CategoryBudget({
    required this.id,
    required this.categoryId,
    required this.monthKey,
    required this.limit,
  });
}

class CategoryBudgetAdapter extends TypeAdapter<CategoryBudget> {
  @override
  final int typeId = 3;

  @override
  CategoryBudget read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return CategoryBudget(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      monthKey: fields[2] as String,
      limit: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryBudget obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.monthKey)
      ..writeByte(3)
      ..write(obj.limit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryBudgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
