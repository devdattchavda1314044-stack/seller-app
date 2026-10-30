import 'package:flutter/foundation.dart';

/// The services seller's own profile.
///
/// Mirrors `ServiceProvider` on the customer side rather than `SellerProfile`
/// from the shop module, because a services seller is a tradesperson, not a
/// storefront: what converts a booking is jobs done, working hours and the
/// areas they cover, not a GST number and a shop photo.
class ServiceSellerProfile {
  ServiceSellerProfile({
    this.profileImage,
    required this.businessName,
    required this.ownerName,
    required this.address,
    required this.phoneNumber,
    required this.email,
    this.whatsappNumber,
    this.about,
    this.workingHours = 'Mon - Sat, 9:00 AM - 8:00 PM',
    this.serviceAreas = const [],
    this.categoriesHandled = const [],
    this.latitude,
    this.longitude,
    this.locationName,
    this.jobsDone = 0,
    this.rating = 0,
    this.reviewsCount = 0,
    this.yearsActive = 1,
    this.isVerified = false,
    this.isAcceptingBookings = true,
  });

  final String? profileImage;
  final String businessName;
  final String ownerName;
  final String address;
  final String phoneNumber;
  final String email;

  /// Chat number, when the seller takes WhatsApp. Null hides the action on the
  /// customer side rather than opening a dead thread.
  final String? whatsappNumber;

  /// A sentence or two in the seller's own voice, shown on their profile.
  final String? about;

  /// When they work, in plain language. Free text rather than a structured
  /// week because providers state it that way and the UI only reads it out.
  final String workingHours;

  /// Neighbourhoods they cover. Empty falls back to [address] alone.
  final List<String> serviceAreas;

  /// Which departments they list under, from `serviceCategories`.
  final List<String> categoriesHandled;

  final double? latitude;
  final double? longitude;
  final String? locationName;

  /// Completed bookings. On a marketplace of strangers this is the number that
  /// converts — more than a rating, which every provider claims is 4.8.
  final int jobsDone;

  final double rating;
  final int reviewsCount;
  final int yearsActive;
  final bool isVerified;

  /// The services equivalent of the shop's open/closed switch. Off keeps the
  /// listings visible but stops new requests, which is what a tradesperson
  /// actually wants when their day is full.
  final bool isAcceptingBookings;

  /// Two initials for the monogram, or one for a single-word name.
  String get initials {
    final parts = businessName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  ServiceSellerProfile copyWith({
    String? profileImage,
    String? businessName,
    String? ownerName,
    String? address,
    String? phoneNumber,
    String? email,
    String? whatsappNumber,
    String? about,
    String? workingHours,
    List<String>? serviceAreas,
    List<String>? categoriesHandled,
    double? latitude,
    double? longitude,
    String? locationName,
    int? jobsDone,
    double? rating,
    int? reviewsCount,
    int? yearsActive,
    bool? isVerified,
    bool? isAcceptingBookings,
  }) {
    return ServiceSellerProfile(
      profileImage: profileImage ?? this.profileImage,
      businessName: businessName ?? this.businessName,
      ownerName: ownerName ?? this.ownerName,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      about: about ?? this.about,
      workingHours: workingHours ?? this.workingHours,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      categoriesHandled: categoriesHandled ?? this.categoriesHandled,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      jobsDone: jobsDone ?? this.jobsDone,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      yearsActive: yearsActive ?? this.yearsActive,
      isVerified: isVerified ?? this.isVerified,
      isAcceptingBookings: isAcceptingBookings ?? this.isAcceptingBookings,
    );
  }
}

/// Shared services-seller profile state.
///
/// Same singleton-plus-[ValueNotifier] shape as `SellerProfileProvider` in the
/// shop module, so the bottom bar and header rebuild off one source.
class ServiceSellerProfileProvider {
  static final ServiceSellerProfileProvider _instance =
      ServiceSellerProfileProvider._internal();
  factory ServiceSellerProfileProvider() => _instance;
  ServiceSellerProfileProvider._internal();

  final ValueNotifier<ServiceSellerProfile> profileNotifier =
      ValueNotifier<ServiceSellerProfile>(
    ServiceSellerProfile(
      businessName: 'Shree Home Services',
      ownerName: 'Jatin Mehta',
      address: 'Shop 4, Mahadev Complex, Waghawadi Road, Bhavnagar 364001',
      phoneNumber: '1234567890',
      email: 'service@service.com',
      whatsappNumber: '1234567890',
      about:
          'Eleven years of home services across Bhavnagar — cleaning, '
          'plumbing, electrical and appliance repair. Same-day call-outs, '
          'uniformed staff, and a written quote before any work starts.',
      workingHours: 'Mon - Sat, 8:00 AM - 8:00 PM',
      serviceAreas: [
        'Waghawadi Road',
        'Kaliyabid',
        'Subhashnagar',
        'Chitra',
        'Ghogha Circle',
        'Nari Road',
      ],
      categoriesHandled: [
        'Cleaning',
        'Plumbing',
        'Electrical',
        'Appliance Repair',
        'Beauty',
      ],
      latitude: 21.7645,
      longitude: 72.1519,
      locationName: 'Bhavnagar, Gujarat',
      jobsDone: 482,
      rating: 4.6,
      reviewsCount: 745,
      yearsActive: 11,
      isVerified: true,
      isAcceptingBookings: true,
    ),
  );

  void updateProfile(ServiceSellerProfile newProfile) {
    profileNotifier.value = newProfile;
  }
}
