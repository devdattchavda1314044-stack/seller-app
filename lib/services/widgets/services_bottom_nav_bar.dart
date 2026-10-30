import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../models/service_seller_profile_model.dart';

/// Services bottom navigation with an active pill indicator.
///
/// Same five-slot shape as `ShopBottomNavBar`, with Products swapped for
/// Services and Bookings given its own slot: a services seller spends their
/// day on the booking pipeline, not on an inventory list.
class ServicesBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  /// Count on the Bookings tab — open requests awaiting a decision. Zero
  /// hides the badge rather than drawing an empty circle.
  final int pendingRequests;

  const ServicesBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.pendingRequests = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ServiceSellerProfile>(
      valueListenable: ServiceSellerProfileProvider().profileNotifier,
      builder: (context, profile, _) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppTokens.dividerStrong, width: 1.0),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.handyman_outlined,
                    activeIcon: Icons.handyman_rounded,
                    label: 'Services',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.event_note_outlined,
                    activeIcon: Icons.event_note_rounded,
                    label: 'Bookings',
                    index: 2,
                    badgeCount: pendingRequests,
                  ),
                  _buildNavItem(
                    icon: Icons.local_offer_outlined,
                    activeIcon: Icons.local_offer_rounded,
                    label: 'Offers',
                    index: 3,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                    index: 4,
                    avatarPath: profile.profileImage,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    String? avatarPath,
    int badgeCount = 0,
  }) {
    final bool isActive = selectedIndex == index;

    return InkWell(
      onTap: () => onItemSelected(index),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 14.0 : 8.0,
          vertical: 6.0,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppTokens.actionSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 22,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (avatarPath != null)
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isActive ? AppColors.primary : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: avatarPath.startsWith('assets/')
                            ? Image.asset(
                                avatarPath,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  isActive ? activeIcon : icon,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.secondaryText,
                                  size: 22,
                                ),
                              )
                            : Image.file(
                                File(avatarPath),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  isActive ? activeIcon : icon,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.secondaryText,
                                  size: 22,
                                ),
                              ),
                      ),
                    )
                  else
                    Icon(
                      isActive ? activeIcon : icon,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.secondaryText,
                      size: 22,
                    ),

                  // Pending-request count, pinned to the glyph's corner.
                  if (badgeCount > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 16),
                        height: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: AppTokens.danger,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
