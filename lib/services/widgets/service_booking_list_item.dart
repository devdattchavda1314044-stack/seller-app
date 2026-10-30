import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../models/service_booking_model.dart';
import 'booking_status_chip.dart';
import 'service_booking_details_sheet.dart';

/// One booking in the seller's list.
///
/// Leads with the arrival window rather than the price. A shop order is a
/// basket the seller packs whenever; a booking is an appointment, and the only
/// question that matters at a glance is when someone has to be somewhere.
class ServiceBookingListItem extends StatelessWidget {
  final SellerBooking booking;

  /// Move the booking to `booking.status.next`. The parent owns this because
  /// confirming into [BookingStatus.assigned] needs a professional's name,
  /// which is a prompt, not a swipe.
  final VoidCallback onAdvance;

  final VoidCallback onReject;

  /// Whether intake is on. Mirrors the shop module: with it off, swipe
  /// actions are inert and explain themselves instead of failing silently.
  final bool isAccepting;
  final VoidCallback onDisabledSwipe;

  const ServiceBookingListItem({
    super.key,
    required this.booking,
    required this.onAdvance,
    required this.onReject,
    required this.isAccepting,
    required this.onDisabledSwipe,
  });

  /// Swipe is only worth offering while there is a move left to make.
  bool get _hasActions => booking.status.next != null;

  @override
  Widget build(BuildContext context) {
    final bool slidable = isAccepting && _hasActions;
    final bool canReject = booking.status.canCancel;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (!isAccepting &&
                _hasActions &&
                details.primaryDelta != null &&
                details.primaryDelta! < -2) {
              onDisabledSwipe();
            }
          },
          child: Slidable(
            enabled: slidable,
            key: ValueKey(booking.id),
            endActionPane: ActionPane(
              motion: const BehindMotion(),
              extentRatio: canReject ? 0.40 : 0.26,
              children: [
                CustomSlidableAction(
                  onPressed: (_) => onAdvance(),
                  backgroundColor: AppTokens.success,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        booking.status.next?.icon ?? Icons.check_circle_outline,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.status.advanceLabel ?? 'Next',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canReject)
                  CustomSlidableAction(
                    onPressed: (_) => onReject(),
                    backgroundColor: AppTokens.danger,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel_outlined,
                            color: Colors.white, size: 22),
                        SizedBox(height: 4),
                        Text(
                          'Reject',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: booking.isEmergency
                      ? AppTokens.closedBorder
                      : AppTokens.border,
                  width: 1.0,
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row: status + emergency flag, then total ──
                  Row(
                    children: [
                      BookingStatusChip(status: booking.status, compact: true),
                      if (booking.isEmergency) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTokens.dangerSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt_rounded,
                                  size: 11, color: AppTokens.danger),
                              SizedBox(width: 2),
                              Text(
                                'Emergency',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTokens.danger,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        '${booking.currency}${booking.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── The job: category glyph + title + reference ──
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: booking.status.softColor,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.handyman_outlined,
                          size: 17,
                          color: booking.status.color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              booking.serviceTitle,
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
                            const SizedBox(height: 1),
                            Text(
                              '${booking.categoryName} • ${booking.id}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11.5,
                                color: AppColors.secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── The appointment: day + arrival window ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTokens.fieldFill,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_outlined,
                            size: 14, color: AppColors.secondaryText),
                        const SizedBox(width: 6),
                        Text(
                          booking.scheduledDayLabel(),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 12,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: AppTokens.borderField,
                        ),
                        const Icon(Icons.access_time_rounded,
                            size: 14, color: AppColors.secondaryText),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            booking.slot.label,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Bottom row: customer + Details ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppTokens.divider,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person_outline_rounded,
                            size: 16, color: AppColors.secondaryText),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              booking.customerName,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              booking.customerPhone,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            barrierColor: Colors.black.withValues(alpha: 0.5),
                            builder: (context) => ServiceBookingDetailsSheet(
                              booking: booking,
                              isAccepting: isAccepting,
                              onAdvance: onAdvance,
                              onReject: onReject,
                              onDisabledAction: onDisabledSwipe,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTokens.actionSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Details',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTokens.action,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Who is doing it, once someone is allocated ──
                  if (booking.assignedProfessional != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined,
                            size: 13, color: AppColors.secondaryText),
                        const SizedBox(width: 6),
                        Text(
                          'Assigned to ${booking.assignedProfessional}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
