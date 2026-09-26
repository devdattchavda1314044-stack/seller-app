import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../models/shop_order_model.dart';

class ShopOrderDetailsSheet extends StatelessWidget {
  final ShopOrder order;
  final bool isStoreOpen;
  final VoidCallback onAccept;
  final VoidCallback onCancel;
  final VoidCallback onDisabledAction;

  const ShopOrderDetailsSheet({
    super.key,
    required this.order,
    required this.isStoreOpen,
    required this.onAccept,
    required this.onCancel,
    required this.onDisabledAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Text(
                'Order Details',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            
            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Details
                    _sectionLabel('Customer Details'),
                    const SizedBox(height: 8),
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Text(
                      order.customerPhone,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Order Information
                    _sectionLabel('Order Information'),
                    const SizedBox(height: 8),
                    Text(
                      '${order.date} • ${order.time}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Products
                    _sectionLabel('Products'),
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFE5E7EB)),
                          bottom: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      child: Column(
                        children: [
                          ...order.products.map((product) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                ),
                                Text(
                                  '×${product.quantity}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    '₹${product.price}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Total Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        Text(
                          '₹${order.totalPrice}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Seller Address
                    _sectionLabel('Seller Address'),
                    const SizedBox(height: 8),
                    Text(
                      order.sellerAddress,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: AppColors.primaryText,
                        height: 1.4,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (!isStoreOpen) {
                                onDisabledAction();
                                return;
                              }
                              Navigator.pop(context);
                              onCancel();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: isStoreOpen ? const Color(0xFFEF4444) : const Color(0xFFD1D5DB),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              foregroundColor: isStoreOpen ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
                            ),
                            icon: const Icon(Icons.cancel_outlined, size: 20),
                            label: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (!isStoreOpen) {
                                onDisabledAction();
                                return;
                              }
                              Navigator.pop(context);
                              onAccept();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isStoreOpen ? const Color(0xFF22C55E) : const Color(0xFFD1D5DB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.check_circle_outline, size: 20),
                            label: const Text(
                              'Accept',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: AppColors.secondaryText,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }
}
