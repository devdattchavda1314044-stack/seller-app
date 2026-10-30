import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../models/service_booking_model.dart';

/// Where a booking has reached, as a pill.
class BookingStatusChip extends StatelessWidget {
  final BookingStatus status;
  final bool compact;

  const BookingStatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: status.softColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: status.color.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: compact ? 11 : 13, color: status.color),
          SizedBox(width: compact ? 4 : 6),
          Text(
            status.label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: compact ? 10 : 11.5,
              fontWeight: FontWeight.w600,
              color: status.color,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// The six-step lifecycle, drawn vertically with the booking's own timestamps.
///
/// A cancelled booking is rendered as a single terminal row rather than five
/// green ticks and a red one: cancellation is the work not happening, not a
/// seventh stage of it.
class BookingTimeline extends StatelessWidget {
  final SellerBooking booking;

  const BookingTimeline({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    if (booking.status.isCancelled) {
      return _buildCancelled();
    }

    final int reached = booking.status.stage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < BookingStatus.timeline.length; i++)
          _buildStep(
            status: BookingStatus.timeline[i],
            isDone: BookingStatus.timeline[i].stage <= reached,
            isCurrent: BookingStatus.timeline[i].stage == reached,
            isLast: i == BookingStatus.timeline.length - 1,
          ),
      ],
    );
  }

  Widget _buildCancelled() {
    final BookingEvent? event = _eventFor(BookingStatus.cancelled);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BookingStatus.cancelled.softColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BookingStatus.cancelled.color.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            BookingStatus.cancelled.icon,
            size: 18,
            color: BookingStatus.cancelled.color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  BookingStatus.cancelled.label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: BookingStatus.cancelled.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event?.note ?? BookingStatus.cancelled.detail,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    height: 1.35,
                  ),
                ),
                if (event != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(event.at),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppTokens.mutedText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required BookingStatus status,
    required bool isDone,
    required bool isCurrent,
    required bool isLast,
  }) {
    final BookingEvent? event = _eventFor(status);
    final Color dotColor =
        isDone ? (isCurrent ? status.color : AppTokens.success) : AppTokens.faintText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rail — dot plus the connector down to the next step
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDone ? dotColor.withValues(alpha: 0.12) : AppTokens.divider,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent ? dotColor : Colors.transparent,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                isDone ? Icons.check_rounded : status.icon,
                size: 12,
                color: dotColor,
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: event != null ? 34 : 26,
                color: isDone && !isCurrent
                    ? AppTokens.success.withValues(alpha: 0.35)
                    : AppTokens.borderField,
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Label, plain-language detail, and timestamp once reached
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 10, top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        status.label,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.w500,
                          color: isDone
                              ? AppColors.primaryText
                              : AppTokens.mutedText,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (event != null)
                      Text(
                        _formatTime(event.at),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppTokens.mutedText,
                        ),
                      ),
                  ],
                ),
                if (isCurrent) ...[
                  const SizedBox(height: 2),
                  Text(
                    status.detail,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.5,
                      color: AppColors.secondaryText,
                      height: 1.3,
                    ),
                  ),
                ],
                if (event?.note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    event!.note!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: AppColors.secondaryText,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  BookingEvent? _eventFor(BookingStatus status) {
    for (final event in booking.history.reversed) {
      if (event.status == status) return event;
    }
    return null;
  }

  static String _formatTime(DateTime at) {
    final int hour12 = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final String minute = at.minute.toString().padLeft(2, '0');
    final String period = at.hour < 12 ? 'AM' : 'PM';
    return '$hour12:$minute $period';
  }
}
