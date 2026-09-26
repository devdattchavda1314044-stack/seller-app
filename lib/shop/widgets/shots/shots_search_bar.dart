import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ShotsSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const ShotsSearchBar({super.key, this.onChanged});

  @override
  State<ShotsSearchBar> createState() => _ShotsSearchBarState();
}

class _ShotsSearchBarState extends State<ShotsSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged?.call('');
    _focusNode.unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: (val) {
            setState(() {});
            widget.onChanged?.call(val);
          },
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
          decoration: InputDecoration(
            hintText: 'Search stories & shots...',
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9CA3AF),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 22,
              color: _isFocused ? AppColors.primaryText : const Color(0xFF9CA3AF),
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF6B7280),
                    ),
                    onPressed: _clearSearch,
                  )
                : null,
            filled: true,
            fillColor: _isFocused ? Colors.white : const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DB),
                width: 1.2,
              ),
            ),
            isDense: true,
          ),
          cursorColor: AppColors.primaryText,
        ),
      ),
    );
  }
}

