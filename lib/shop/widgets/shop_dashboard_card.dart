import 'package:flutter/material.dart';

/// Legacy data model for shop dashboard stat cards (Used by Startup module).
class ShopDashboardCardData {
  final IconData icon;
  final String title;
  final String value;
  final Color cardColor;
  final Color accentColor;

  const ShopDashboardCardData({
    required this.icon,
    required this.title,
    required this.value,
    required this.cardColor,
    required this.accentColor,
  });
}

/// Legacy dashboard card — border, no shadow, compact top-aligned content.
class ShopDashboardCard extends StatelessWidget {
  final ShopDashboardCardData data;

  const ShopDashboardCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: data.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: data.accentColor.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Stack(
          children: [
            // Decorative watermark icon
            Positioned(
              right: -10,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  data.icon,
                  size: 64,
                  color: data.accentColor.withValues(alpha: 0.12),
                ),
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 14.0, right: 14.0, bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16, // Adjusted for typical shop cards
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF4B5563),
                      letterSpacing: 0.1,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          data.value,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: data.accentColor,
                            height: 1.1,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Soft premium card colors and matching accents
// ──────────────────────────────────────────────────────────────────

const _softBlue = Color(0xFFE8F0FF);
const _accentBlue = Color(0xFF1F4ED8);

const _softGreen = Color(0xFFE6F7F0);
const _accentGreen = Color(0xFF0F766E);

const _softRed = Color(0xFFFFE8EA);
const _accentRed = Color(0xFFD9363E);

const _softOrange = Color(0xFFFFF0DF);
const _accentOrange = Color(0xFFE85D04);

const _softTeal = Color(0xFFE0F2FE);
const _accentTeal = Color(0xFF0369A1);

const _softPurple = Color(0xFFF0E9FF);
const _accentPurple = Color(0xFF6D3FC0);

/// Legacy Shop seller dashboard cards.
const List<ShopDashboardCardData> shopCards = [
  ShopDashboardCardData(
    icon: Icons.shopping_bag_outlined,
    title: 'Total\nOrders',
    value: '24',
    cardColor: _softBlue,
    accentColor: _accentBlue,
  ),
  ShopDashboardCardData(
    icon: Icons.account_balance_wallet_outlined,
    title: 'Total\nEarn',
    value: '₹8,450',
    cardColor: _softGreen,
    accentColor: _accentGreen,
  ),
  ShopDashboardCardData(
    icon: Icons.check_circle_outline,
    title: 'Orders\nAccept',
    value: '18',
    cardColor: _softRed,
    accentColor: _accentRed,
  ),
  ShopDashboardCardData(
    icon: Icons.inventory_2_outlined,
    title: 'Parcel\nHandover',
    value: '12',
    cardColor: _softOrange,
    accentColor: _accentOrange,
  ),
  ShopDashboardCardData(
    icon: Icons.local_shipping_outlined,
    title: 'Successfully\nDelivered',
    value: '10',
    cardColor: _softTeal,
    accentColor: _accentTeal,
  ),
  ShopDashboardCardData(
    icon: Icons.cancel_outlined,
    title: 'Orders\nReject',
    value: '2',
    cardColor: _softPurple,
    accentColor: _accentPurple,
  ),
];
