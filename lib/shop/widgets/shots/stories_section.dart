import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../models/shop_content_model.dart';

class StoriesSection extends StatelessWidget {
  final List<StoryGroup> storyGroups;
  final VoidCallback onAddStoryTap;
  final void Function(StoryGroup group) onStoryTap;
  final void Function(StoryGroup group)? onStoryLongPress;

  const StoriesSection({
    super.key,
    required this.storyGroups,
    required this.onAddStoryTap,
    required this.onStoryTap,
    this.onStoryLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stories',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Share quick updates with your customers',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (storyGroups.isEmpty)
          _buildEmptyState()
        else
          SizedBox(
            height: 90,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: storyGroups.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddStoryBtn();
                }
                final group = storyGroups[index - 1];
                return _buildStoryItem(group);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        ),
        child: Column(
          children: [
            const Icon(Icons.amp_stories_rounded, color: Color(0xFF9CA3AF), size: 36),
            const SizedBox(height: 12),
            const Text(
              'No Stories Yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Share updates, offers and moments with your customers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAddStoryTap,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Story', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddStoryBtn() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: onAddStoryTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5, style: BorderStyle.solid),
                color: const Color(0xFFF9FAFB),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Color(0xFF4B5563),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add Story',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(StoryGroup group) {
    return _AnimatedStoryItem(
      group: group,
      onTap: () => onStoryTap(group),
      onLongPress: onStoryLongPress != null ? () => onStoryLongPress!(group) : null,
    );
  }
}

class _AnimatedStoryItem extends StatefulWidget {
  final StoryGroup group;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _AnimatedStoryItem({
    required this.group,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<_AnimatedStoryItem> createState() => _AnimatedStoryItemState();
}

class _AnimatedStoryItemState extends State<_AnimatedStoryItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool allViewed = widget.group.allViewed;
    final int storyCount = widget.group.stories.length;

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        onLongPress: () {
          _controller.reverse();
          if (widget.onLongPress != null) widget.onLongPress!();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Premium ring
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: allViewed
                          ? const LinearGradient(
                              colors: [Color(0xFFE5E7EB), Color(0xFFE5E7EB)],
                            )
                          : const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Color(0xFFFF7A00), Color(0xFFE11D48), Color(0xFF4F46E5)],
                            ),
                    ),
                  ),
                  // Inner white padding
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  // Image
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.group.coverImageUrl.isEmpty ? const Color(0xFFE5E7EB) : null,
                      image: widget.group.coverImageUrl.isNotEmpty ? DecorationImage(
                        image: AssetImage(widget.group.coverImageUrl),
                        fit: BoxFit.cover,
                        colorFilter: allViewed
                            ? ColorFilter.mode(Colors.white.withValues(alpha: 0.3), BlendMode.lighten)
                            : null,
                      ) : null,
                    ),
                    child: widget.group.coverImageUrl.isEmpty 
                        ? const Icon(Icons.video_file, color: Color(0xFF9CA3AF), size: 24) 
                        : null,
                  ),
                  // Multi-story indicator
                  if (storyCount > 1)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          '$storyCount',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 64,
                child: Text(
                  widget.group.groupName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: allViewed ? FontWeight.w400 : FontWeight.w500,
                    color: allViewed ? const Color(0xFF6B7280) : AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
