import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../models/seller_product_model.dart';
import '../widgets/product_edit/shop_product_edit_basic_info.dart';
import '../widgets/product_edit/shop_product_image_editor.dart';
import '../widgets/product_edit/shop_product_category_selector.dart';
import '../widgets/product_edit/shop_product_pricing_section.dart';
import '../widgets/product_edit/shop_product_description_section.dart';
import '../widgets/product_edit/shop_product_return_section.dart';

class SellerProductEditScreen extends StatefulWidget {
  final SellerProduct product;

  const SellerProductEditScreen({
    super.key,
    required this.product,
  });

  @override
  State<SellerProductEditScreen> createState() => _SellerProductEditScreenState();
}

class _SellerProductEditScreenState extends State<SellerProductEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _oldPriceController;
  late TextEditingController _newPriceController;
  late TextEditingController _descriptionController;

  late List<String> _images;
  late String _category;
  late String _subCategory;
  late bool _returnAvailable;

  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _oldPriceController = TextEditingController(text: widget.product.oldPrice.toString());
    _newPriceController = TextEditingController(text: widget.product.newPrice.toString());
    _descriptionController = TextEditingController(text: widget.product.description ?? '');

    _images = List.from(widget.product.images);
    _category = widget.product.category;
    _subCategory = widget.product.subCategory;
    _returnAvailable = widget.product.returnAvailable;

    _nameController.addListener(_markChanged);
    _oldPriceController.addListener(_markChanged);
    _newPriceController.addListener(_markChanged);
    _descriptionController.addListener(_markChanged);
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _oldPriceController.dispose();
    _newPriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  double? get _discountPercent {
    final oldP = double.tryParse(_oldPriceController.text) ?? 0;
    final newP = double.tryParse(_newPriceController.text) ?? 0;
    if (oldP > 0 && newP < oldP) {
      return ((oldP - newP) / oldP) * 100;
    }
    return null;
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Discard changes?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Discard',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  void _handleSave() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product name cannot be empty')),
      );
      return;
    }

    // Capture references before async gap
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() {
      _isSaving = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    widget.product.name = _nameController.text.trim();
    widget.product.oldPrice = double.tryParse(_oldPriceController.text) ?? 0;
    widget.product.newPrice = double.tryParse(_newPriceController.text) ?? 0;
    widget.product.description = _descriptionController.text.trim();
    widget.product.images = _images;
    widget.product.category = _category;
    widget.product.subCategory = _subCategory;
    widget.product.returnAvailable = _returnAvailable;

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Product updated successfully!'),
        backgroundColor: Color(0xFF16A34A),
      ),
    );
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldPop = await _confirmDiscard();
        if (shouldPop && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
            onPressed: () async {
              final navigator = Navigator.of(context);
              if (await _confirmDiscard()) {
                if (mounted) navigator.pop();
              }
            },
          ),
          title: const Text(
            'Edit Product',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShopProductEditBasicInfo(nameController: _nameController),
              const SizedBox(height: 32),

              ShopProductImageEditor(
                images: _images,
                onRemove: (index) {
                  setState(() {
                    _images.removeAt(index);
                    _hasChanges = true;
                  });
                },
                onAdd: () {
                  setState(() {
                    _images.add('assets/images/shop/product1_1.png');
                    _hasChanges = true;
                  });
                },
              ),
              const SizedBox(height: 32),

              const Divider(color: Color(0xFFF1F5F9), thickness: 1.5, height: 1),
              const SizedBox(height: 32),

              ShopProductCategorySelector(
                category: _category,
                subCategory: _subCategory,
                onCategorySelected: (cat, sub) {
                  setState(() {
                    _category = cat;
                    _subCategory = sub;
                    _hasChanges = true;
                  });
                },
              ),
              const SizedBox(height: 32),

              ShopProductPricingSection(
                oldPriceController: _oldPriceController,
                newPriceController: _newPriceController,
                discountPercent: _discountPercent,
              ),
              const SizedBox(height: 32),

              const Divider(color: Color(0xFFF1F5F9), thickness: 1.5, height: 1),
              const SizedBox(height: 32),

              ShopProductDescriptionSection(descriptionController: _descriptionController),
              const SizedBox(height: 32),

              ShopProductReturnSection(
                isReturnAvailable: _returnAvailable,
                onChanged: (val) {
                  setState(() {
                    _returnAvailable = val;
                    _hasChanges = true;
                  });
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _hasChanges && !_isSaving ? _handleSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                disabledBackgroundColor: const Color(0xFF9CA3AF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Update Product',
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
      ),
    );
  }
}
