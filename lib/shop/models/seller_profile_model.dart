import 'package:flutter/foundation.dart';

class SellerProfile {
  final String? profileImage;
  final String shopName;
  final String address;
  final String gstNumber;
  final String phoneNumber;
  final String email;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String mainCategory;
  final String subCategory;
  final bool isStoreAvailable;

  SellerProfile({
    this.profileImage,
    required this.shopName,
    required this.address,
    required this.gstNumber,
    required this.phoneNumber,
    required this.email,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.mainCategory,
    required this.subCategory,
    this.isStoreAvailable = true,
  });

  SellerProfile copyWith({
    String? profileImage,
    String? shopName,
    String? address,
    String? gstNumber,
    String? phoneNumber,
    String? email,
    double? latitude,
    double? longitude,
    String? locationName,
    String? mainCategory,
    String? subCategory,
    bool? isStoreAvailable,
  }) {
    return SellerProfile(
      profileImage: profileImage ?? this.profileImage,
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
      gstNumber: gstNumber ?? this.gstNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      mainCategory: mainCategory ?? this.mainCategory,
      subCategory: subCategory ?? this.subCategory,
      isStoreAvailable: isStoreAvailable ?? this.isStoreAvailable,
    );
  }
}

class SellerProfileProvider {
  // Singleton pattern
  static final SellerProfileProvider _instance = SellerProfileProvider._internal();
  factory SellerProfileProvider() => _instance;
  SellerProfileProvider._internal();

  // The shared state using ValueNotifier for lightweight reactivity
  final ValueNotifier<SellerProfile> profileNotifier = ValueNotifier<SellerProfile>(
    SellerProfile(
      profileImage: 'assets/images/shop/shop.jpg', // initial mock image
      shopName: 'ABC Grocery Store',
      address: '123 Market Street, Bhavnagar, Gujarat 364001',
      gstNumber: '24AAAAA0000A1Z5',
      phoneNumber: '9876543210',
      email: 'shop@example.com',
      latitude: 21.7645,
      longitude: 72.1519,
      locationName: 'Bhavnagar, Gujarat',
      mainCategory: 'Grocery',
      subCategory: 'Grocery Store',
      isStoreAvailable: true,
    ),
  );

  void updateProfile(SellerProfile newProfile) {
    profileNotifier.value = newProfile;
  }
}
