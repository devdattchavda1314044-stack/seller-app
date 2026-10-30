import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// How soon the seller can attend.
///
/// The single most decisive fact on a services card, and the one a product
/// card has no equivalent for. Mirrors `ServiceAvailability` in the customer
/// app so the two sides label the same promise identically.
enum ServiceAvailability {
  now('Available now', 'Someone can be dispatched within the hour'),
  today('Today', 'A slot is free later today'),
  tomorrow('Tomorrow', 'Earliest slot is tomorrow'),
  thisWeek('This week', 'Booked out; customer picks a slot later in the week');

  const ServiceAvailability(this.label, this.detail);

  final String label;
  final String detail;
}

/// One bookable department the seller can file a listing under.
///
/// Carries an [icon] and a [tint] rather than an asset path, matching the
/// customer app: the module ships no service photography, and a glyph is
/// honest about what it is, scales to any tile, and cannot go missing at
/// runtime.
@immutable
class ServiceCategoryOption {
  const ServiceCategoryOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.tint,
    this.subCategories = const [],
  });

  final String id;
  final String name;
  final IconData icon;

  /// Soft ground the glyph sits on, so the picker reads as a set of
  /// departments rather than a column of identical rows.
  final Color tint;

  final List<String> subCategories;
}

/// Every department a services seller can list under, with the sub-categories
/// the customer app's category screen expects beneath each.
const List<ServiceCategoryOption> serviceCategories = [
  ServiceCategoryOption(
    id: 'c1',
    name: 'Cleaning',
    icon: Icons.cleaning_services_outlined,
    tint: Color(0xFFE8F0FF),
    subCategories: [
      'Home Deep Clean',
      'Sofa & Carpet',
      'Bathroom',
      'Kitchen',
      'Water Tank',
      'Pest Control',
    ],
  ),
  ServiceCategoryOption(
    id: 'c2',
    name: 'Plumbing',
    icon: Icons.plumbing_outlined,
    tint: Color(0xFFE6F7FF),
    subCategories: [
      'Leak Repair',
      'Tap & Mixer',
      'Drainage',
      'Water Tank',
      'Bathroom Fitting',
    ],
  ),
  ServiceCategoryOption(
    id: 'c3',
    name: 'Electrical',
    icon: Icons.electrical_services_outlined,
    tint: Color(0xFFFFF7E0),
    subCategories: [
      'Wiring',
      'Switch & Socket',
      'Fan & Light',
      'Inverter',
      'Inspection',
    ],
  ),
  ServiceCategoryOption(
    id: 'c4',
    name: 'Appliance Repair',
    icon: Icons.handyman_outlined,
    tint: Color(0xFFFFF0DF),
    subCategories: [
      'AC Service',
      'Refrigerator',
      'Washing Machine',
      'Microwave',
      'Water Purifier',
      'Geyser',
    ],
  ),
  ServiceCategoryOption(
    id: 'c5',
    name: 'Beauty',
    icon: Icons.face_retouching_natural_outlined,
    tint: Color(0xFFFFE8F0),
    subCategories: [
      'Salon at Home',
      'Bridal',
      'Hair',
      'Skin & Facial',
      'Mehndi',
      'Spa & Massage',
    ],
  ),
  ServiceCategoryOption(
    id: 'c6',
    name: 'Carpentry',
    icon: Icons.carpenter_outlined,
    tint: Color(0xFFF0E9FF),
    subCategories: [
      'Furniture Repair',
      'Door & Window',
      'Modular Kitchen',
      'Curtain Fitting',
    ],
  ),
  ServiceCategoryOption(
    id: 'c7',
    name: 'Painting',
    icon: Icons.format_paint_outlined,
    tint: Color(0xFFE8FFF2),
    subCategories: [
      'Interior',
      'Exterior',
      'Waterproofing',
      'Texture & Stencil',
    ],
  ),
  ServiceCategoryOption(
    id: 'c8',
    name: 'Tutoring',
    icon: Icons.menu_book_outlined,
    tint: Color(0xFFFFE8EA),
    subCategories: [
      'School Tuition',
      'Competitive Exams',
      'Music',
      'Spoken English',
      'Computer Basics',
    ],
  ),
];

ServiceCategoryOption categoryByName(String name) {
  return serviceCategories.firstWhere(
    (c) => c.name == name,
    orElse: () => serviceCategories.first,
  );
}

/// One bookable service the seller offers.
///
/// There is deliberately no image field. Services is icon-led on the customer
/// side: a card is built from its category glyph, the provider behind it, and
/// the numbers that decide a booking — price, rating, how soon someone can
/// come. Giving the seller an image uploader here would collect assets the
/// customer app has nowhere to render.
class ServiceListing {
  ServiceListing({
    String? id,
    required this.title,
    required this.category,
    required this.subCategory,
    required this.startingPrice,
    required this.durationLabel,
    required this.availability,
    this.originalPrice,
    this.visitFee = 0,
    this.currency = '₹',
    this.rating = 0,
    this.reviewsCount = 0,
    this.bookingsReceived = 0,
    this.isActive = true,
    this.isEmergency = false,
    this.description = '',
    this.inclusions = const [],
    this.exclusions = const [],
    this.requirements = const [],
    List<BookingSlotRef>? slots,
  })  : id = id ?? const Uuid().v4(),
        slots = slots ?? List.of(_defaultSlotIds);

  final String id;

  String title;
  String category;
  String subCategory;

  /// What the visit starts at. Services quote from, they do not price exactly,
  /// so every customer surface renders this as "From ₹x".
  double startingPrice;

  /// Struck-through original, when the service is discounted. Null means full
  /// price and no badge.
  double? originalPrice;

  /// Call-out charge, quoted on top of [startingPrice] and stated separately
  /// so the customer can see it is not part of the service price.
  double visitFee;

  final String currency;

  /// How long the job takes — "45-60 min", "3-4 hrs". A shopper compares
  /// price; someone booking a service compares price *and* their afternoon.
  String durationLabel;

  ServiceAvailability availability;

  /// Emergency call-outs get their own rail on the customer home screen and
  /// the only red on the page.
  bool isEmergency;

  bool isActive;

  /// In the seller's own words. Empty is allowed: the customer's detail screen
  /// falls back to a sentence built from the title, category and provider.
  String description;

  /// What the quoted price buys. The single most requested piece of
  /// information on a services listing, and the one that stops a dispute on
  /// the doorstep.
  List<String> inclusions;

  /// What it does not buy — parts, materials, anything quoted separately.
  List<String> exclusions;

  /// What the customer needs to have ready — water supply, parking, a power
  /// point. Shown before booking, not after.
  List<String> requirements;

  /// Which two-hour windows this service can be booked into. Ids match
  /// `BookingSlot.all` in `service_booking_model.dart`.
  List<BookingSlotRef> slots;

  final double rating;
  final int reviewsCount;
  final int bookingsReceived;

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > startingPrice;

  int get discountPercent => hasDiscount
      ? (((originalPrice! - startingPrice) / originalPrice!) * 100).round()
      : 0;

  IconData get icon => categoryByName(category).icon;

  /// The department's pastel ground.
  ///
  /// Mirrors `ServiceCategory.tint` in the customer app, which does render a
  /// tint per department. The seller UI deliberately does not: Shop puts every
  /// leading glyph on one neutral tile, and eight pastels in a list made the
  /// catalogue read as eight unrelated screens. Kept so the two models stay
  /// the same shape when this is wired to the API.
  Color get tint => categoryByName(category).tint;

  static const List<BookingSlotRef> _defaultSlotIds = [
    'sl1',
    'sl2',
    'sl3',
    'sl4',
    'sl5',
    'sl6',
  ];
}

/// A `BookingSlot.id`. Named rather than a bare `String` so a listing's slot
/// list cannot be confused with its inclusions at a call site.
typedef BookingSlotRef = String;

// ──────────────────────────────────────────────────────────────────
// Static mock listings, mirroring `dummySellerProducts` in the shop module.
// ──────────────────────────────────────────────────────────────────

final List<ServiceListing> dummyServiceListings = [
  ServiceListing(
    id: 'sv1',
    title: 'Deep Home Cleaning (2 BHK)',
    category: 'Cleaning',
    subCategory: 'Home Deep Clean',
    startingPrice: 2499,
    originalPrice: 2999,
    visitFee: 99,
    durationLabel: '4-5 hrs',
    availability: ServiceAvailability.today,
    rating: 4.7,
    reviewsCount: 184,
    bookingsReceived: 96,
    description:
        'A full top-to-bottom clean of a 2 BHK — floors, bathrooms, kitchen, '
        'balconies and all reachable surfaces. Two professionals, machine '
        'scrubbing, and eco-safe chemicals.',
    inclusions: [
      'Bathroom descaling and sanitising',
      'Kitchen degreasing, including chimney exterior',
      'Floor scrubbing with a single-disc machine',
      'Cobweb and dust removal up to 10 ft',
      'Balcony and window-grill wash',
    ],
    exclusions: [
      'Exterior window glass above ground floor',
      'Furniture shifting over 40 kg',
      'Sofa and carpet shampooing (quoted separately)',
    ],
    requirements: [
      'Running water supply',
      'A working power point',
      'Someone at home to let the team in',
    ],
  ),
  ServiceListing(
    id: 'sv2',
    title: 'Split AC Service & Gas Top-up',
    category: 'Appliance Repair',
    subCategory: 'AC Service',
    startingPrice: 1299,
    originalPrice: 1599,
    durationLabel: '60-90 min',
    availability: ServiceAvailability.now,
    rating: 4.5,
    reviewsCount: 142,
    bookingsReceived: 118,
    description:
        'Jet-pump service of indoor and outdoor units, drain-line clearing, '
        'and R-32 gas top-up where pressure is low.',
    inclusions: [
      'Indoor and outdoor coil jet wash',
      'Filter clean and refit',
      'Drain-line clearing',
      'Cooling and pressure check',
    ],
    exclusions: [
      'Gas refill beyond 200g (charged per gram)',
      'PCB or compressor replacement',
      'Uninstall and reinstall',
    ],
    requirements: [
      'Clear access to the outdoor unit',
      'A power point within 3 m',
    ],
  ),
  ServiceListing(
    id: 'sv3',
    title: 'Bridal Makeup & Hair Styling',
    category: 'Beauty',
    subCategory: 'Bridal',
    startingPrice: 5999,
    durationLabel: '3-4 hrs',
    availability: ServiceAvailability.thisWeek,
    rating: 4.9,
    reviewsCount: 67,
    bookingsReceived: 31,
    description:
        'HD bridal makeup with draping and hair styling, done at your venue '
        'by a senior artist. Includes one trial session booked separately.',
    inclusions: [
      'HD base with airbrush finish',
      'Eye makeup, lashes and contouring',
      'Hair styling of your choice',
      'Saree or lehenga draping',
      'Touch-up kit for the day',
    ],
    exclusions: [
      'Jewellery and accessories',
      'Travel beyond 15 km from Bhavnagar',
      'Additional family members (quoted per head)',
    ],
    requirements: [
      'A well-lit room with a mirror and a plug point',
      'Booking at least 4 days in advance',
    ],
  ),
  ServiceListing(
    id: 'sv4',
    title: 'Emergency Pipe Leak Repair',
    category: 'Plumbing',
    subCategory: 'Leak Repair',
    startingPrice: 799,
    visitFee: 149,
    durationLabel: '45-60 min',
    availability: ServiceAvailability.now,
    isEmergency: true,
    rating: 4.6,
    reviewsCount: 211,
    bookingsReceived: 157,
    description:
        'Same-hour call-out for burst pipes, overflowing sinks and running '
        'leaks. Diagnosis and the fix in one visit wherever parts allow.',
    inclusions: [
      'Leak tracing and diagnosis',
      'Sealing, re-threading or clamping',
      'Pressure test after the fix',
    ],
    exclusions: [
      'Replacement pipes and fittings (billed at cost)',
      'Wall breaking and re-plastering',
      'Concealed-line rerouting',
    ],
    requirements: [
      'Access to the main water valve',
      'The affected area cleared of belongings',
    ],
  ),
  ServiceListing(
    id: 'sv5',
    title: 'Full Home Electrical Inspection',
    category: 'Electrical',
    subCategory: 'Inspection',
    startingPrice: 1499,
    durationLabel: '2-3 hrs',
    availability: ServiceAvailability.tomorrow,
    rating: 4.4,
    reviewsCount: 48,
    bookingsReceived: 22,
    isActive: false,
    description:
        'A licensed electrician checks every circuit, board and earthing '
        'point in the home and hands over a written report with risks ranked.',
    inclusions: [
      'MCB and distribution-board check',
      'Earthing and leakage test',
      'Load balance across phases',
      'Written report with photographs',
    ],
    exclusions: [
      'Any repair or rewiring arising from the report',
      'Replacement MCBs and fittings',
    ],
    requirements: [
      'Access to the main board and all rooms',
      'Roughly 3 hours with power switching on and off',
    ],
  ),
  ServiceListing(
    id: 'sv6',
    title: 'Sofa & Carpet Shampooing',
    category: 'Cleaning',
    subCategory: 'Sofa & Carpet',
    startingPrice: 1199,
    originalPrice: 1499,
    durationLabel: '90-120 min',
    availability: ServiceAvailability.today,
    rating: 4.3,
    reviewsCount: 93,
    bookingsReceived: 58,
    description:
        'Wet shampooing and vacuum extraction for fabric sofas, mattresses '
        'and carpets, with a deodorising finish.',
    inclusions: [
      'Dry vacuum and stain pre-treatment',
      'Wet shampoo with extraction',
      'Deodorising finish',
    ],
    exclusions: [
      'Leather and rexine upholstery',
      'Permanent stains older than 6 months',
    ],
    requirements: [
      'A power point within 5 m',
      'Cushions and covers removed in advance',
    ],
  ),
];
