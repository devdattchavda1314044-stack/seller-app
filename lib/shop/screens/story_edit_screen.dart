import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../models/shop_content_model.dart';
import '../utils/media_picker_util.dart';
import '../widgets/shots/content_video_player.dart';
import '../widgets/shots/category_selection_sheet.dart';

class StoryEditScreen extends StatefulWidget {
  final StoryItem story;
  final Function(StoryItem)? onStoryUpdated;

  const StoryEditScreen({
    super.key, 
    required this.story, 
    this.onStoryUpdated
  });

  @override
  State<StoryEditScreen> createState() => _StoryEditScreenState();
}

class _StoryEditScreenState extends State<StoryEditScreen> {
  String? _currentVideoPath;
  String? _selectedCategory;
  String? _selectedSubCategory;
  late TextEditingController _descController;
  final TextEditingController _hashtagSearchController = TextEditingController();

  List<String> _selectedHashtags = [];
  List<String> _filteredHashtags = [];

  final List<String> _availableHashtags = [
    '#udur', '#udurbusiness', '#shopping', '#shoplocal', '#grocery',
    '#groceries', '#fresh', '#freshfood', '#offer', '#offers',
    '#discount', '#sale', '#newarrival', '#trending', '#bestdeal',
    '#dailyneeds', '#electronics', '#fashion', '#homeliving', '#localbusiness'
  ];

  final Map<String, List<String>> _categoryData = {
    'Grocery': ['Dairy', 'Rice & Grains', 'Cooking Essentials', 'Snacks'],
    'Electronics': ['Audio', 'Mobile Accessories', 'Smart Devices'],
    'Fashion': ['Men\'s', 'Women\'s', 'Kids'],
    'Beauty': ['Makeup', 'Skincare', 'Fragrances'],
  };

  @override
  void initState() {
    super.initState();
    // Initialize with existing data. Fallback to asset URL if no local path exists.
    _currentVideoPath = widget.story.localVideoPath ?? widget.story.imageUrl;
    _selectedCategory = widget.story.category ?? 'Fashion'; // Fallback for dummy
    _selectedSubCategory = widget.story.subCategory ?? 'Women\'s'; // Fallback for dummy
    _descController = TextEditingController(text: widget.story.description ?? '');
    _selectedHashtags = List.from(widget.story.hashtags);
  }

  void _pickMedia() async {
    final path = await MediaPickerUtil.pickVideo(context);
    if (path != null) {
      setState(() {
        _currentVideoPath = path;
      });
    }
  }

  void _showCategoryPicker() async {
    final category = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategorySelectionSheet(
        title: 'Select Category',
        categories: _categoryData.keys.toList(),
        selectedCategory: _selectedCategory,
      ),
    );

    if (category != null && category != _selectedCategory) {
      setState(() {
        _selectedCategory = category;
        _selectedSubCategory = null; // Reset sub-category
      });
    }
  }

  void _showSubCategoryPicker() async {
    if (_selectedCategory == null) return;
    
    final subCategory = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategorySelectionSheet(
        title: 'Select Sub Category',
        categories: _categoryData[_selectedCategory] ?? [],
        selectedCategory: _selectedSubCategory,
      ),
    );

    if (subCategory != null) {
      setState(() {
        _selectedSubCategory = subCategory;
      });
    }
  }

  void _onHashtagSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _filteredHashtags = []);
      return;
    }
    final normalizedQuery = query.toLowerCase();
    setState(() {
      _filteredHashtags = _availableHashtags.where((tag) {
        return tag.toLowerCase().contains(normalizedQuery) && 
               !_selectedHashtags.contains(tag);
      }).toList();
    });
  }

  void _addHashtag(String tag) {
    if (!_selectedHashtags.contains(tag)) {
      setState(() {
        _selectedHashtags.add(tag);
        _hashtagSearchController.clear();
        _filteredHashtags = [];
      });
    }
  }

  void _removeHashtag(String tag) {
    setState(() {
      _selectedHashtags.remove(tag);
      _onHashtagSearchChanged(_hashtagSearchController.text);
    });
  }

  void _saveStory() {
    if (_currentVideoPath == null || _selectedCategory == null || _selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please ensure all required fields are filled.')),
      );
      return;
    }

    final isLocal = _currentVideoPath != widget.story.imageUrl;

    final updatedStory = StoryItem(
      id: widget.story.id,
      imageUrl: isLocal ? '' : widget.story.imageUrl,
      mediaType: MediaType.video,
      uploadedAt: widget.story.uploadedAt,
      isViewed: widget.story.isViewed,
      localVideoPath: isLocal ? _currentVideoPath : widget.story.localVideoPath,
      description: _descController.text,
      category: _selectedCategory,
      subCategory: _selectedSubCategory,
      hashtags: List.from(_selectedHashtags),
    );

    if (widget.onStoryUpdated != null) {
      widget.onStoryUpdated!(updatedStory);
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _descController.dispose();
    _hashtagSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
        title: const Text(
          'Edit Story',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveStory,
            child: const Text(
              'Save',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Preview Area
            _currentVideoPath == null ? _buildUploadPlaceholder() : _buildVideoPreview(),
            
            const SizedBox(height: 32),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              maxLength: 500,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tell your customers about this story...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildHashtagSection(),

            const SizedBox(height: 24),

            // Category Selection
            _buildSelectionField(
              label: 'Category',
              value: _selectedCategory,
              hint: 'Select Category',
              onTap: _showCategoryPicker,
            ),
            
            const SizedBox(height: 16),

            // Sub Category Selection
            _buildSelectionField(
              label: 'Sub Category',
              value: _selectedSubCategory,
              hint: _selectedCategory == null ? 'Select Category First' : 'Select Sub Category',
              onTap: _selectedCategory == null ? () {} : _showSubCategoryPicker,
              disabled: _selectedCategory == null,
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return GestureDetector(
      onTap: _pickMedia,
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.video_library, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add Story Video',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ContentVideoPlayer(
            videoPath: _currentVideoPath,
            autoPlay: true,
            looping: true,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _pickMedia,
              icon: const Icon(Icons.sync, size: 18),
              label: const Text('Replace', style: TextStyle(fontFamily: 'Poppins')),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: () => setState(() => _currentVideoPath = null),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Remove', style: TextStyle(fontFamily: 'Poppins')),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionField({
    required String label,
    required String? value,
    required String hint,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: disabled ? const Color(0xFF9CA3AF) : AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: disabled ? const Color(0xFFF3F4F6) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? hint,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: value == null ? const Color(0xFF9CA3AF) : AppColors.primaryText,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: disabled ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildHashtagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hashtags',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedHashtags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedHashtags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _removeHashtag(tag),
                      child: const Icon(Icons.close, size: 14, color: AppColors.primary),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ] else ...[
          const Text(
            'Add hashtags',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: _hashtagSearchController,
          onChanged: _onHashtagSearchChanged,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          decoration: InputDecoration(
            hintText: _selectedHashtags.isEmpty ? 'Type a hashtag...' : 'Add another hashtag',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            prefixIcon: const Icon(Icons.tag, color: Color(0xFF9CA3AF), size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        if (_hashtagSearchController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _filteredHashtags.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No matching hashtags',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredHashtags.length,
                    itemBuilder: (context, index) {
                      final tag = _filteredHashtags[index];
                      return InkWell(
                        onTap: () => _addHashtag(tag),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }
}
