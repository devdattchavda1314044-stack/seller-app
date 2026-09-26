import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../models/seller_product_model.dart';
import 'seller_product_image_slider.dart';

/// Dense accordion-style product inventory item.
///
/// **Collapsed (default):** Compact 72px row — thumbnail, name, price, status dot.
/// **Expanded (selected):** Full image slider, metadata grid, contextual actions.
class SellerProductListItem extends StatelessWidget {
  final SellerProduct product;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleStatus;

  const SellerProductListItem({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF8FAFF) : Colors.white,
          border: isSelected
              ? Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3), width: 1.0)
              : null,
          borderRadius: isSelected ? BorderRadius.circular(14) : null,
        ),
        margin: isSelected ? const EdgeInsets.symmetric(horizontal: 0, vertical: 4) : EdgeInsets.zero,
        child: Column(
          children: [
            // ─── COLLAPSED ROW (always visible) ───
            Opacity(
              opacity: product.isActive ? 1.0 : 0.45,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    // Compact thumbnail
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: product.images.isNotEmpty
                            ? Image.asset(product.images.first, fit: BoxFit.cover)
                            : const Icon(Icons.image, color: Color(0xFFBFC4CE)),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Name + category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                              height: 1.25,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${product.category} · ${product.subCategory}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondaryText,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Price column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${product.newPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${product.oldPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondaryText,
                            decoration: TextDecoration.lineThrough,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Status dot + chevron
                    Column(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: product.isActive
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFD1D5DB),
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedRotation(
                          turns: isSelected ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ─── EXPANDED DETAIL (only when selected) ───
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: isSelected
                  ? Opacity(
                      opacity: product.isActive ? 1.0 : 0.5,
                      child: _buildExpandedContent(),
                    )
                  : const SizedBox.shrink(),
            ),

            // Divider between items (NOT shown when expanded to avoid double lines)
            if (!isSelected)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F1F3)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      children: [
        // Full-width image slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SellerProductImageSlider(images: product.images),
          ),
        ),
        const SizedBox(height: 16),

        // Metadata grid — 2x2
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Row 1: Orders | Rating
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetadataCell(
                          icon: Icons.shopping_bag_outlined,
                          iconColor: const Color(0xFF2563EB),
                          label: 'Orders',
                          value: '${product.receivedOrders}',
                        ),
                      ),
                      Container(width: 1, color: const Color(0xFFECEDF0)),
                      Expanded(
                        child: _MetadataCell(
                          icon: Icons.star_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          label: 'Rating',
                          value: product.rating.toStringAsFixed(1),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: const Color(0xFFECEDF0)),
                // Row 2: Status | Offer
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetadataCell(
                          icon: product.isActive
                              ? Icons.check_circle_outline
                              : Icons.pause_circle_outline,
                          iconColor: product.isActive
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                          label: 'Status',
                          value: product.isActive ? 'Active' : 'Inactive',
                        ),
                      ),
                      Container(width: 1, color: const Color(0xFFECEDF0)),
                      Expanded(
                        child: _MetadataCell(
                          icon: product.offerAvailable
                              ? Icons.local_offer_outlined
                              : Icons.money_off_outlined,
                          iconColor: product.offerAvailable
                              ? const Color(0xFF059669)
                              : const Color(0xFF9CA3AF),
                          label: 'Offer',
                          value: product.offerAvailable ? 'Active' : 'None',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Contextual actions
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              // Toggle
              Expanded(
                child: _ActionButton(
                  onTap: () => onToggleStatus(!product.isActive),
                  icon: product.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  label: product.isActive ? 'Deactivate' : 'Activate',
                  color: product.isActive ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                  bgColor: product.isActive
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFF0FDF4),
                ),
              ),
              const SizedBox(width: 8),
              // Edit
              Expanded(
                child: _ActionButton(
                  onTap: onEdit,
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 8),
              // Delete
              Expanded(
                child: _ActionButton(
                  onTap: onDelete,
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  color: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEF2F2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Metadata cell inside the 2x2 grid ───
class _MetadataCell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _MetadataCell({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryText,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Contextual action button ───
class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
