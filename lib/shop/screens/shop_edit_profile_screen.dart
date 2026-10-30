import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../models/seller_profile_model.dart';
import 'shop_location_picker_screen.dart';

class ShopEditProfileScreen extends StatefulWidget {
  const ShopEditProfileScreen({super.key});

  @override
  State<ShopEditProfileScreen> createState() => _ShopEditProfileScreenState();
}

class _ShopEditProfileScreenState extends State<ShopEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // State
  String? _localImagePath; // Selected from device
  String? _existingImagePath; // From provider
  
  double? _selectedLat;
  double? _selectedLng;
  String? _locationName;

  String? _selectedMainCategory;
  String? _selectedSubcategory;

  // Categories Dummy Data
  final Map<String, List<String>> _categoriesMap = {
    'Medical': ['Medicine', 'Pharmacy', 'Surgical Store', 'Medical Equipment'],
    'Grocery': ['Grocery Store', 'Supermarket', 'Organic Food'],
    'Electronics': ['Mobile & Accessories', 'Computers', 'Home Appliances'],
    'Fashion': ['Clothing', 'Footwear', 'Jewelry'],
    'Food': ['Bakery', 'Restaurant', 'Farsan'],
  };

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  void _loadExistingProfile() {
    final profile = SellerProfileProvider().profileNotifier.value;
    
    _nameController.text = profile.shopName;
    _addressController.text = profile.address;
    _gstController.text = profile.gstNumber;
    _phoneController.text = profile.phoneNumber;
    _emailController.text = profile.email;

    _existingImagePath = profile.profileImage;
    _selectedLat = profile.latitude;
    _selectedLng = profile.longitude;
    _locationName = profile.locationName;
    _selectedMainCategory = profile.mainCategory;
    _selectedSubcategory = profile.subCategory;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _localImagePath = image.path;
      });
    }
  }

  Future<void> _pickLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShopLocationPickerScreen(
          initialLatitude: _selectedLat,
          initialLongitude: _selectedLng,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLat = result.latitude;
        _selectedLng = result.longitude;
        // In a real app, reverse geocoding happens here. We mock it for UI purposes.
        _locationName = 'Selected Location: ${result.latitude.toStringAsFixed(2)}, ${result.longitude.toStringAsFixed(2)}';
      });
    }
  }

  void _showCategorySelector(bool isMain) {
    if (!isMain && _selectedMainCategory == null) {
      _showFeedback('Please select a Main Category first.', isError: true);
      return;
    }

    final items = isMain 
        ? _categoriesMap.keys.toList() 
        : _categoriesMap[_selectedMainCategory] ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isMain ? 'Select Main Category' : 'Select Subcategory',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      itemBuilder: (ctx, i) {
                        final item = items[i];
                        final isSelected = isMain ? _selectedMainCategory == item : _selectedSubcategory == item;
                        return ListTile(
                          onTap: () {
                            setState(() {
                              if (isMain) {
                                if (_selectedMainCategory != item) {
                                  _selectedMainCategory = item;
                                  _selectedSubcategory = null; // reset sub
                                }
                              } else {
                                _selectedSubcategory = item;
                              }
                            });
                            Navigator.pop(ctx);
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
                          title: Text(
                            item,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? AppColors.primary : AppColors.primaryText,
                            ),
                          ),
                          trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMainCategory == null || _selectedSubcategory == null) {
      _showFeedback('Please select valid business categories', isError: true);
      return;
    }

    // Update shared singleton state
    final updatedProfile = SellerProfile(
      profileImage: _localImagePath ?? _existingImagePath,
      shopName: _nameController.text.trim(),
      address: _addressController.text.trim(),
      gstNumber: _gstController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      latitude: _selectedLat,
      longitude: _selectedLng,
      locationName: _locationName,
      mainCategory: _selectedMainCategory!,
      subCategory: _selectedSubcategory!,
      isStoreAvailable: SellerProfileProvider().profileNotifier.value.isStoreAvailable, // keep existing toggle
    );

    SellerProfileProvider().updateProfile(updatedProfile);

    _showFeedback('Profile updated successfully');
    Navigator.pop(context);
  }

  void _showFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: isError ? Colors.red.shade600 : const Color(0xFF1F2937),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // Basic unsaved changes check
    final profile = SellerProfileProvider().profileNotifier.value;
    final hasChanges = _nameController.text != profile.shopName ||
        _addressController.text != profile.address ||
        _localImagePath != null ||
        _selectedMainCategory != profile.mainCategory ||
        _selectedSubcategory != profile.subCategory;

    if (!hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Discard Changes?', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?', style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Editing', style: TextStyle(fontFamily: 'Poppins', color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Discard', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryText, size: 20),
            onPressed: () async {
              if (await _onWillPop()) {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('PROFILE IDENTITY'),
                _buildIdentitySection(),
                
                _buildSectionHeader('SHOP INFORMATION'),
                _buildShopInfoSection(),
                
                _buildSectionHeader('CONTACT INFORMATION'),
                _buildContactInfoSection(),
                
                _buildSectionHeader('SHOP LOCATION'),
                _buildLocationSection(),
                
                _buildSectionHeader('BUSINESS CATEGORY'),
                _buildCategorySection(),
                
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: AppColors.secondaryText,
        ),
      ),
    );
  }

  Widget _buildIdentitySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Image Editor
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF3F4F6),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                    ),
                    child: ClipOval(
                      child: _localImagePath != null
                          ? Image.file(File(_localImagePath!), fit: BoxFit.cover)
                          : _existingImagePath != null
                              ? Image.asset(_existingImagePath!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.store, color: AppColors.secondaryText, size: 40))
                              : const Icon(Icons.store, color: AppColors.secondaryText, size: 40),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
            child: const Text(
              'Change Shop Icon',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Shop Name',
            controller: _nameController,
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildShopInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _buildTextField(
            label: 'Shop Address',
            controller: _addressController,
            maxLines: 3,
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'GST Number',
            controller: _gstController,
            textCapitalization: TextCapitalization.characters,
            // GST can be optional depending on business size, so no strict required validation here as requested
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _buildTextField(
            label: 'Phone Number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (v.trim().length < 10) return 'Invalid phone number';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Email Address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (!v.contains('@') || !v.contains('.')) return 'Invalid email';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedLat != null && _selectedLng != null) ...[
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // Displaying a static map view or icon placeholder since we don't load map instances everywhere
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.map, size: 48, color: const Color(0xFFD1D5DB)),
                    Positioned(
                      child: Icon(Icons.location_on, size: 32, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.secondaryText, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _locationName ?? '${_selectedLat!.toStringAsFixed(4)}, ${_selectedLng!.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickLocation,
              icon: const Icon(Icons.map_outlined, size: 18),
              label: Text(_selectedLat == null ? 'Set Shop Location' : 'Change Location'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _buildSelectorTile(
            label: 'Main Category',
            value: _selectedMainCategory,
            onTap: () => _showCategorySelector(true),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6), indent: 16, endIndent: 16),
          _buildSelectorTile(
            label: 'Subcategory',
            value: _selectedSubcategory,
            onTap: () => _showCategorySelector(false),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorTile({required String label, required String? value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value ?? 'Select $label',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: value == null ? FontWeight.normal : FontWeight.w600,
                      color: value == null ? const Color(0xFF9CA3AF) : AppColors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.primaryText),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
          ),
        ),
      ],
    );
  }
}
