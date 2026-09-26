

enum MediaType { image, video }

class StoryItem {
  final String id;
  final String imageUrl;
  final MediaType mediaType;
  final DateTime uploadedAt;
  bool isViewed;
  final String? localVideoPath;
  final String? videoUrl;
  final String? description;
  final String? category;
  final String? subCategory;
  final List<String> hashtags;

  StoryItem({
    required this.id,
    required this.imageUrl,
    this.mediaType = MediaType.image,
    required this.uploadedAt,
    this.isViewed = false,
    this.localVideoPath,
    this.videoUrl,
    this.description,
    this.category,
    this.subCategory,
    this.hashtags = const [],
  });

  String get effectiveVideoPath => localVideoPath ?? videoUrl ?? imageUrl;
}

class StoryGroup {
  final String id;
  final String groupName;
  final String coverImageUrl;
  final List<StoryItem> stories;
  final bool isHighlight; // E.g., true if it's a pinned highlight rather than temporary 24h

  StoryGroup({
    required this.id,
    required this.groupName,
    required this.coverImageUrl,
    required this.stories,
    this.isHighlight = false,
  });

  bool get allViewed => stories.every((story) => story.isViewed);
}

class ShotItem {
  final String id;
  final String title;
  final String mediaUrl;
  final MediaType mediaType;
  final int views;
  final int likes;
  final DateTime uploadedAt;
  final String status; // e.g. "Active", "Processing", "Rejected"
  final String? localVideoPath;
  final String? videoUrl;
  final String? category;
  final String? subCategory;

  ShotItem({
    required this.id,
    required this.title,
    required this.mediaUrl,
    this.mediaType = MediaType.image,
    required this.views,
    required this.likes,
    required this.uploadedAt,
    this.status = 'Active',
    this.localVideoPath,
    this.videoUrl,
    this.category,
    this.subCategory,
  });

  String get effectiveVideoPath => localVideoPath ?? videoUrl ?? mediaUrl;
}

// ---------------------------------------------------------------------------
// DUMMY DATA
// ---------------------------------------------------------------------------

final List<StoryGroup> dummyStoryGroups = [];

final List<ShotItem> dummyShots = [
  ShotItem(
    id: 'shot_1',
    title: 'Introducing the new Summer Collection! 🌞👗',
    mediaUrl: 'assets/images/shop/product1_1.png',
    mediaType: MediaType.image,
    views: 1240,
    likes: 342,
    uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  ShotItem(
    id: 'shot_2',
    title: 'How we pack your orders 📦✨',
    mediaUrl: 'assets/images/shop/product2_1.png',
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    mediaType: MediaType.video,
    views: 8900,
    likes: 1205,
    uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  ShotItem(
    id: 'shot_3',
    title: 'Sneak peek at our upcoming designs...',
    mediaUrl: 'assets/images/shop/product3_1.png',
    mediaType: MediaType.image,
    views: 842,
    likes: 112,
    uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  ShotItem(
    id: 'shot_4',
    title: 'Styling tips for the weekend! 💃',
    mediaUrl: 'assets/images/shop/product4_1.png',
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    mediaType: MediaType.video,
    views: 3200,
    likes: 670,
    uploadedAt: DateTime.now().subtract(const Duration(days: 6)),
  ),
  ShotItem(
    id: 'shot_5',
    title: 'Customer review: "Best quality ever!" ⭐⭐⭐⭐⭐',
    mediaUrl: 'assets/images/shop/product5_1.png',
    mediaType: MediaType.image,
    views: 1540,
    likes: 230,
    uploadedAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  ShotItem(
    id: 'shot_6',
    title: 'Limited Edition pieces available now',
    mediaUrl: 'assets/images/shop/product6_1.png',
    mediaType: MediaType.image,
    views: 930,
    likes: 150,
    uploadedAt: DateTime.now().subtract(const Duration(days: 8)),
  ),
  ShotItem(
    id: 'shot_7',
    title: 'Behind the scenes at our workshop 🧵',
    mediaUrl: 'assets/images/shop/product7_1.png',
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    mediaType: MediaType.video,
    views: 4500,
    likes: 890,
    uploadedAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  ShotItem(
    id: 'shot_8',
    title: 'Flash Sale! 50% off selected items today only! ⚡',
    mediaUrl: 'assets/images/shop/product8_1.png',
    mediaType: MediaType.image,
    views: 5600,
    likes: 1200,
    uploadedAt: DateTime.now().subtract(const Duration(days: 12)),
  ),
];

