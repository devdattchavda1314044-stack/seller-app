import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Filter rail for the services list.
///
/// The filters a services seller actually reaches for differ from a shop's:
/// there is no stock to run low, and "Available now" — the promise that drives
/// the customer's emergency rail — is the one a provider needs to audit before
/// their phone rings.
class ServiceListingFilters extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const ServiceListingFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  static const List<_FilterDef> _filters = [
    _FilterDef('All', Icons.grid_view_rounded),
    _FilterDef('Active', Icons.check_circle_outline),
    _FilterDef('Paused', Icons.pause_circle_outline),
    _FilterDef('Available Now', Icons.flash_on_outlined),
    _FilterDef('Emergency', Icons.bolt_outlined),
    _FilterDef('Discounted', Icons.local_offer_outlined),
    _FilterDef('High Rated', Icons.star_outline_rounded),
  ];

  /// Every label this rail can emit, so the screen's filter switch and the
  /// rail cannot drift apart.
  static List<String> get labels =>
      _filters.map((f) => f.label).toList(growable: false);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 42,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter.label == selectedFilter;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _filters.length - 1 ? 6 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => onFilterChanged(filter.label),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTokens.inkFill
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            filter.icon,
                            size: 15,
                            color: isSelected
                                ? Colors.white
                                : AppColors.secondaryText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            filter.label,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.secondaryText,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),
          Container(height: 1, color: AppTokens.dividerStrong),
        ],
      ),
    );
  }
}

class _FilterDef {
  final String label;
  final IconData icon;
  const _FilterDef(this.label, this.icon);
}
