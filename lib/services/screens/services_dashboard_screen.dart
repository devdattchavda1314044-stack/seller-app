import 'package:flutter/material.dart';
import '../widgets/services_dashboard_header.dart';
import '../widgets/services_dashboard_card.dart';

class ServicesDashboardScreen extends StatelessWidget {
  const ServicesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ServicesDashboardHeader(title: 'UDUR Services'),
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
                  children: servicesCards
                      .map((card) => ServicesDashboardCard(data: card))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
