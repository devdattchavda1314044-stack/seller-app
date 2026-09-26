import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../models/offer_model.dart';
import '../models/seller_product_model.dart';
import '../utils/media_picker_util.dart';

class OfferAddEditScreen extends StatefulWidget {
  final OfferModel? offer;

  const OfferAddEditScreen({super.key, this.offer});

  @override
  State<OfferAddEditScreen> createState() => _OfferAddEditScreenState();
}

class _OfferAddEditScreenState extends State<OfferAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _oldPriceController = TextEditingController();
  final _newPriceController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<String> _images = [];
  String _category = '';
  String _subCategory = '';
  DateTime? _startDate;
  DateTime? _endDate;
  OfferSourceType _sourceType = OfferSourceType.manual;
  String? _sourceProductId;

  bool get _isEditMode => widget.offer != null;

  // Same categories as existing product category selector
  final Map<String, List<String>> _categoryData = {
    'Grocery': ['Dairy', 'Rice & Grains', 'Vegetables', 'Cooking Essentials'],
    'Electronics': ['Mobiles', 'Accessories', 'Laptops', 'Audio'],
    'Fashion': ['Men', 'Women', 'Kids'],
  };

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final o = widget.offer!;
      _titleController.text = o.title;
      _oldPriceController.text = o.oldPrice.toStringAsFixed(0);
      _newPriceController.text = o.newPrice.toStringAsFixed(0);
      _descriptionController.text = o.description ?? '';
      _images = List.from(o.images);
      _category = o.category;
      _subCategory = o.subCategory;
      _startDate = o.startDate;
      _endDate = o.endDate;
      _sourceType = o.sourceType;
      _sourceProductId = o.sourceProductId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _oldPriceController.dispose();
    _newPriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showCreationMethodSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'How do you want to create this offer?',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryText),
            ),
            const SizedBox(height: 20),
            _buildMethodTile(
              icon: Icons.inventory_2_outlined,
              title: 'Use Existing Product',
              subtitle: 'Pick from your product list and customize offer details',
              onTap: () {
                Navigator.pop(ctx);
                _showExistingProductPicker();
              },
            ),
            const SizedBox(height: 12),
            _buildMethodTile(
              icon: Icons.edit_note_outlined,
              title: 'Create Manually',
              subtitle: 'Enter all details from scratch',
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _sourceType = OfferSourceType.manual;
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.secondaryText)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.secondaryText),
          ],
        ),
      ),
    );
  }

  void _showExistingProductPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Text(
                'Select a Product',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryText),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemCount: dummySellerProducts.length,
                itemBuilder: (context, index) {
                  final product = dummySellerProducts[index];
                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      _populateFromProduct(product);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              product.images.isNotEmpty ? product.images.first : '',
                              width: 56, height: 56, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 56, height: 56,
                                color: const Color(0xFFF3F4F6),
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
                                const SizedBox(height: 4),
                                Text('₹${product.newPrice.toStringAsFixed(0)}  •  ${product.category}',
                                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.secondaryText)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.secondaryText, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _populateFromProduct(SellerProduct product) {
    setState(() {
      _sourceType = OfferSourceType.existingProduct;
      _sourceProductId = product.name; // Using name as a proxy ID
      _titleController.text = product.name;
      _images = List.from(product.images);
      _oldPriceController.text = product.oldPrice.toStringAsFixed(0);
      _newPriceController.text = product.newPrice.toStringAsFixed(0);
      _category = product.category;
      _subCategory = product.subCategory;
      _descriptionController.text = product.description ?? '';
    });
  }

  Future<void> _pickImages() async {
    final paths = await MediaPickerUtil.pickImages(context);
    if (paths.isNotEmpty) {
      setState(() {
        _images.addAll(paths);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now.add(const Duration(days: 7))),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Auto-clear end date if it's before new start date
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Select Category',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categoryData.keys.length,
                    itemBuilder: (context, index) {
                      final cat = _categoryData.keys.elementAt(index);
                      final subs = _categoryData[cat]!;
                      return Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: AppColors.primary,
                          collapsedIconColor: const Color(0xFF6B7280),
                          title: Text(
                            cat,
                            style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600,
                              color: cat == _category ? AppColors.primary : AppColors.primaryText,
                            ),
                          ),
                          children: subs.map((sub) {
                            final isSelected = cat == _category && sub == _subCategory;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 40),
                              title: Text(
                                sub,
                                style: TextStyle(
                                  fontFamily: 'Poppins', fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? AppColors.primary : const Color(0xFF4B5563),
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _category = cat;
                                  _subCategory = sub;
                                });
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveOffer() {
    if (!_formKey.currentState!.validate()) return;

    final oldPrice = double.tryParse(_oldPriceController.text) ?? 0;
    final newPrice = double.tryParse(_newPriceController.text) ?? 0;

    if (newPrice >= oldPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New price must be less than old price.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_category.isEmpty || _subCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.'), backgroundColor: Colors.red),
      );
      return;
    }

    final offer = OfferModel(
      id: widget.offer?.id,
      title: _titleController.text.trim(),
      images: _images,
      oldPrice: oldPrice,
      newPrice: newPrice,
      category: _category,
      subCategory: _subCategory,
      startDate: _startDate!,
      endDate: _endDate!,
      createdAt: widget.offer?.createdAt,
      sourceType: _sourceType,
      sourceProductId: _sourceProductId,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    );

    Navigator.pop(context, offer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit Offer' : 'Add Offer',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryText),
        ),
        centerTitle: true,
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.auto_awesome_outlined, color: AppColors.primary),
              tooltip: 'Choose Creation Method',
              onPressed: _showCreationMethodSheet,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── IMAGES SECTION ──
                    _buildSectionLabel('Product Images'),
                    const SizedBox(height: 12),
                    _buildImageGallery(),
                    const SizedBox(height: 24),

                    // ── TITLE ──
                    _buildSectionLabel('Offer Title'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, color: AppColors.primaryText),
                      decoration: _inputDecoration('e.g. Weekend Grocery Special'),
                    ),
                    const SizedBox(height: 24),

                    // ── PRICING ──
                    _buildSectionLabel('Pricing'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _oldPriceController,
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, color: AppColors.primaryText),
                            decoration: _inputDecoration('Old Price (₹)'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _newPriceController,
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, color: AppColors.primaryText),
                            decoration: _inputDecoration('New Price (₹)'),
                          ),
                        ),
                      ],
                    ),
                    // Discount preview
                    Builder(
                      builder: (_) {
                        final oldP = double.tryParse(_oldPriceController.text) ?? 0;
                        final newP = double.tryParse(_newPriceController.text) ?? 0;
                        if (oldP > 0 && newP > 0 && newP < oldP) {
                          final pct = ((oldP - newP) / oldP * 100).toStringAsFixed(0);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Discount: $pct% OFF',
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── CATEGORY ──
                    _buildSectionLabel('Category'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _showCategoryPicker,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(color: Color(0xFFEEF2FF), shape: BoxShape.circle),
                              child: const Icon(Icons.category_rounded, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _category.isEmpty ? 'Select Category' : _category,
                                    style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600,
                                      color: _category.isEmpty ? AppColors.secondaryText : AppColors.primaryText,
                                    ),
                                  ),
                                  if (_subCategory.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(_subCategory, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Color(0xFF6B7280))),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9CA3AF)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── OFFER PERIOD ──
                    _buildSectionLabel('Offer Period'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateTile(
                            label: 'Start Date',
                            date: _startDate,
                            onTap: () => _pickDate(isStart: true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateTile(
                            label: 'End Date',
                            date: _endDate,
                            onTap: () => _pickDate(isStart: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── DESCRIPTION ──
                    _buildSectionLabel('Description (Optional)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, color: AppColors.primaryText),
                      decoration: _inputDecoration('Describe the offer...').copyWith(
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          // ── STICKY CTA ──
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: const Color(0xFFE5E7EB).withValues(alpha: 0.5))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  _isEditMode ? 'Update Offer' : 'Save Offer',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryText),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.secondaryText),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildImageGallery() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // Add button
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 28),
                  const SizedBox(height: 4),
                  const Text('Add', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Image tiles
          ..._images.asMap().entries.map((entry) {
            final idx = entry.key;
            final path = entry.value;
            final isAsset = path.startsWith('assets/');
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: isAsset
                        ? Image.asset(path, width: 100, height: 100, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _imagePlaceholder())
                        : Image.file(File(path), width: 100, height: 100, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _imagePlaceholder()),
                  ),
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(idx),
                      child: Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(14)),
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  Widget _buildDateTile({required String label, required DateTime? date, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.secondaryText)),
                  const SizedBox(height: 2),
                  Text(
                    date != null ? DateFormat('dd MMM yyyy').format(date) : 'Select',
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600,
                      color: date != null ? AppColors.primaryText : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
