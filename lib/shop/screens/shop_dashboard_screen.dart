import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/shop_dashboard_header.dart';
import '../widgets/shop_bottom_nav_bar.dart';
import '../widgets/shop_order_list_item.dart';
import '../models/shop_order_model.dart';
import '../widgets/shop_store_status.dart';
import 'seller_product_list_screen.dart';
import 'shop_shots_screen.dart';
import 'shop_offers_screen.dart';
import 'shop_profile_screen.dart';

class ShopDashboardScreen extends StatefulWidget {
  const ShopDashboardScreen({super.key});

  @override
  State<ShopDashboardScreen> createState() => _ShopDashboardScreenState();
}

class _ShopDashboardScreenState extends State<ShopDashboardScreen> {
  int _selectedIndex = 0;

  late List<ShopOrder> _orders;
  int _acceptedOrdersCount = 0;
  int _rejectedOrdersCount = 0;
  final int _parcelHandoverCount = 0;
  final int _successfullyDeliveredCount = 0;
  bool _storeOpen = true;

  int get _todaysEarns => _orders.fold(0, (sum, order) => sum + order.totalPrice);

  @override
  void initState() {
    super.initState();
    _orders = List.from(initialShopOrders);
  }

  void _onAcceptOrder(int index) {
    setState(() {
      _orders.removeAt(index);
      _acceptedOrdersCount++;
    });
  }

  void _onCancelOrder(int index) {
    setState(() {
      _orders.removeAt(index);
      _rejectedOrdersCount++;
    });
  }

  void _showStoreOffSnackBar() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Store is off. Turn on the store to manage orders.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: _selectedIndex == 0
            ? _buildDashboardContent()
            : _selectedIndex == 1
                ? const SellerProductListScreen()
                : _selectedIndex == 2
                    ? const ShopShotsScreen()
                    : _selectedIndex == 3
                        ? const ShopOffersScreen()
                        : const ShopProfileScreen(),
      ),
      bottomNavigationBar: ShopBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      children: [
        // Fixed header + store status
        const ShopDashboardHeader(title: 'UDUR Shop'),
        const SizedBox(height: 12),
        ShopStoreStatus(
          isOpen: _storeOpen,
          onChanged: (value) => setState(() => _storeOpen = value),
        ),

        // Scrollable content
        Expanded(
          child: Stack(
            children: [
              CustomScrollView(
                physics: _storeOpen
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                slivers: [
                  // ── TODAY'S BUSINESS (Hero Section) ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _buildBusinessHero(),
                    ),
                  ),

                  // ── ORDER PERFORMANCE (Secondary Section) ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: _buildOrderPerformance(),
                    ),
                  ),

                  // ── TODAY'S ORDERS SECTION TITLE ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Today's Orders",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _orders.isEmpty
                                    ? 'No pending orders'
                                    : '${_orders.length} order${_orders.length == 1 ? '' : 's'} pending',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                          // Order count badge
                          if (_orders.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFDE68A), width: 0.5),
                              ),
                              child: Text(
                                '${_orders.length}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ── ORDER LIST ──
                  _orders.isEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                            child: Center(
                              child: Column(
                                children: const [
                                  Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFD1D5DB)),
                                  SizedBox(height: 12),
                                  Text(
                                    'No pending orders',
                                    style: TextStyle(fontFamily: 'Poppins', fontSize: 15, color: Color(0xFF9CA3AF)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final order = _orders[index];
                                return ShopOrderListItem(
                                  order: order,
                                  isStoreOpen: _storeOpen,
                                  onDisabledSwipe: _showStoreOffSnackBar,
                                  onAccept: () => _onAcceptOrder(index),
                                  onCancel: () => _onCancelOrder(index),
                                );
                              },
                              childCount: _orders.length,
                            ),
                          ),
                        ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),

              // Blurred overlay when store is OFF
              if (!_storeOpen)
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.6),
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/closed_store.png',
                          width: 250,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  // TODAY'S BUSINESS — Hero section with two primary KPIs
  // ─────────────────────────────────────────────────────
  Widget _buildBusinessHero() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E9EC), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "TODAY'S BUSINESS",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Two KPI columns
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left — Today's Orders
                  Expanded(
                    child: _buildHeroKPI(
                      icon: Icons.shopping_bag_outlined,
                      iconBgColor: const Color(0xFFEBF0FF),
                      iconColor: const Color(0xFF2563EB),
                      label: "Today's Orders",
                      value: '${_orders.length + _acceptedOrdersCount + _rejectedOrdersCount}',
                    ),
                  ),

                  // Vertical divider
                  Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: const Color(0xFFF3F4F6),
                  ),

                  // Right — Today's Earns
                  Expanded(
                    child: _buildHeroKPI(
                      icon: Icons.account_balance_wallet_outlined,
                      iconBgColor: const Color(0xFFF3EEFF),
                      iconColor: const Color(0xFF7C3AED),
                      label: "Today's Earnings",
                      value: '₹$_todaysEarns',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroKPI({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon circle
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(height: 14),
        // Label
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        // Value — large, prominent
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  // ORDER PERFORMANCE — Grouped secondary metrics
  // ─────────────────────────────────────────────────────
  Widget _buildOrderPerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: const Text(
            'Order Performance',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ),

        // Metrics card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E9EC), width: 1.0),
          ),
          child: Column(
            children: [
              // Top row: Accepted | Rejected
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPerformanceMetric(
                        dotColor: const Color(0xFF22C55E),
                        icon: Icons.check_circle_outline,
                        iconColor: const Color(0xFF22C55E),
                        label: 'Accepted',
                        value: '$_acceptedOrdersCount',
                      ),
                    ),
                    Container(width: 1, color: const Color(0xFFF3F4F6)),
                    Expanded(
                      child: _buildPerformanceMetric(
                        dotColor: const Color(0xFFEF4444),
                        icon: Icons.cancel_outlined,
                        iconColor: const Color(0xFFEF4444),
                        label: 'Rejected',
                        value: '$_rejectedOrdersCount',
                      ),
                    ),
                  ],
                ),
              ),

              // Horizontal divider
              Container(height: 1, color: const Color(0xFFF3F4F6)),

              // Bottom row: Handover | Delivered
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPerformanceMetric(
                        dotColor: const Color(0xFFF97316),
                        icon: Icons.inventory_2_outlined,
                        iconColor: const Color(0xFFF97316),
                        label: 'Handover',
                        value: '$_parcelHandoverCount',
                      ),
                    ),
                    Container(width: 1, color: const Color(0xFFF3F4F6)),
                    Expanded(
                      child: _buildPerformanceMetric(
                        dotColor: const Color(0xFF14B8A6),
                        icon: Icons.local_shipping_outlined,
                        iconColor: const Color(0xFF14B8A6),
                        label: 'Delivered',
                        value: '$_successfullyDeliveredCount',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetric({
    required Color dotColor,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Small semantic icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: dotColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          // Label + value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
