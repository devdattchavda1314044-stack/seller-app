import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Clean, minimal dashboard header with profile, title, and settings.
class StartupDashboardHeader extends StatelessWidget {
  final String title;

  const StartupDashboardHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Row(
            children: [
              // Left — Small Profile Avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.secondaryText,
                  size: 18,
                ),
              ),

              // Center — Seller Name
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Right — Small Settings Icon with adequate touch target
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: AppColors.secondaryText,
                    size: 21,
                  ),
                  splashRadius: 20,
                ),
              ),
            ],
          ),
        ),

        // Light divider below header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          height: 1.0,
          color: const Color(0xFFF0F0F0),
        ),
      ],
    );
  }
}
