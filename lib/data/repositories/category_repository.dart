import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';
import '../../core/constants/hive_boxes.dart';

const _seed = [
  ('comida',      'Comida',       0xFFFF7043, 0),
  ('transporte',  'Transporte',   0xFF42A5F5, 1),
  ('galgueria',   'Galguería',    0xFFFFB300, 2),
  ('compras',     'Compras',      0xFF7C4DFF, 3),
  ('plataformas', 'Plataformas',  0xFF00BCD4, 4),
  ('prestamos',   'Préstamos',    0xFFEF5350, 5),
  ('ropa',        'Ropa',         0xFFEC407A, 6),
  ('otros',       'Otros',        0xFF78909C, 7),
];

class CategoryRepository {
  Box<Category> get _box => Hive.box<Category>(HiveBoxes.categories);

  List<Category> getAll() {
    return _box.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  void seedIfEmpty() {
    if (_box.isNotEmpty) return;
    _seedAll();
  }

  // Removes categories from v1 (salud, entretenimiento, hogar, educacion)
  // and replaces them with the new set, preserving existing ids.
  void migrateCategories() {
    const oldIds = ['salud', 'entretenimiento', 'hogar', 'educacion'];
    final needsMigration = oldIds.any((id) => _box.containsKey(id));
    if (!needsMigration) return;

    for (final id in oldIds) {
      _box.delete(id);
    }
    _seedAll();
  }

  void _seedAll() {
    for (final (id, name, color, order) in _seed) {
      if (!_box.containsKey(id)) {
        _box.put(id, Category(
          id: id, name: name, iconName: id,
          colorValue: color, isDefault: true, sortOrder: order,
        ));
      } else {
        // Fix sort order if it changed
        final existing = _box.get(id)!;
        if (existing.sortOrder != order) {
          _box.put(id, Category(
            id: existing.id, name: existing.name, iconName: existing.iconName,
            colorValue: existing.colorValue, isDefault: existing.isDefault,
            sortOrder: order,
          ));
        }
      }
    }
  }

  static IconData iconFor(String name) => switch (name) {
    'comida'      => Icons.restaurant_rounded,
    'transporte'  => Icons.directions_car_rounded,
    'galgueria'   => Icons.icecream_rounded,
    'compras'     => Icons.shopping_cart_rounded,
    'plataformas' => Icons.subscriptions_rounded,
    'prestamos'   => Icons.payments_rounded,
    'ropa'        => Icons.shopping_bag_rounded,
    _             => Icons.more_horiz_rounded,
  };
}
