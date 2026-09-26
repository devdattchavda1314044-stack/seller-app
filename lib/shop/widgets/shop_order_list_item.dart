import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../core/theme/app_colors.dart';
import '../models/shop_order_model.dart';
import 'shop_order_details_sheet.dart';

/// Professional order list item — time+price top, products middle, customer bottom.
class ShopOrderListItem extends StatelessWidget {
  final ShopOrder order;
  final VoidCallback onAccept;
  final VoidCallback onCancel;
  final bool isStoreOpen;
  final VoidCallback onDisabledSwipe;

  const ShopOrderListItem({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onCancel,
    required this.isStoreOpen,
    required this.onDisabledSwipe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (!isStoreOpen && details.primaryDelta != null && details.primaryDelta! < -2) {
              onDisabledSwipe();
            }
          },
          child: Slidable(
            enabled: isStoreOpen,
            key: ValueKey(order.id),
            endActionPane: ActionPane(
              motion: const BehindMotion(),
              extentRatio: 0.40,
              children: [
                CustomSlidableAction(
                  onPressed: (_) => onAccept(),
                  backgroundColor: const Color(0xFF22C55E),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                      SizedBox(height: 4),
                      Text('Accept', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
                CustomSlidableAction(
                  onPressed: (_) => onCancel(),
                  backgroundColor: const Color(0xFFEF4444),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel_outlined, color: Colors.white, size: 22),
                      SizedBox(height: 4),
                      Text('Cancel', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8E9EC), width: 1.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Time (left) + Total price (right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: AppColors.secondaryText),
                          const SizedBox(width: 5),
                          Text(
                            '${order.date} • ${order.time}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${order.totalPrice}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Product list — compact
                  ...order.products.map((product) => Padding(
                    padding: const EdgeInsets.only(bottom: 3.0),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryText.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${product.name} × ${product.quantity}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '₹${product.price}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 12),

                  // Bottom row: Customer (left) + View Details (right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Customer avatar placeholder
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.secondaryText),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              order.customerName,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              order.customerPhone,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            barrierColor: Colors.black.withValues(alpha: 0.5),
                            builder: (context) => ShopOrderDetailsSheet(
                              order: order,
                              isStoreOpen: isStoreOpen,
                              onAccept: onAccept,
                              onCancel: onCancel,
                              onDisabledAction: onDisabledSwipe,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF0FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Details',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
