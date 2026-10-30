/// Data models for shop order items.
library;

class ShopOrderProduct {
  final String name;
  final int quantity;
  final int price;

  const ShopOrderProduct({
    required this.name,
    required this.quantity,
    required this.price,
  });
}

class ShopOrder {
  final String id;
  final String customerName;
  final String customerPhone;
  final List<ShopOrderProduct> products;
  final String date;
  final String time;
  final String sellerAddress;

  const ShopOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.products,
    required this.date,
    required this.time,
    required this.sellerAddress,
  });

  int get totalPrice => products.fold(0, (sum, p) => sum + p.price);
}

/// Static mock orders for the Shop Dashboard.
final List<ShopOrder> initialShopOrders = [
  ShopOrder(
    id: '#1024',
    customerName: 'Rahul Patel',
    customerPhone: '+91 9876543210',
    products: [
      ShopOrderProduct(name: 'Milk', quantity: 2, price: 60),
      ShopOrderProduct(name: 'Bread', quantity: 1, price: 40),
    ],
    date: '05 Sep 2026',
    time: '09:42 PM',
    sellerAddress: 'UDUR Family Store\nWaghawadi Road,\nBhavnagar, Gujarat - 364001',
  ),
  ShopOrder(
    id: '#1025',
    customerName: 'Priya Sharma',
    customerPhone: '+91 9123456789',
    products: [
      ShopOrderProduct(name: 'Basmati Rice', quantity: 1, price: 220),
      ShopOrderProduct(name: 'Cooking Oil', quantity: 1, price: 180),
      ShopOrderProduct(name: 'Sugar', quantity: 2, price: 90),
    ],
    date: '05 Sep 2026',
    time: '10:15 AM',
    sellerAddress: 'UDUR Family Store\nWaghawadi Road,\nBhavnagar, Gujarat - 364001',
  ),
  ShopOrder(
    id: '#1026',
    customerName: 'Amit Kumar',
    customerPhone: '+91 9988776655',
    products: [
      ShopOrderProduct(name: 'Eggs (12 pack)', quantity: 1, price: 96),
      ShopOrderProduct(name: 'Butter', quantity: 1, price: 55),
    ],
    date: '05 Sep 2026',
    time: '11:30 AM',
    sellerAddress: 'UDUR Family Store\nWaghawadi Road,\nBhavnagar, Gujarat - 364001',
  ),
  ShopOrder(
    id: '#1027',
    customerName: 'Neha Verma',
    customerPhone: '+91 9876512345',
    products: [
      ShopOrderProduct(name: 'Tomatoes', quantity: 2, price: 60),
      ShopOrderProduct(name: 'Onions', quantity: 3, price: 75),
      ShopOrderProduct(name: 'Potatoes', quantity: 2, price: 50),
    ],
    date: '05 Sep 2026',
    time: '01:05 PM',
    sellerAddress: 'UDUR Family Store\nWaghawadi Road,\nBhavnagar, Gujarat - 364001',
  ),
  ShopOrder(
    id: '#1028',
    customerName: 'Sanjay Gupta',
    customerPhone: '+91 8765432109',
    products: [
      ShopOrderProduct(name: 'Cold Drink (2L)', quantity: 2, price: 170),
      ShopOrderProduct(name: 'Chips', quantity: 3, price: 90),
    ],
    date: '05 Sep 2026',
    time: '03:48 PM',
    sellerAddress: 'UDUR Family Store\nWaghawadi Road,\nBhavnagar, Gujarat - 364001',
  ),
  ShopOrder(
    id: '#1029',
    customerName: 'Kavita Singh',
    customerPhone: '+91 7654321098',
    products: [
      ShopOrderProduct(name: 'Wheat Flour', quantity: 1, price: 340),
      ShopOrderProduct(name: 'Ghee', quantity: 1, price: 560),
      ShopOrderProduct(name: 'Tea Leaves', quantity: 1, price: 180),
    ],
    date: '05 Sep 2026',
    time: '05:22 PM',
    sellerAddress: 'UDUR Family Store\nWaghawadi Road,\nBhavnagar, Gujarat - 364001',
  ),
];
