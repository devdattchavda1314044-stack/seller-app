import 'package:uuid/uuid.dart';

enum OfferSourceType {
  existingProduct,
  manual
}

class OfferModel {
  String id;
  String title;
  List<String> images;
  double oldPrice;
  double newPrice;
  String category;
  String subCategory;
  DateTime startDate;
  DateTime endDate;
  DateTime createdAt;
  OfferSourceType sourceType;
  String? sourceProductId;
  String? description;

  OfferModel({
    String? id,
    required this.title,
    required this.images,
    required this.oldPrice,
    required this.newPrice,
    required this.category,
    required this.subCategory,
    required this.startDate,
    required this.endDate,
    DateTime? createdAt,
    required this.sourceType,
    this.sourceProductId,
    this.description,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  double get discountPercentage {
    if (oldPrice <= 0 || newPrice >= oldPrice) return 0;
    return ((oldPrice - newPrice) / oldPrice) * 100;
  }
}

// Dummy data
final List<OfferModel> dummyOffers = [
  OfferModel(
    title: "Weekend Special Grocery Offer",
    images: [
      "assets/images/shop/product1_1.png",
      "assets/images/shop/product1_2.png",
    ],
    oldPrice: 70,
    newPrice: 62,
    category: "Grocery",
    subCategory: "Dairy",
    startDate: DateTime.now().subtract(const Duration(days: 2)),
    endDate: DateTime.now().add(const Duration(days: 5)),
    sourceType: OfferSourceType.existingProduct,
    description: "Farm fresh Amul milk, pasteurized and homogenized. Best before 2 days from date of packaging.",
  ),
  OfferModel(
    title: "Festive Electronics Deal",
    images: [
      "assets/images/shop/product2_1.png",
    ],
    oldPrice: 1500,
    newPrice: 1299,
    category: "Electronics",
    subCategory: "Audio",
    startDate: DateTime.now().add(const Duration(days: 1)), // Upcoming
    endDate: DateTime.now().add(const Duration(days: 10)),
    sourceType: OfferSourceType.manual,
    description: "High quality wireless earbuds for the festive season.",
  ),
  OfferModel(
    title: "Monsoon Sale - Arhar Dal",
    images: [
      "assets/images/shop/product4_1.png",
    ],
    oldPrice: 180,
    newPrice: 155,
    category: "Grocery",
    subCategory: "Cooking Essentials",
    startDate: DateTime.now().subtract(const Duration(days: 10)),
    endDate: DateTime.now().subtract(const Duration(days: 1)), // Expired
    sourceType: OfferSourceType.existingProduct,
    description: "Unpolished arhar dal rich in protein. Free from artificial colors and preservatives.",
  ),
  OfferModel(
    title: "Fresh Potatoes Mega Discount",
    images: [
      "assets/images/shop/product3_1.png",
    ],
    oldPrice: 40,
    newPrice: 32,
    category: "Grocery",
    subCategory: "Vegetables",
    startDate: DateTime.now().subtract(const Duration(days: 1)),
    endDate: DateTime.now().add(const Duration(days: 3)),
    sourceType: OfferSourceType.existingProduct,
    description: "Farm fresh, unwashed potatoes. Locally sourced from organic farms.",
  ),
];
