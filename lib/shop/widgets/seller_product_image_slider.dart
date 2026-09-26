import 'package:flutter/material.dart';

/// Full-width product image slider used inside the expanded accordion state.
class SellerProductImageSlider extends StatefulWidget {
  final List<String> images;

  const SellerProductImageSlider({super.key, required this.images});

  @override
  State<SellerProductImageSlider> createState() => _SellerProductImageSliderState();
}

class _SellerProductImageSliderState extends State<SellerProductImageSlider> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: 200,
        color: const Color(0xFFF4F5F7),
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, color: Color(0xFFBFC4CE), size: 32),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          // Image pages
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return Container(
                color: const Color(0xFFF4F5F7),
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  widget.images[index],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),

          // Image counter badge (top-right)
          if (widget.images.length > 1)
            Positioned(
              top: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_currentIndex + 1}/${widget.images.length}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ),

          // Bottom progress bar (instead of dots for a more modern, premium feel)
          if (widget.images.length > 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                children: List.generate(widget.images.length, (index) {
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : 1,
                        right: index == widget.images.length - 1 ? 0 : 1,
                      ),
                      color: _currentIndex == index
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFE2E4E9),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
