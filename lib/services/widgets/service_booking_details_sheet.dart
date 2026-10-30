import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../models/service_booking_model.dart';
import 'booking_status_chip.dart';

/// Everything about one booking, plus the single move the seller can make next.
///
/// The sheet shows one primary action rather than a row of stage buttons: the
/// lifecycle is a line, and a seller who can jump from "requested" straight to
/// "completed" produces a timeline the customer cannot read.
class ServiceBookingDetailsSheet extends StatelessWidget {
  final SellerBooking booking;
  final bool isAccepting;
  final VoidCallback onAdvance;
  final VoidCallback onReject;
  final VoidCallback onDisabledAction;

  const ServiceBookingDetailsSheet({
    super.key,
    required this.booking,
    required this.isAccepting,
    required this.onAdvance,
    required this.onReject,
    required this.onDisabledAction,
  });

  @override
  Widget build(BuildContext context) {
    final BookingStatus? next = booking.status.next;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTokens.faintText,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title row — reference is the one thing a caller reads out
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Booking Details',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          booking.id,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BookingStatusChip(status: booking.status),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: AppTokens.divider),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── THE JOB ──
                    _sectionLabel('Service'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            booking.serviceTitle,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (booking.isEmergency)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTokens.dangerSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Emergency',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppTokens.danger,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      booking.categoryName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.secondaryText,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── THE APPOINTMENT ──
                    _sectionLabel('Appointment'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTokens.fieldFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _detailRow(
                            Icons.event_outlined,
                            'Date',
                            booking.scheduledDayLabel(),
                          ),
                          const SizedBox(height: 10),
                          _detailRow(
                            Icons.access_time_rounded,
                            'Arrival window',
                            booking.slot.label,
                          ),
                          if (booking.assignedProfessional != null) ...[
                            const SizedBox(height: 10),
                            _detailRow(
                              Icons.badge_outlined,
                              'Professional',
                              booking.assignedProfessional!,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── CUSTOMER ──
                    _sectionLabel('Customer'),
                    const SizedBox(height: 8),
                    Text(
                      booking.customerName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Text(
                      booking.customerPhone,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 15, color: AppColors.secondaryText),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            booking.address,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.secondaryText,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (booking.notes != null &&
                        booking.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _sectionLabel('Customer note'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTokens.warningSoft,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTokens.warningBorder,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          booking.notes!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppTokens.warningText,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ── MONEY ──
                    _sectionLabel('Payment'),
                    const SizedBox(height: 8),
                    _priceRow('Service', booking.basePrice, booking.currency),
                    if (booking.visitFee > 0) ...[
                      const SizedBox(height: 6),
                      _priceRow(
                        'Visit / call-out fee',
                        booking.visitFee,
                        booking.currency,
                      ),
                    ],
                    if (booking.discount > 0) ...[
                      const SizedBox(height: 6),
                      _priceRow(
                        'Discount',
                        -booking.discount,
                        booking.currency,
                        valueColor: AppTokens.success,
                      ),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: AppTokens.divider,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        Text(
                          '${booking.currency}${booking.total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // ── LIFECYCLE ──
                    _sectionLabel('Progress'),
                    const SizedBox(height: 12),
                    BookingTimeline(booking: booking),
                  ],
                ),
              ),
            ),

            // ── ACTION BAR ──
            if (next != null)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppTokens.divider, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    if (booking.status.canCancel) ...[
                      Expanded(
                        child: _actionButton(
                          label: 'Reject',
                          icon: Icons.cancel_outlined,
                          background: AppTokens.destructiveSoft,
                          foreground: AppTokens.danger,
                          onTap: () {
                            if (!isAccepting) {
                              onDisabledAction();
                              return;
                            }
                            Navigator.of(context).pop();
                            onReject();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      flex: booking.status.canCancel ? 1 : 2,
                      child: _actionButton(
                        label: booking.status.advanceLabel ?? 'Next',
                        icon: next.icon,
                        background: isAccepting
                            ? AppTokens.success
                            : AppTokens.faintText,
                        foreground: Colors.white,
                        onTap: () {
                          if (!isAccepting) {
                            onDisabledAction();
                            return;
                          }
                          Navigator.of(context).pop();
                          onAdvance();
                        },
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

  // ─────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.secondaryText,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.secondaryText),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.5,
            color: AppColors.secondaryText,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _priceRow(
    String label,
    double amount,
    String currency, {
    Color? valueColor,
  }) {
    final String sign = amount < 0 ? '-' : '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          '$sign$currency${amount.abs().toStringAsFixed(0)}',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
