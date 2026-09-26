import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Horizontally scrolling segmented filter system with a sliding active indicator.
class SellerProductFilters extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const SellerProductFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  static const List<_FilterDef> _filters = [
    _FilterDef('All', Icons.grid_view_rounded),
    _FilterDef('Active', Icons.check_circle_outline),
    _FilterDef('Inactive', Icons.pause_circle_outline),
    _FilterDef('Offers', Icons.local_offer_outlined),
    _FilterDef('No Offers', Icons.money_off_outlined),
    _FilterDef('Low Stock', Icons.inventory_outlined),
    _FilterDef('High Rated', Icons.star_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // The filter track
          SizedBox(
            height: 42,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter.label == selectedFilter;

                return Padding(
                  padding: EdgeInsets.only(right: index < _filters.length - 1 ? 6 : 0),
                  child: GestureDetector(
                    onTap: () => onFilterChanged(filter.label),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E3A5F) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            filter.icon,
                            size: 15,
                            color: isSelected ? Colors.white : AppColors.secondaryText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            filter.label,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.secondaryText,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Subtle bottom edge
          const SizedBox(height: 10),
          Container(
            height: 1,
            color: const Color(0xFFF0F1F3),
          ),
        ],
      ),
    );
  }
}

class _FilterDef {
  final String label;
  final IconData icon;
  const _FilterDef(this.label, this.icon);
}
