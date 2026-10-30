import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// A tab that is wired up but not built yet.
///
/// Says plainly what will live here rather than showing mock content, so a
/// demo cannot mistake an unbuilt tab for a finished one.
class ServicesPlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final String headline;
  final String detail;

  /// What this tab will do, once built. Listed so the gap is legible to
  /// whoever picks the work up.
  final List<String> planned;

  const ServicesPlaceholderTab({
    super.key,
    required this.title,
    required this.icon,
    required this.headline,
    required this.detail,
    this.planned = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTokens.divider,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Text(
                      'Not built yet',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppTokens.dividerStrong),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(28, 48, 28, 40),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTokens.fieldFill,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        size: 34,
                        color: AppTokens.faintText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      headline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detail,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.secondaryText,
                        height: 1.5,
                      ),
                    ),

                    if (planned.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTokens.fieldFill,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTokens.borderField,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PLANNED',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryText,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...planned.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 7),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.only(
                                        top: 7,
                                        right: 9,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: AppTokens.faintText,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12.5,
                                          color: AppColors.primaryText,
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
