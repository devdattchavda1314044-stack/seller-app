import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ShopProductPricingSection extends StatelessWidget {
  final TextEditingController oldPriceController;
  final TextEditingController newPriceController;
  final double? discountPercent;

  const ShopProductPricingSection({
    super.key,
    required this.oldPriceController,
    required this.newPriceController,
    this.discountPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pricing',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            if (discountPercent != null && discountPercent! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${discountPercent!.toStringAsFixed(0)}% OFF',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPriceField(
                label: 'Old Price',
                controller: oldPriceController,
                isPrimary: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPriceField(
                label: 'New Price (Selling)',
                controller: newPriceController,
                isPrimary: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceField({
    required String label,
    required TextEditingController controller,
    required bool isPrimary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
            color: isPrimary ? AppColors.primaryText : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isPrimary ? 16 : 14,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
            color: AppColors.primaryText,
            decoration: !isPrimary ? TextDecoration.lineThrough : null,
          ),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isPrimary ? 16 : 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: isPrimary ? Colors.white : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isPrimary ? const Color(0xFF2563EB).withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isPrimary ? const Color(0xFF2563EB).withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
