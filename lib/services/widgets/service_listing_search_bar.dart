import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Search header for the services list — title, count, and the field.
///
/// Same shape as `SellerProductSearchBar`, counting "services" rather than
/// "items": a listing is a job someone books, not stock on a shelf.
class ServiceListingSearchBar extends StatefulWidget {
  final int serviceCount;
  final ValueChanged<String> onSearchChanged;

  const ServiceListingSearchBar({
    super.key,
    required this.serviceCount,
    required this.onSearchChanged,
  });

  @override
  State<ServiceListingSearchBar> createState() =>
      _ServiceListingSearchBarState();
}

class _ServiceListingSearchBarState extends State<ServiceListingSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
      widget.onSearchChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Services',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  height: 1.15,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '${widget.serviceCount} '
                  'service${widget.serviceCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTokens.fieldFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Search your services...',
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppTokens.mutedText,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: _hasFocus
                      ? AppColors.secondaryText
                      : AppTokens.mutedText,
                  size: 20,
                ),
                suffixIcon: _hasText
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppTokens.mutedText,
                        ),
                        onPressed: _controller.clear,
                      )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFB8B8B8),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF8A8A8A),
                    width: 1,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFB8B8B8),
                    width: 1,
                  ),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
              ),
              cursorColor: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
