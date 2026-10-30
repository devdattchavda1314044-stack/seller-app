import 'package:flutter/material.dart';

import '../models/service_booking_model.dart';
import '../models/service_booking_store.dart';
import '../widgets/booking_action_dialogs.dart';

/// The two booking moves, in one place.
///
/// Both the dashboard and the Bookings tab offer accept / advance / reject, and
/// the rules around them — assigning needs a name, rejecting needs a
/// confirmation, intake being off blocks both — are the same on either screen.
/// Keeping them here is what stops the dashboard quietly growing a shortcut
/// the pipeline does not have.
class BookingActions {
  const BookingActions._();

  /// Move [booking] one stage along, prompting where the stage needs input.
  static Future<void> advance(
    BuildContext context,
    SellerBooking booking, {
    bool isAccepting = true,
  }) async {
    if (!isAccepting) {
      _notify(context, 'Turn on availability to manage bookings.');
      return;
    }

    final BookingStatus? next = booking.status.next;
    if (next == null) return;

    String? professional;
    if (next == BookingStatus.assigned) {
      professional = await BookingActionDialogs.askProfessional(
        context,
        booking: booking,
      );
      if (professional == null) return;
    }

    if (!context.mounted) return;

    final BookingStatus? reached = ServiceBookingStore().advance(
      booking,
      professional: professional,
    );
    if (reached == null) return;

    _notify(context, _confirmationFor(reached, booking, professional));
  }

  /// Call [booking] off after confirming, recording the reason on its history.
  static Future<void> reject(
    BuildContext context,
    SellerBooking booking, {
    bool isAccepting = true,
  }) async {
    if (!isAccepting) {
      _notify(context, 'Turn on availability to manage bookings.');
      return;
    }

    final String? reason = await BookingActionDialogs.confirmReject(
      context,
      booking: booking,
    );
    // Null is "backed out"; empty is "rejected without giving a reason".
    if (reason == null) return;

    if (!context.mounted) return;

    final bool didReject = ServiceBookingStore().reject(
      booking,
      note: reason.isEmpty ? null : reason,
    );
    if (!didReject) return;

    _notify(context, '${booking.id} rejected.');
  }

  static String _confirmationFor(
    BookingStatus reached,
    SellerBooking booking,
    String? professional,
  ) {
    return switch (reached) {
      BookingStatus.confirmed =>
        '${booking.id} accepted for ${booking.slot.label}.',
      BookingStatus.assigned => 'Assigned to $professional.',
      BookingStatus.onTheWay => 'Customer told you are on the way.',
      BookingStatus.started => 'Work started on ${booking.id}.',
      BookingStatus.completed => '${booking.id} completed. Nice work.',
      _ => 'Booking updated.',
    };
  }

  static void _notify(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
