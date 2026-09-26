import 'package:flutter/material.dart';

/// A list of real product images from the shop assets folder.
/// Defined as a top-level constant so it is created once.
const List<String> _productImages = [
  'assets/images/shop/lauki_sabzi_01.png',
  'assets/images/shop/rajma_rice_01.png',
  'assets/images/shop/potatoes-with-leaves-on-transparent-background-background-png.png',
  'assets/images/shop/imgi_2_801_1643446838759.png',
  'assets/images/shop/imgi_3_1937_1643446905991.png',
  'assets/images/shop/imgi_4_722_1678103275835.png',
  'assets/images/shop/imgi_5_1128_1643637211527.png',
  'assets/images/shop/imgi_6_395_1668582176947.png',
  'assets/images/shop/imgi_17_c0417f6a-c7e0-4452-a1d5-d0b18bca5d7d.png',
  'assets/images/shop/imgi_18_6880ee6a-dc90-481c-b78f-313fd1183049.png',
  'assets/images/shop/imgi_19_24e46c9b-8f2f-4d53-aada-8f168e29b7a8.png',
  'assets/images/shop/imgi_20_8bddb35b-f8f5-4b0c-9771-f3a4aa024e98.png',
  'assets/images/shop/imgi_21_697487a7-6c1b-4a5b-9c07-286f0970c1c7.png',
  'assets/images/shop/imgi_22_7914ccda-af50-40dd-b7b1-bc3f1bf60d30.png',
];

/// Efficiently scrolling product marquee with 3 rows moving in alternating directions.
///
/// Architecture:
/// - Each row is an isolated [_MarqueeRow] with its own [AnimationController].
/// - Animation rebuilds ONLY the [Transform.translate] wrapper, NOT the product card widgets.
/// - Product card widgets are built once in [initState] and cached.
/// - The entire marquee is wrapped in a [RepaintBoundary] so animation repaints
///   do not dirty the parent login screen.
class ProductMarquee extends StatelessWidget {
  final double height;

  const ProductMarquee({super.key, this.height = 240.0});

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic row height and card size based on available height
    final double rowHeight = (height / 3.15).clamp(52.0, 85.0);
    final double cardSize = (rowHeight - 10.0).clamp(42.0, 75.0);

    // RepaintBoundary isolates marquee repaints from the rest of the login screen
    return RepaintBoundary(
      child: ClipRect(
        child: Container(
          color: Colors.white, // Pure white background
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MarqueeRow(
                startIndex: 0,
                moveLeft: true,
                durationSeconds: 35,
                rowHeight: rowHeight,
                cardSize: cardSize,
              ),
              _MarqueeRow(
                startIndex: 5,
                moveLeft: false,
                durationSeconds: 40,
                rowHeight: rowHeight,
                cardSize: cardSize,
              ),
              _MarqueeRow(
                startIndex: 10,
                moveLeft: true,
                durationSeconds: 30,
                rowHeight: rowHeight,
                cardSize: cardSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarqueeRow extends StatefulWidget {
  final int startIndex;
  final bool moveLeft;
  final int durationSeconds;
  final double rowHeight;
  final double cardSize;

  const _MarqueeRow({
    required this.startIndex,
    required this.moveLeft,
    required this.durationSeconds,
    required this.rowHeight,
    required this.cardSize,
  });

  @override
  State<_MarqueeRow> createState() => _MarqueeRowState();
}

class _MarqueeRowState extends State<_MarqueeRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<String> _images;

  // Pre-built stacked row — built once in initState
  late final Widget _stackedRow;

  double get _itemWidth => widget.cardSize + 16.0; // cardSize + 8 padding each side

  @override
  void initState() {
    super.initState();

    // Create a deterministic image order for this row based on startIndex
    _images = List<String>.generate(
      _productImages.length,
      (i) => _productImages[(i + widget.startIndex) % _productImages.length],
    );

    // Build positioned product cards ONCE and cache them in a Stack.
    // Stack allows all cards to exist in an extended horizontal plane without RenderFlex overflow.
    final List<Widget> positionedCards = [];
    int globalIndex = 0;
    for (int setIndex = 0; setIndex < 3; setIndex++) {
      for (int i = 0; i < _images.length; i++) {
        final double leftPos = globalIndex * _itemWidth + 8.0;
        positionedCards.add(
          Positioned(
            left: leftPos,
            top: 0,
            width: widget.cardSize,
            height: widget.cardSize,
            child: _ProductCard(
              key: ValueKey('${setIndex}_$i'),
              imagePath: _images[i],
              size: widget.cardSize,
            ),
          ),
        );
        globalIndex++;
      }
    }

    _stackedRow = Stack(
      clipBehavior: Clip.none,
      children: positionedCards,
    );

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSeconds),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double singleSetWidth = _images.length * _itemWidth;

    return SizedBox(
      height: widget.rowHeight,
      child: AnimatedBuilder(
        animation: _controller,
        // Pass _stackedRow as static child — AnimatedBuilder will NOT rebuild it
        child: _stackedRow,
        builder: (context, child) {
          final double rawOffset = _controller.value * singleSetWidth;
          final double offset = widget.moveLeft
              ? -rawOffset
              : rawOffset - singleSetWidth;

          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
      ),
    );
  }
}

/// Individual product card — const-constructible and cached by the marquee row.
class _ProductCard extends StatelessWidget {
  final String imagePath;
  final double size;

  const _ProductCard({
    super.key,
    required this.imagePath,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = (size * 0.22).clamp(10.0, 18.0);
    final padding = (size * 0.12).clamp(5.0, 10.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: EdgeInsets.all(padding),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        // Use cacheWidth to avoid decoding full-resolution images
        cacheWidth: (size * 2).round(), // 2x for high-DPI screens
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
          size: 20,
        ),
      ),
    );
  }
}
