import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../models/service_listing_model.dart';

/// One service in the seller's list, expanding to its full terms.
///
/// Where the shop's product row opens onto an image slider, this opens onto
/// what the quoted price includes, excludes and requires. Services ship no
/// photography — the customer app renders a category glyph — so the panel that
/// earns the space is the one that stops an argument on the doorstep.
class ServiceListingListItem extends StatelessWidget {
  final ServiceListing service;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleStatus;

  const ServiceListingListItem({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected ? AppTokens.surfaceSelected : AppTokens.surface,
        border: isSelected
            ? Border.all(
                color: AppTokens.action.withValues(alpha: 0.3),
                width: 1.0,
              )
            : null,
        borderRadius:
            isSelected ? BorderRadius.circular(AppTokens.radiusRow) : null,
      ),
      margin: isSelected
          ? const EdgeInsets.symmetric(vertical: 4)
          : EdgeInsets.zero,
      child: Column(
        children: [
          // ── Collapsed summary row ──
          //
          // Paused listings dim the whole row, the way Shop dims an inactive
          // product, rather than greying the title alone — one rule the reader
          // learns once instead of two that look like a rendering bug.
          Opacity(
            opacity: service.isActive ? 1.0 : 0.45,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Category glyph — the same mark the customer app draws
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTokens.tile,
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusChip),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      service.icon,
                      size: 24,
                      color: AppTokens.action,
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                service.title,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText,
                                  height: 1.25,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (service.isEmergency) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.bolt_rounded,
                                size: 15,
                                color: AppTokens.destructive,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${service.category} · ${service.subCategory}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.5,
                            color: AppColors.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Price, duration, availability — the three numbers a
                        // customer decides on
                        Row(
                          children: [
                            Text(
                              'From ${service.currency}'
                              '${service.startingPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                              ),
                            ),
                            if (service.hasDiscount) ...[
                              const SizedBox(width: 6),
                              Text(
                                '${service.currency}'
                                '${service.originalPrice!.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11.5,
                                  color: AppTokens.mutedText,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTokens.successSoft,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '${service.discountPercent}% off',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppTokens.successText,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: AppColors.secondaryText,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                service.durationLabel,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11.5,
                                  color: AppColors.secondaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isSelected ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),

          // ── Expanded detail ──
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeOutCubic,
            sizeCurve: Curves.easeOutCubic,
            crossFadeState: isSelected
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildExpandedContent(),
            secondChild: const SizedBox(width: double.infinity),
          ),

          if (!isSelected)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 1,
              color: AppTokens.divider,
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Availability promise ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: service.availability == ServiceAvailability.now
                  ? AppTokens.openFill
                  : AppTokens.fieldFill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  service.availability == ServiceAvailability.now
                      ? Icons.flash_on_rounded
                      : Icons.event_outlined,
                  size: 15,
                  color: service.availability == ServiceAvailability.now
                      ? AppTokens.successStrong
                      : AppColors.secondaryText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        service.availability.label,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: service.availability == ServiceAvailability.now
                              ? AppTokens.successText
                              : AppColors.primaryText,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        service.availability.detail,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.secondaryText,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ── Metadata grid — 2x2 ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppTokens.surfaceSunken,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetadataCell(
                          icon: Icons.event_note_outlined,
                          iconColor: AppTokens.action,
                          label: 'Bookings',
                          value: '${service.bookingsReceived}',
                        ),
                      ),
                      Container(width: 1, color: AppTokens.divider),
                      Expanded(
                        child: _MetadataCell(
                          icon: Icons.star_rounded,
                          iconColor: AppTokens.warning,
                          label: 'Rating',
                          value: service.reviewsCount == 0
                              ? 'New'
                              : '${service.rating.toStringAsFixed(1)} '
                                  '(${service.reviewsCount})',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: AppTokens.divider),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetadataCell(
                          icon: service.isActive
                              ? Icons.check_circle_outline
                              : Icons.pause_circle_outline,
                          iconColor: service.isActive
                              ? AppTokens.success
                              : AppTokens.danger,
                          label: 'Status',
                          value: service.isActive ? 'Active' : 'Paused',
                        ),
                      ),
                      Container(width: 1, color: AppTokens.divider),
                      Expanded(
                        child: _MetadataCell(
                          icon: Icons.directions_car_outlined,
                          iconColor: service.visitFee > 0
                              ? AppTokens.earnings
                              : AppTokens.mutedText,
                          label: 'Visit fee',
                          value: service.visitFee > 0
                              ? '${service.currency}'
                                  '${service.visitFee.toStringAsFixed(0)}'
                              : 'None',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── The terms, which is what a services listing really is ──
        if (service.inclusions.isNotEmpty)
          _buildTermsBlock(
            title: 'Includes',
            icon: Icons.check_rounded,
            color: AppTokens.successStrong,
            items: service.inclusions,
          ),
        if (service.exclusions.isNotEmpty)
          _buildTermsBlock(
            title: 'Not included',
            icon: Icons.close_rounded,
            color: AppTokens.destructive,
            items: service.exclusions,
          ),
        if (service.requirements.isNotEmpty)
          _buildTermsBlock(
            title: 'Customer must have ready',
            icon: Icons.info_outline_rounded,
            color: AppTokens.warningText,
            items: service.requirements,
          ),

        const SizedBox(height: 16),

        // ── Contextual actions ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: _ActionButton(
                  onTap: () => onToggleStatus(!service.isActive),
                  icon: service.isActive
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  label: service.isActive ? 'Pause' : 'Activate',
                  color: service.isActive
                      ? AppTokens.danger
                      : AppTokens.success,
                  bgColor: service.isActive
                      ? AppTokens.destructiveSoft
                      : AppTokens.openFill,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  onTap: onEdit,
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  color: AppTokens.action,
                  bgColor: AppTokens.actionTile,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  onTap: onDelete,
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  color: AppTokens.destructive,
                  bgColor: AppTokens.destructiveSoft,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsBlock({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 7),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1.5),
                    child: Icon(icon, size: 13, color: color),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        color: AppColors.primaryText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Metadata cell inside the 2x2 grid ───
class _MetadataCell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _MetadataCell({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contextual action button ───
class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
