import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ShopProductCategorySelector extends StatelessWidget {
  final String category;
  final String subCategory;
  final Function(String, String) onCategorySelected;

  const ShopProductCategorySelector({
    super.key,
    required this.category,
    required this.subCategory,
    required this.onCategorySelected,
  });

  void _showCategoryPicker(BuildContext context) {
    // Hardcoded dummy categories for local state
    final categories = {
      'Grocery': ['Dairy', 'Rice & Grains', 'Vegetables', 'Cooking Essentials'],
      'Electronics': ['Mobiles', 'Accessories', 'Laptops'],
      'Fashion': ['Men', 'Women', 'Kids'],
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Select Category',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: categories.keys.length,
                    itemBuilder: (context, index) {
                      final cat = categories.keys.elementAt(index);
                      final subs = categories[cat]!;
                      return Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: const Color(0xFF2563EB),
                          collapsedIconColor: const Color(0xFF6B7280),
                          title: Text(
                            cat,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: cat == category ? const Color(0xFF2563EB) : AppColors.primaryText,
                            ),
                          ),
                          children: subs.map((sub) {
                            final isSelected = cat == category && sub == subCategory;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 40),
                              title: Text(
                                sub,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF4B5563),
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 20)
                                  : null,
                              onTap: () {
                                onCategorySelected(cat, sub);
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showCategoryPicker(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.category_rounded, color: Color(0xFF2563EB), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.isEmpty ? 'Select Category' : category,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                      if (subCategory.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subCategory,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
