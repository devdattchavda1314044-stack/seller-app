import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Data model for a single services dashboard stat card.
class ServicesDashboardCardData {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color cardColor;
  final Color accentColor;
  /// If true, show a small "Active" dot next to the value.
  final bool showActiveBadge;
  /// Specific font size for the value. Defaults to 36.0.
  final double valueFontSize;

  const ServicesDashboardCardData({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.cardColor,
    required this.accentColor,
    this.showActiveBadge = false,
    this.valueFontSize = 36.0,
  });
}

/// Premium light-filled dashboard card — border, no shadow, compact top-aligned content.
class ServicesDashboardCard extends StatelessWidget {
  final ServicesDashboardCardData data;

  const ServicesDashboardCard({super.key, required this.data});

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
        // ZERO shadow
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Stack(
          children: [
            // Large decorative watermark icon — right side
            Positioned(
              right: -10,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  data.icon,
                  size: 64,
                  // Very low opacity for a subtle watermark
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
                  // Title — large, regular weight, 2 lines max
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 23, // Increased size
                      fontWeight: FontWeight.normal, // REGULAR text
                      color: AppTokens.tertiaryText,
                      letterSpacing: 0.1,
                      height: 1.1, // compact line height
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Flexible space to push the main value to the bottom
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: data.showActiveBadge
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      data.value,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: data.valueFontSize,
                                        fontWeight: FontWeight.w700,
                                        color: data.accentColor,
                                        height: 1.1,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTokens.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                data.value,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: data.valueFontSize,
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

const _softRed = Color(0xFFFFE8EA);
const _accentRed = Color(0xFFD9363E);

const _softOrange = Color(0xFFFFF0DF);
const _accentOrange = Color(0xFFE85D04);

const _softPurple = Color(0xFFF0E9FF);
const _accentPurple = Color(0xFF6D3FC0);

/// Static services cards, kept for the Startup stub.
///
/// The services dashboard builds its own set from the booking store and the
/// listing catalogue, so these fixed numbers are no longer what a services
/// seller sees. `StartupDashboardScreen` still renders them when its business
/// type is Services, and that module has not been built out yet.
const List<ServicesDashboardCardData> servicesCards = [
  ServicesDashboardCardData(
    icon: Icons.check_circle_outline,
    title: 'Active\nServices',
    value: '12',
    subtitle: '',
    cardColor: _softBlue,
    accentColor: _accentBlue,
  ),
  ServicesDashboardCardData(
    icon: Icons.grid_view_rounded,
    title: 'Total\nServices',
    value: '28',
    subtitle: '',
    cardColor: _softRed,
    accentColor: _accentRed,
  ),
  ServicesDashboardCardData(
    icon: Icons.people_outline_rounded,
    title: 'People\nInterested',
    value: '84',
    subtitle: '',
    cardColor: _softOrange,
    accentColor: _accentOrange,
  ),
  ServicesDashboardCardData(
    icon: Icons.workspace_premium_outlined,
    title: 'Current\nPlan',
    value: 'Premium',
    subtitle: '',
    cardColor: _softPurple,
    accentColor: _accentPurple,
    showActiveBadge: true,
    valueFontSize: 24.0,
  ),
];
