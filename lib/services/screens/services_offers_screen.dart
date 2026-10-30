import 'package:flutter/material.dart';

import '../widgets/services_placeholder_tab.dart';

/// Offers tab — wired into the shell, not built.
///
/// The customer side already models two offer shapes that the shop module has
/// no equivalent for (`ServiceCoupon` and `ServiceBundle` in
/// `udur/lib/services/offers/models/`), so this is not a copy of
/// `ShopOffersScreen` with the words changed.
class ServicesOffersScreen extends StatelessWidget {
  const ServicesOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServicesPlaceholderTab(
      title: 'Offers',
      icon: Icons.local_offer_outlined,
      headline: 'Offers are next',
      detail:
          'Coupons and service bundles will be created and managed here, the '
          'way the shop module handles product offers.',
      planned: [
        'Percentage and flat-rupee coupons, with a validity window',
        'Service bundles — two or more listings sold as one visit',
        'First-booking and repeat-customer offers',
        'Seasonal campaigns, matching the customer app\'s seasonal rail',
      ],
    );
  }
}
