import 'package:flutter/material.dart';
import '../models/shop_content_model.dart';
import '../widgets/shots/shots_search_bar.dart';
import '../widgets/shots/shots_content_overview.dart';
import '../widgets/shots/stories_section.dart';
import '../widgets/shots/shots_list_section.dart';
import '../widgets/shots/expandable_add_fab.dart';
import '../widgets/shots/content_video_player.dart';
import '../../core/theme/app_colors.dart';
import 'story_add_screen.dart';
import 'story_edit_screen.dart';
import 'shot_add_screen.dart';
import 'shot_edit_screen.dart';

class ShopShotsScreen extends StatefulWidget {
  const ShopShotsScreen({super.key});

  @override
  State<ShopShotsScreen> createState() => _ShopShotsScreenState();
}

class _ShopShotsScreenState extends State<ShopShotsScreen> {
  late List<StoryGroup> _stories;
  late List<ShotItem> _shots;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _stories = List.from(dummyStoryGroups);
    _shots = List.from(dummyShots);
  }

  List<StoryGroup> get _filteredStories {
    if (_searchQuery.isEmpty) return _stories;
    final query = _searchQuery.toLowerCase();
    return _stories.where((s) => s.groupName.toLowerCase().contains(query)).toList();
  }

  List<ShotItem> get _filteredShots {
    if (_searchQuery.isEmpty) return _shots;
    final query = _searchQuery.toLowerCase();
    return _shots.where((s) => s.title.toLowerCase().contains(query)).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _navigateToAddStory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryAddScreen(
          onStoryAdded: (newStory) {
            setState(() {
              _stories.insert(0,
                StoryGroup(
                  id: newStory.id,
                  groupName: 'Story',
                  coverImageUrl: '',
                  stories: [newStory],
                ),
              );
            });
          },
        ),
      ),
    );
  }

  void _navigateToAddShot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShotAddScreen(
          onShotAdded: (newShot) {
            setState(() {
              _shots.insert(0, newShot);
            });
          },
        ),
      ),
    );
  }

  void _navigateToEditShot(ShotItem shot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShotEditScreen(
          shot: shot,
          onShotUpdated: (updatedShot) {
            setState(() {
              final index = _shots.indexWhere((s) => s.id == updatedShot.id);
              if (index != -1) {
                _shots[index] = updatedShot;
              }
            });
          },
        ),
      ),
    );
  }

  void _deleteShot(ShotItem shot) {
    setState(() {
      _shots.removeWhere((s) => s.id == shot.id);
    });
  }

  void _showStoryPreview(StoryGroup group) {
    // Show immersive bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) {
        final story = group.stories.isNotEmpty ? group.stories.first : null;
        if (story == null) return const SizedBox();
        
        final videoPath = story.effectiveVideoPath;
        
        return SizedBox.expand(
          child: SafeArea(
            child: Stack(
            children: [
              Positioned.fill(
                child: ContentVideoPlayer(
                  videoPath: videoPath,
                  autoPlay: true,
                  looping: true,
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),

              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.groupName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0,2))],
                      ),
                    ),
                    if (story.description != null && story.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        story.description!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0,2))],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ));
      },
    );
  }

  void _showStoryManagementSheet(StoryGroup group) {
    final story = group.stories.isNotEmpty ? group.stories.first : null;
    if (story == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: ContentVideoPlayer(
                            videoPath: story.effectiveVideoPath,
                            autoPlay: true,
                            looping: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Information
                      const Text(
                        'Description',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (story.description != null && story.description!.isNotEmpty) ? story.description! : 'No description provided.',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.primaryText),
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Category',
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  story.category ?? 'Uncategorized',
                                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sub Category',
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  story.subCategory ?? '-',
                                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (story.hashtags.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Hashtags',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: story.hashtags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary),
                            ),
                          )).toList(),
                        ),
                      ],
                      const SizedBox(height: 32),
                      const Divider(color: Color(0xFFE5E7EB), height: 1),
                      const SizedBox(height: 16),
                      
                      // Actions
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit_outlined, color: AppColors.primaryText, size: 22),
                        ),
                        title: const Text('Edit this story', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoryEditScreen(
                                story: story,
                                onStoryUpdated: (updatedStory) {
                                  setState(() {
                                    final index = group.stories.indexWhere((s) => s.id == updatedStory.id);
                                    if (index != -1) {
                                      group.stories[index] = updatedStory;
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 22),
                        ),
                        title: const Text('Remove this story', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                        onTap: () {
                          _confirmDeleteStory(ctx, group, story);
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteStory(BuildContext sheetContext, StoryGroup group, StoryItem story) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Story?', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18)),
          content: const Text('This story will be removed from your content.', style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF6B7280))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogCtx); // close dialog
                Navigator.pop(sheetContext); // close bottom sheet
                setState(() {
                  group.stories.removeWhere((s) => s.id == story.id);
                  if (group.stories.isEmpty) {
                    _stories.removeWhere((g) => g.id == group.id);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Delete', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
            ),
          ],
        );
      },
    );
  }

  void _showShotPreview(ShotItem shot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) {
        final videoPath = shot.effectiveVideoPath;
        return SizedBox.expand(
          child: SafeArea(
            child: Stack(
            children: [
              Positioned.fill(
                child: ContentVideoPlayer(
                  videoPath: videoPath,
                  autoPlay: true,
                  looping: true,
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 26),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _navigateToEditShot(shot);
                  },
                ),
              ),
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shot.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0,2))],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${shot.views}',
                          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.favorite, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${shot.likes}',
                          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredStories = _filteredStories;
    final filteredShots = _filteredShots;
    
    // Active story groups count
    final activeStoriesCount = _stories.where((g) => !g.allViewed).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header padding
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Content Overview
                SliverToBoxAdapter(
                  child: ShotsContentOverview(
                    totalStories: activeStoriesCount,
                    totalShots: _shots.length,
                  ),
                ),

                // Spacing
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Search Bar
                SliverToBoxAdapter(
                  child: ShotsSearchBar(
                    onChanged: _onSearchChanged,
                  ),
                ),

                // Spacing
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Stories Section (Horizontal Scroll)
                if (filteredStories.isNotEmpty || _searchQuery.isEmpty)
                  SliverToBoxAdapter(
                    child: StoriesSection(
                      storyGroups: filteredStories,
                      onAddStoryTap: _navigateToAddStory,
                      onStoryTap: _showStoryPreview,
                      onStoryLongPress: _showStoryManagementSheet,
                    ),
                  ),

                // Spacing
                if (filteredStories.isNotEmpty || _searchQuery.isEmpty)
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // Shots Title
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shots',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Showcase your products, offers & moments',
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
                ),

                // Spacing
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Shots List
                ShotsListSection(
                  shots: filteredShots,
                  onShotTap: _showShotPreview,
                  onEditShot: _navigateToEditShot,
                  onDeleteShot: _deleteShot,
                ),

                // Bottom padding so FAB doesn't hide content
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
          
          // Positioned FAB
          Positioned(
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20,
            child: ExpandableAddFab(
              onAddStory: _navigateToAddStory,
              onAddShot: _navigateToAddShot,
            ),
          ),
        ],
      ),
    );
  }
}
