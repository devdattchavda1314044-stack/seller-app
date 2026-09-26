import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../models/shop_content_model.dart';
import '../utils/media_picker_util.dart';
import '../widgets/shots/content_video_player.dart';
import '../widgets/shots/category_selection_sheet.dart';

class ShotEditScreen extends StatefulWidget {
  final ShotItem shot;
  final Function(ShotItem)? onShotUpdated;

  const ShotEditScreen({
    super.key, 
    required this.shot, 
    this.onShotUpdated
  });

  @override
  State<ShotEditScreen> createState() => _ShotEditScreenState();
}

class _ShotEditScreenState extends State<ShotEditScreen> {
  String? _currentVideoPath;
  String? _selectedCategory;
  String? _selectedSubCategory;
  late TextEditingController _descController;

  final Map<String, List<String>> _categoryData = {
    'Grocery': ['Dairy', 'Rice & Grains', 'Cooking Essentials', 'Snacks'],
    'Electronics': ['Audio', 'Mobile Accessories', 'Smart Devices'],
    'Fashion': ['Men\'s', 'Women\'s', 'Kids'],
    'Beauty': ['Makeup', 'Skincare', 'Fragrances'],
  };

  @override
  void initState() {
    super.initState();
    _currentVideoPath = widget.shot.localVideoPath ?? widget.shot.mediaUrl;
    _selectedCategory = widget.shot.category ?? 'Fashion';
    _selectedSubCategory = widget.shot.subCategory ?? 'Women\'s';
    _descController = TextEditingController(text: widget.shot.title);
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
        title: 'Select Shot Category',
        categories: _categoryData.keys.toList(),
        selectedCategory: _selectedCategory,
      ),
    );

    if (category != null && category != _selectedCategory) {
      setState(() {
        _selectedCategory = category;
        _selectedSubCategory = null; 
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

  void _saveShot() {
    if (_currentVideoPath == null || _selectedCategory == null || _selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please ensure all required fields are filled.')),
      );
      return;
    }

    final isLocal = _currentVideoPath != widget.shot.mediaUrl;

    final updatedShot = ShotItem(
      id: widget.shot.id,
      title: _descController.text.isNotEmpty ? _descController.text : 'Updated Shot',
      mediaUrl: isLocal ? '' : widget.shot.mediaUrl,
      mediaType: MediaType.video,
      views: widget.shot.views,
      likes: widget.shot.likes,
      uploadedAt: widget.shot.uploadedAt,
      status: widget.shot.status,
      localVideoPath: isLocal ? _currentVideoPath : widget.shot.localVideoPath,
      category: _selectedCategory,
      subCategory: _selectedSubCategory,
    );

    if (widget.onShotUpdated != null) {
      widget.onShotUpdated!(updatedShot);
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
        title: const Text(
          'Edit Shot',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: _saveShot,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Creator Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _currentVideoPath == null ? _buildUploadPlaceholder() : _buildVideoPreview(),
            ),
            
            const SizedBox(height: 24),

            // Form Fields
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Caption',
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
                    maxLines: 3,
                    maxLength: 100,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Write something about this shot...',
                      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                      contentPadding: const EdgeInsets.all(16),
                      filled: true,
                      fillColor: Colors.white,
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
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildSelectionField(
                    label: 'Category',
                    value: _selectedCategory,
                    hint: 'Select Category',
                    onTap: _showCategoryPicker,
                  ),
                  
                  const SizedBox(height: 16),

                  _buildSelectionField(
                    label: 'Sub Category',
                    value: _selectedSubCategory,
                    hint: _selectedCategory == null ? 'Select Category First' : 'Select Sub Category',
                    onTap: _selectedCategory == null ? () {} : _showSubCategoryPicker,
                    disabled: _selectedCategory == null,
                  ),
                ],
              ),
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
        height: 280, 
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.movie_creation_outlined, color: AppColors.accent, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add Shot Video',
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
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 320,
            child: ContentVideoPlayer(
              videoPath: _currentVideoPath,
              autoPlay: true,
              looping: true,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickMedia,
                icon: const Icon(Icons.sync, size: 18),
                label: const Text('Replace', style: TextStyle(fontFamily: 'Poppins')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _currentVideoPath = null),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Remove', style: TextStyle(fontFamily: 'Poppins')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: disabled ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: disabled ? const Color(0xFFF3F4F6) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: disabled ? Colors.transparent : const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? hint,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: value == null ? FontWeight.w400 : FontWeight.w500,
                    color: value == null ? const Color(0xFF9CA3AF) : AppColors.primaryText,
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  color: disabled ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
