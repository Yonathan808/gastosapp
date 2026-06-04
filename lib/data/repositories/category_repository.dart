import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';
import '../../core/constants/hive_boxes.dart';

class CategoryRepository {
  Box<Category> get _box => Hive.box<Category>(HiveBoxes.categories);

  List<Category> getAll() {
    return _box.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  void seedIfEmpty() {
    if (_box.isNotEmpty) return;

    const seed = [
      ('comida',          'Comida',          0xFFFF7043),
      ('transporte',      'Transporte',      0xFF42A5F5),
      ('ropa',            'Ropa',            0xFFEC407A),
      ('salud',           'Salud',           0xFFEF5350),
      ('entretenimiento', 'Entretenimiento', 0xFFAB47BC),
      ('hogar',           'Hogar',           0xFF26A69A),
      ('educacion',       'Educación',       0xFF5C6BC0),
      ('otros',           'Otros',           0xFF78909C),
    ];

    for (int i = 0; i < seed.length; i++) {
      final (id, name, color) = seed[i];
      _box.put(id, Category(
        id: id, name: name, iconName: id,
        colorValue: color, isDefault: true, sortOrder: i,
      ));
    }
  }

  static IconData iconFor(String name) => switch (name) {
    'comida'          => Icons.restaurant_rounded,
    'transporte'      => Icons.directions_car_rounded,
    'ropa'            => Icons.shopping_bag_rounded,
    'salud'           => Icons.favorite_rounded,
    'entretenimiento' => Icons.music_note_rounded,
    'hogar'           => Icons.home_rounded,
    'educacion'       => Icons.school_rounded,
    _                 => Icons.more_horiz_rounded,
  };
}
