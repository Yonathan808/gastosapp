import 'package:flutter/material.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/category_repository.dart';

class CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final String? selectedId;
  final void Function(String) onSelect;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 78,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return _CategoryItem(
          category: cat,
          isSelected: cat.id == selectedId,
          onTap: () => onSelect(cat.id),
        );
      },
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final catColor = Color(category.colorValue);
    final icon = CategoryRepository.iconFor(category.iconName);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: isSelected
                  ? catColor.withValues(alpha: 0.18)
                  : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: isSelected
                  ? Border.all(color: catColor.withValues(alpha: 0.6), width: 1.5)
                  : null,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected
                  ? catColor
                  : scheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _shortName(category.name),
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? catColor
                  : scheme.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _shortName(String name) =>
      name.length > 8 ? '${name.substring(0, 7)}.' : name;
}
