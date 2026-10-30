import 'package:flutter/foundation.dart';

import 'service_booking_model.dart';

/// Shared booking state for the services module.
///
/// The dashboard and the Bookings tab both advance the same jobs, so the list
/// cannot live in either one's `State` — accepting a request on the dashboard
/// has to be the same accept the Bookings tab sees. Same singleton-plus-
/// [ValueNotifier] shape as `SellerProfileProvider` in the shop module, which
/// is as much state management as this app has needed so far.
class ServiceBookingStore extends ChangeNotifier {
  static final ServiceBookingStore _instance = ServiceBookingStore._internal();
  factory ServiceBookingStore() => _instance;
  ServiceBookingStore._internal()
      : _bookings = List.of(initialSellerBookings);

  List<SellerBooking> _bookings;

  /// Every booking, newest appointment first within each bucket.
  List<SellerBooking> get bookings => List.unmodifiable(_bookings);

  // ── Reads the dashboard and the pipeline both need ──

  List<SellerBooking> get requests =>
      _inBucket(BookingBucket.requests)..sort(_byUrgency);

  List<SellerBooking> get upcoming =>
      _inBucket(BookingBucket.upcoming)..sort(_bySchedule);

  List<SellerBooking> get active =>
      _inBucket(BookingBucket.active)..sort(_bySchedule);

  List<SellerBooking> get completed =>
      _inBucket(BookingBucket.completed)..sort(_byScheduleDesc);

  List<SellerBooking> get cancelled =>
      _inBucket(BookingBucket.cancelled)..sort(_byScheduleDesc);

  List<SellerBooking> inBucket(BookingBucket bucket) => switch (bucket) {
        BookingBucket.requests => requests,
        BookingBucket.upcoming => upcoming,
        BookingBucket.active => active,
        BookingBucket.completed => completed,
        BookingBucket.cancelled => cancelled,
      };

  /// Today's jobs, in the order the day runs. Requests included: a request for
  /// today is the most urgent thing on the screen.
  List<SellerBooking> get today =>
      _bookings.where((b) => b.isToday).toList()..sort(_bySchedule);

  List<SellerBooking> get todaysOpen =>
      today.where((b) => b.status.isOpen).toList();

  int get pendingRequestCount => requests.length;

  int get todaysCompletedCount =>
      today.where((b) => b.status.isCompleted).length;

  int get todaysCancelledCount =>
      today.where((b) => b.status.isCancelled).length;

  int get liveJobCount => active.length;

  int get openJobCount => _bookings.where((b) => b.status.isOpen).length;

  /// Earnings from today's *completed* jobs only.
  ///
  /// A booking that has been accepted is not money yet — counting requested or
  /// confirmed work as revenue is how a dashboard ends up reporting a figure
  /// the seller never banked.
  double get todaysEarnings => today
      .where((b) => b.status.isCompleted)
      .fold(0.0, (sum, b) => sum + b.total);

  /// What today could still be worth if every open job completes.
  double get todaysPipeline => today
      .where((b) => b.status.isOpen)
      .fold(0.0, (sum, b) => sum + b.total);

  // ── Writes ──

  /// Move [booking] one stage along the lifecycle.
  ///
  /// [professional] is required by the UI when advancing into
  /// [BookingStatus.assigned] and ignored otherwise. Returns the stage reached,
  /// or null if the booking was already terminal.
  BookingStatus? advance(
    SellerBooking booking, {
    String? professional,
    String? note,
  }) {
    final BookingStatus? next = booking.status.next;
    if (next == null) return null;

    _replace(
      booking,
      booking.advancedTo(next, professional: professional, note: note),
    );
    return next;
  }

  /// Call [booking] off, with an optional reason the customer will see.
  bool reject(SellerBooking booking, {String? note}) {
    if (!booking.status.canCancel) return false;
    _replace(
      booking,
      booking.advancedTo(BookingStatus.cancelled, note: note),
    );
    return true;
  }

  void _replace(SellerBooking old, SellerBooking updated) {
    final int index = _bookings.indexWhere((b) => b.id == old.id);
    if (index == -1) return;
    _bookings = List.of(_bookings)..[index] = updated;
    notifyListeners();
  }

  /// Restore the mock data. Used by the dashboard's debug reset so a demo can
  /// be run twice without restarting the app.
  void reset() {
    _bookings = List.of(initialSellerBookings);
    notifyListeners();
  }

  List<SellerBooking> _inBucket(BookingBucket bucket) =>
      _bookings.where((b) => BookingBucket.of(b) == bucket).toList();

  /// Emergencies first, then by arrival window.
  static int _byUrgency(SellerBooking a, SellerBooking b) {
    if (a.isEmergency != b.isEmergency) return a.isEmergency ? -1 : 1;
    return _bySchedule(a, b);
  }

  static int _bySchedule(SellerBooking a, SellerBooking b) =>
      a.scheduledStart.compareTo(b.scheduledStart);

  static int _byScheduleDesc(SellerBooking a, SellerBooking b) =>
      b.scheduledStart.compareTo(a.scheduledStart);
}
