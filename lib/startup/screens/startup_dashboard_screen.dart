import 'package:flutter/material.dart';
import '../../core/constants/static_credentials.dart';
import '../widgets/startup_dashboard_header.dart';
import '../../shop/widgets/shop_dashboard_card.dart';
import '../../services/widgets/services_dashboard_card.dart';

class StartupDashboardScreen extends StatelessWidget {
  const StartupDashboardScreen({super.key});

  /// Static mock configuration for testing.
  /// Change this to [StartupBusinessType.services] to switch the 4 cards.
  static const StartupBusinessType _businessType = StartupBusinessType.shop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header always shows "UDUR Startup" regardless of business type.
            const StartupDashboardHeader(title: 'UDUR Startup'),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.15,
                  physics: const BouncingScrollPhysics(),
                  children: _businessType == StartupBusinessType.shop
                      ? shopCards.map((card) => ShopDashboardCard(data: card)).toList()
                      : servicesCards.map((card) => ServicesDashboardCard(data: card)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
