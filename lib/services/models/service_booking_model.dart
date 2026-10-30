import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Where a booking has reached.
///
/// Mirrors `BookingStatus` in the customer app (`udur/lib/services/models/
/// service_booking.dart`) stage for stage, because the customer's timeline
/// renders from exactly these values — a seller-side stage the customer app
/// does not know about would draw a gap in their progress bar.
///
/// [cancelled] sits outside that line with a stage of -1: it is not a later
/// phase of the work, it is the work not happening.
enum BookingStatus {
  requested(
    stage: 0,
    label: 'Requested',
    detail: 'Waiting for you to accept',
    icon: Icons.schedule_rounded,
  ),
  confirmed(
    stage: 1,
    label: 'Confirmed',
    detail: 'You have accepted the slot',
    icon: Icons.event_available_rounded,
  ),
  assigned(
    stage: 2,
    label: 'Professional assigned',
    detail: 'Someone is allocated to the job',
    icon: Icons.badge_outlined,
  ),
  onTheWay(
    stage: 3,
    label: 'On the way',
    detail: 'Your professional is travelling',
    icon: Icons.directions_bike_rounded,
  ),
  started(
    stage: 4,
    label: 'Work started',
    detail: 'The job is under way',
    icon: Icons.handyman_rounded,
  ),
  completed(
    stage: 5,
    label: 'Completed',
    detail: 'The job is done',
    icon: Icons.task_alt_rounded,
  ),
  cancelled(
    stage: -1,
    label: 'Cancelled',
    detail: 'This booking was cancelled',
    icon: Icons.cancel_outlined,
  );

  const BookingStatus({
    required this.stage,
    required this.label,
    required this.detail,
    required this.icon,
  });

  /// Position on the timeline. -1 means off the line entirely.
  final int stage;

  final String label;

  /// One line under the label, in plain language.
  final String detail;

  final IconData icon;

  /// The six steps a booking passes through, in order. Excludes [cancelled].
  static const List<BookingStatus> timeline = [
    requested,
    confirmed,
    assigned,
    onTheWay,
    started,
    completed,
  ];

  bool get isCancelled => this == BookingStatus.cancelled;
  bool get isCompleted => this == BookingStatus.completed;

  /// Still going to happen: not finished, not called off.
  bool get isOpen => !isCancelled && !isCompleted;

  /// Someone is en route or on site.
  bool get isLive => this == onTheWay || this == started;

  /// The stage the seller moves this booking to next, or null at the end of
  /// the line. Driving the UI off this rather than a switch in each widget is
  /// what keeps the sheet, the list item and the dashboard agreeing on what
  /// the next button should say.
  BookingStatus? get next => switch (this) {
    requested => confirmed,
    confirmed => assigned,
    assigned => onTheWay,
    onTheWay => started,
    started => completed,
    completed || cancelled => null,
  };

  /// Imperative label for the button that advances to [next].
  String? get advanceLabel => switch (this) {
    requested => 'Accept',
    confirmed => 'Assign',
    assigned => 'On the way',
    onTheWay => 'Start work',
    started => 'Complete',
    completed || cancelled => null,
  };

  /// Whether the seller may still call the job off.
  ///
  /// Rejecting stops once work has started: at that point the professional is
  /// on site, and a tap that voids the booking is not a cancellation, it is an
  /// unpaid job.
  bool get canCancel =>
      this == requested || this == confirmed || this == assigned;

  Color get color => switch (this) {
    cancelled => AppTokens.danger,
    completed => AppTokens.success,
    onTheWay || started => AppTokens.progress,
    _ => AppColors.primary,
  };

  Color get softColor => switch (this) {
    cancelled => AppTokens.dangerSoft,
    completed => AppTokens.successSoft,
    onTheWay || started => AppTokens.progressSoft,
    _ => AppTokens.actionSoft,
  };
}

/// A two-hour arrival window.
///
/// Services quote a window, not a minute: a plumber who promises 10:00 and
/// arrives 10:40 has broken a promise, one who promises 10-12 has not. The
/// seller offers windows for the same reason the customer books them.
@immutable
class BookingSlot {
  const BookingSlot({
    required this.id,
    required this.label,
    required this.startHour,
  });

  final String id;

  /// "8:00 AM - 10:00 AM".
  final String label;

  /// 24-hour start, used to order the day.
  final int startHour;

  /// Every window a provider can offer in a day.
  static const List<BookingSlot> all = [
    BookingSlot(id: 'sl1', label: '8:00 AM - 10:00 AM', startHour: 8),
    BookingSlot(id: 'sl2', label: '10:00 AM - 12:00 PM', startHour: 10),
    BookingSlot(id: 'sl3', label: '12:00 PM - 2:00 PM', startHour: 12),
    BookingSlot(id: 'sl4', label: '2:00 PM - 4:00 PM', startHour: 14),
    BookingSlot(id: 'sl5', label: '4:00 PM - 6:00 PM', startHour: 16),
    BookingSlot(id: 'sl6', label: '6:00 PM - 8:00 PM', startHour: 18),
  ];
}

/// One recorded change of status, for the timeline.
@immutable
class BookingEvent {
  const BookingEvent({required this.status, required this.at, this.note});

  final BookingStatus status;
  final DateTime at;

  /// Free text attached to this step — a rejection reason, a delay note.
  final String? note;
}

/// A booking as the seller sees it.
///
/// Holds the customer's details rather than the provider's: the seller already
/// knows who they are, and what they need on screen is who to call and where
/// to go. Prices are copied in at the moment of booking, so a receipt still
/// reads correctly after the listing is repriced.
@immutable
class SellerBooking {
  const SellerBooking({
    required this.id,
    required this.serviceId,
    required this.serviceTitle,
    required this.categoryName,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.scheduledDate,
    required this.slot,
    required this.basePrice,
    required this.createdAt,
    required this.history,
    this.assignedProfessional,
    this.currency = '₹',
    this.visitFee = 0,
    this.discount = 0,
    this.notes,
    this.isEmergency = false,
    this.status = BookingStatus.requested,
  });

  /// Customer-facing reference — "UDR-4820XK". The one thing a caller can read
  /// out, so it is the same string on both sides of the marketplace.
  final String id;

  final String serviceId;
  final String serviceTitle;
  final String categoryName;

  final String customerName;
  final String customerPhone;
  final String address;

  /// Date of the visit, at midnight. The time lives in [slot].
  final DateTime scheduledDate;

  final BookingSlot slot;

  /// What the listing quoted at the time of booking.
  final double basePrice;

  /// Call-out charge, stated separately so the customer can see it is not part
  /// of the service price.
  final double visitFee;

  /// Money off, as a positive number.
  final double discount;

  final String currency;
  final String? notes;

  /// Who is doing the job. Null until the booking reaches
  /// [BookingStatus.assigned] — which is the whole point of that stage.
  final String? assignedProfessional;

  /// Emergency call-outs sort to the top and carry the only red on the list.
  final bool isEmergency;

  final BookingStatus status;
  final DateTime createdAt;

  /// Every status this booking has passed through, oldest first.
  final List<BookingEvent> history;

  double get total =>
      (basePrice + visitFee - discount).clamp(0, double.infinity);

  /// When the visit window opens, for sorting.
  DateTime get scheduledStart => DateTime(
    scheduledDate.year,
    scheduledDate.month,
    scheduledDate.day,
    slot.startHour,
  );

  /// "Today", "Tomorrow", or "Sat, 20 Sep".
  String scheduledDayLabel({DateTime? now}) {
    final DateTime today = now ?? DateTime.now();
    final int days = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    ).difference(DateTime(today.year, today.month, today.day)).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days == -1) return 'Yesterday';
    return '${_weekdays[scheduledDate.weekday - 1]}, '
        '${scheduledDate.day} ${_months[scheduledDate.month - 1]}';
  }

  bool get isToday => scheduledDayLabel() == 'Today';

  /// This booking at [to], with the move recorded on [history].
  ///
  /// Advancing and logging are one operation on purpose: a status that moves
  /// without an event behind it is what leaves the customer's timeline showing
  /// a stage with no timestamp under it.
  SellerBooking advancedTo(
    BookingStatus to, {
    String? note,
    String? professional,
    DateTime? at,
  }) {
    return copyWith(
      status: to,
      assignedProfessional: professional ?? assignedProfessional,
      history: [
        ...history,
        BookingEvent(status: to, at: at ?? DateTime.now(), note: note),
      ],
    );
  }

  SellerBooking copyWith({
    BookingStatus? status,
    DateTime? scheduledDate,
    BookingSlot? slot,
    String? assignedProfessional,
    List<BookingEvent>? history,
  }) {
    return SellerBooking(
      id: id,
      serviceId: serviceId,
      serviceTitle: serviceTitle,
      categoryName: categoryName,
      customerName: customerName,
      customerPhone: customerPhone,
      address: address,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      slot: slot ?? this.slot,
      basePrice: basePrice,
      visitFee: visitFee,
      discount: discount,
      currency: currency,
      notes: notes,
      assignedProfessional: assignedProfessional ?? this.assignedProfessional,
      isEmergency: isEmergency,
      status: status ?? this.status,
      createdAt: createdAt,
      history: history ?? this.history,
    );
  }

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}

/// Which bucket a booking belongs in on the seller's booking list.
enum BookingBucket {
  requests('Requests'),
  upcoming('Upcoming'),
  active('Active'),
  completed('Completed'),
  cancelled('Cancelled');

  const BookingBucket(this.label);

  final String label;

  static BookingBucket of(SellerBooking booking) {
    if (booking.status.isCancelled) return cancelled;
    if (booking.status.isCompleted) return completed;
    if (booking.status.isLive) return active;
    if (booking.status == BookingStatus.requested) return requests;
    return upcoming;
  }
}

// ──────────────────────────────────────────────────────────────────
// Static mock bookings for the Services Dashboard.
//
// Mirrors `initialShopOrders` in the shop module: the services backend has no
// tables yet (`udur-backend/docs/05-database.md` marks providers as P4), so
// every surface here reads from this list.
// ──────────────────────────────────────────────────────────────────

DateTime _todayAt(int hour, [int minute = 0]) {
  final DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}

DateTime get _today {
  final DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

final List<SellerBooking> initialSellerBookings = [
  SellerBooking(
    id: 'UDR-4820XK',
    serviceId: 'sv1',
    serviceTitle: 'Deep Home Cleaning (2 BHK)',
    categoryName: 'Cleaning',
    customerName: 'Rahul Patel',
    customerPhone: '+91 98765 43210',
    address: '14, Krishna Residency, Waghawadi Road,\nBhavnagar, Gujarat - 364001',
    scheduledDate: _today,
    slot: BookingSlot.all[2],
    basePrice: 2499,
    visitFee: 99,
    notes: 'Third floor, no lift. Please bring your own ladder.',
    createdAt: _todayAt(8, 12),
    history: [
      BookingEvent(status: BookingStatus.requested, at: _todayAt(8, 12)),
    ],
  ),
  SellerBooking(
    id: 'UDR-4821PM',
    serviceId: 'sv4',
    serviceTitle: 'Emergency Pipe Leak Repair',
    categoryName: 'Plumbing',
    customerName: 'Priya Sharma',
    customerPhone: '+91 91234 56789',
    address: 'B-7, Sardar Nagar, Near Ghogha Circle,\nBhavnagar, Gujarat - 364002',
    scheduledDate: _today,
    slot: BookingSlot.all[1],
    basePrice: 799,
    visitFee: 149,
    isEmergency: true,
    notes: 'Kitchen sink overflowing since morning.',
    createdAt: _todayAt(9, 40),
    history: [
      BookingEvent(status: BookingStatus.requested, at: _todayAt(9, 40)),
    ],
  ),
  SellerBooking(
    id: 'UDR-4818QT',
    serviceId: 'sv2',
    serviceTitle: 'Split AC Service & Gas Top-up',
    categoryName: 'Appliance Repair',
    customerName: 'Amit Kumar',
    customerPhone: '+91 99887 76655',
    address: '203, Shivalik Heights, Kaliyabid,\nBhavnagar, Gujarat - 364002',
    scheduledDate: _today,
    slot: BookingSlot.all[3],
    basePrice: 1299,
    discount: 150,
    status: BookingStatus.confirmed,
    createdAt: _todayAt(7, 5),
    history: [
      BookingEvent(status: BookingStatus.requested, at: _todayAt(7, 5)),
      BookingEvent(status: BookingStatus.confirmed, at: _todayAt(7, 18)),
    ],
  ),
  SellerBooking(
    id: 'UDR-4815LN',
    serviceId: 'sv3',
    serviceTitle: 'Bridal Makeup & Hair Styling',
    categoryName: 'Beauty',
    customerName: 'Sneha Joshi',
    customerPhone: '+91 97654 32108',
    address: '5, Anand Bungalows, Nari Road,\nBhavnagar, Gujarat - 364001',
    scheduledDate: _today,
    slot: BookingSlot.all[0],
    basePrice: 5999,
    assignedProfessional: 'Kavita M.',
    status: BookingStatus.onTheWay,
    createdAt: _today.subtract(const Duration(days: 2, hours: 3)),
    history: [
      BookingEvent(
        status: BookingStatus.requested,
        at: _today.subtract(const Duration(days: 2, hours: 3)),
      ),
      BookingEvent(
        status: BookingStatus.confirmed,
        at: _today.subtract(const Duration(days: 2, hours: 2)),
      ),
      BookingEvent(status: BookingStatus.assigned, at: _todayAt(7, 30)),
      BookingEvent(status: BookingStatus.onTheWay, at: _todayAt(7, 50)),
    ],
  ),
  SellerBooking(
    id: 'UDR-4812RS',
    serviceId: 'sv5',
    serviceTitle: 'Full Home Electrical Inspection',
    categoryName: 'Electrical',
    customerName: 'Mehul Desai',
    customerPhone: '+91 90123 45678',
    address: '88, Patel Society, Subhashnagar,\nBhavnagar, Gujarat - 364003',
    scheduledDate: _today.add(const Duration(days: 1)),
    slot: BookingSlot.all[4],
    basePrice: 1499,
    assignedProfessional: 'Jignesh P.',
    status: BookingStatus.assigned,
    createdAt: _today.subtract(const Duration(days: 1)),
    history: [
      BookingEvent(
        status: BookingStatus.requested,
        at: _today.subtract(const Duration(days: 1)),
      ),
      BookingEvent(
        status: BookingStatus.confirmed,
        at: _today.subtract(const Duration(hours: 20)),
      ),
      BookingEvent(status: BookingStatus.assigned, at: _todayAt(8, 0)),
    ],
  ),
  SellerBooking(
    id: 'UDR-4809WB',
    serviceId: 'sv1',
    serviceTitle: 'Deep Home Cleaning (2 BHK)',
    categoryName: 'Cleaning',
    customerName: 'Nikhil Trivedi',
    customerPhone: '+91 93456 78901',
    address: '21, Gokul Flats, Chitra,\nBhavnagar, Gujarat - 364004',
    scheduledDate: _today,
    slot: BookingSlot.all[0],
    basePrice: 2499,
    assignedProfessional: 'Ramesh B.',
    status: BookingStatus.completed,
    createdAt: _today.subtract(const Duration(days: 3)),
    history: [
      BookingEvent(
        status: BookingStatus.requested,
        at: _today.subtract(const Duration(days: 3)),
      ),
      BookingEvent(
        status: BookingStatus.confirmed,
        at: _today.subtract(const Duration(days: 3)),
      ),
      BookingEvent(status: BookingStatus.assigned, at: _todayAt(6, 45)),
      BookingEvent(status: BookingStatus.onTheWay, at: _todayAt(7, 40)),
      BookingEvent(status: BookingStatus.started, at: _todayAt(8, 10)),
      BookingEvent(status: BookingStatus.completed, at: _todayAt(10, 25)),
    ],
  ),
];
