import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Dashboard header — app identity bar with profile, business name, and actions.
///
/// Same layout as `ShopDashboardHeader`: 40dp avatar on the left, name over a
/// quiet subtitle, then the bell and settings as square tiles. The services
/// version previously centred the title and dropped the bell, which made the
/// two modules read as two different apps on the first screen after login.
/// Only the avatar glyph differs, because a services seller is a tradesperson
/// rather than a storefront.
class ServicesDashboardHeader extends StatelessWidget {
  final String title;

  /// Shown under the name. Defaults to the same words Shop uses.
  final String subtitle;

  const ServicesDashboardHeader({
    super.key,
    required this.title,
    this.subtitle = 'Seller Dashboard',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTokens.surface,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          // Profile avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0F3),
              shape: BoxShape.circle,
              border: Border.all(color: AppTokens.borderField, width: 1.0),
            ),
            child: Icon(
              Icons.handyman_outlined,
              color: AppColors.primary.withValues(alpha: 0.7),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Business name + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Notification bell
          _HeaderIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 4),
          // Settings
          _HeaderIconButton(
            icon: Icons.settings_outlined,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusChip),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppTokens.pageBackground,
          borderRadius: BorderRadius.circular(AppTokens.radiusChip),
          border: Border.all(color: const Color(0xFFEEF0F3), width: 1.0),
        ),
        child: Icon(icon, color: AppColors.secondaryText, size: 20),
      ),
    );
  }
}
