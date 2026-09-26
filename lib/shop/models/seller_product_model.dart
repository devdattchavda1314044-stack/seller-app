class SellerProduct {
  String name;
  List<String> images;
  double oldPrice;
  double newPrice;
  final int receivedOrders;
  final bool offerAvailable;
  String category;
  String subCategory;
  final double rating;
  bool isActive;
  String? description;
  bool returnAvailable;

  SellerProduct({
    required this.name,
    required this.images,
    required this.oldPrice,
    required this.newPrice,
    required this.receivedOrders,
    required this.offerAvailable,
    required this.category,
    required this.subCategory,
    required this.rating,
    this.isActive = true,
    this.description,
    this.returnAvailable = false,
  });
}

final List<SellerProduct> dummySellerProducts = [
  SellerProduct(
    name: "Fresh Amul Milk 1L",
    images: [
      "assets/images/shop/product1_1.png",
      "assets/images/shop/product1_2.png",
    ],
    oldPrice: 70,
    newPrice: 62,
    receivedOrders: 42,
    offerAvailable: true,
    category: "Grocery",
    subCategory: "Dairy",
    rating: 4.6,
    description: "Farm fresh Amul milk, pasteurized and homogenized. Best before 2 days from date of packaging.",
    returnAvailable: false,
  ),
  SellerProduct(
    name: "Premium Basmati Rice 5kg",
    images: [
      "assets/images/shop/product2_1.png",
      "assets/images/shop/product2_2.png",
    ],
    oldPrice: 650,
    newPrice: 579,
    receivedOrders: 28,
    offerAvailable: true,
    category: "Grocery",
    subCategory: "Rice & Grains",
    rating: 4.4,
    description: "Extra long grain basmati rice perfect for biryani and daily use. Aged for 2 years.",
    returnAvailable: true,
  ),
  SellerProduct(
    name: "Fresh Potatoes 1kg",
    images: [
      "assets/images/shop/product3_1.png",
    ],
    oldPrice: 40,
    newPrice: 32,
    receivedOrders: 18,
    offerAvailable: false,
    category: "Grocery",
    subCategory: "Vegetables",
    rating: 4.2,
    description: "Farm fresh, unwashed potatoes. Locally sourced from organic farms.",
    returnAvailable: false,
  ),
  SellerProduct(
    name: "Arhar Dal (Toor Dal) 1kg",
    images: [
      "assets/images/shop/product4_1.png",
    ],
    oldPrice: 180,
    newPrice: 155,
    receivedOrders: 63,
    offerAvailable: true,
    category: "Grocery",
    subCategory: "Cooking Essentials",
    rating: 4.7,
    description: "Unpolished arhar dal rich in protein. Free from artificial colors and preservatives.",
    returnAvailable: true,
  ),
];
