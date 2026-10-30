import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../models/seller_profile_model.dart';

/// Professional bottom navigation with active pill indicator.
class ShopBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const ShopBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SellerProfile>(
      valueListenable: SellerProfileProvider().profileNotifier,
      builder: (context, profile, _) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFF0F0F0), width: 1.0),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard', index: 0),
                  _buildNavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2_rounded, label: 'Products', index: 1),
                  _buildNavItem(icon: Icons.play_circle_outline, activeIcon: Icons.play_circle_rounded, label: 'Shots', index: 2),
                  _buildNavItem(icon: Icons.local_offer_outlined, activeIcon: Icons.local_offer_rounded, label: 'Offers', index: 3),
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
      }
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    String? avatarPath,
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
          color: isActive ? const Color(0xFFEBF0FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatarPath != null)
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: avatarPath.startsWith('assets/')
                      ? Image.asset(avatarPath, fit: BoxFit.cover, errorBuilder: (_, _, _) => Icon(isActive ? activeIcon : icon, color: isActive ? AppColors.primary : AppColors.secondaryText, size: 22))
                      : Image.file(File(avatarPath), fit: BoxFit.cover, errorBuilder: (_, _, _) => Icon(isActive ? activeIcon : icon, color: isActive ? AppColors.primary : AppColors.secondaryText, size: 22)),
                ),
              )
            else
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : AppColors.secondaryText,
                size: 22,
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
