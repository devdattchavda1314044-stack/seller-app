import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../models/service_listing_model.dart';
import '../widgets/service_edit/service_form_fields.dart';

/// Add or edit one service listing.
///
/// Has no image editor, unlike the shop's product editor. The customer app's
/// services module renders a category glyph rather than photography, so an
/// uploader here would collect assets nothing can display — and would invite
/// the stock-photo problem that module was built to avoid.
class ServiceListingEditScreen extends StatefulWidget {
  /// The listing being edited, or null to create one.
  final ServiceListing? service;

  const ServiceListingEditScreen({super.key, this.service});

  @override
  State<ServiceListingEditScreen> createState() =>
      _ServiceListingEditScreenState();
}

class _ServiceListingEditScreenState extends State<ServiceListingEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _originalPriceController;
  late final TextEditingController _visitFeeController;
  late final TextEditingController _durationController;
  late final TextEditingController _descriptionController;

  late String _category;
  late String _subCategory;
  late ServiceAvailability _availability;
  late List<String> _inclusions;
  late List<String> _exclusions;
  late List<String> _requirements;
  late List<BookingSlotRef> _slots;
  late bool _isEmergency;
  late bool _isActive;

  bool _hasChanges = false;
  bool _isSaving = false;

  /// Set once the seller tries to save, so the form does not shout at them
  /// about empty fields they have not reached yet.
  bool _showErrors = false;

  bool get _isNew => widget.service == null;

  @override
  void initState() {
    super.initState();
    final ServiceListing? s = widget.service;

    _titleController = TextEditingController(text: s?.title ?? '');
    _priceController = TextEditingController(
      text: s == null ? '' : s.startingPrice.toStringAsFixed(0),
    );
    _originalPriceController = TextEditingController(
      text: s?.originalPrice == null
          ? ''
          : s!.originalPrice!.toStringAsFixed(0),
    );
    _visitFeeController = TextEditingController(
      text: s == null || s.visitFee == 0 ? '' : s.visitFee.toStringAsFixed(0),
    );
    _durationController = TextEditingController(text: s?.durationLabel ?? '');
    _descriptionController = TextEditingController(text: s?.description ?? '');

    _category = s?.category ?? serviceCategories.first.name;
    _subCategory =
        s?.subCategory ?? serviceCategories.first.subCategories.first;
    _availability = s?.availability ?? ServiceAvailability.today;
    _inclusions = List.of(s?.inclusions ?? const []);
    _exclusions = List.of(s?.exclusions ?? const []);
    _requirements = List.of(s?.requirements ?? const []);
    _slots = List.of(s?.slots ?? _defaultSlotIds);
    _isEmergency = s?.isEmergency ?? false;
    _isActive = s?.isActive ?? true;

    for (final c in [
      _titleController,
      _priceController,
      _originalPriceController,
      _visitFeeController,
      _durationController,
      _descriptionController,
    ]) {
      c.addListener(_markChanged);
    }
  }

  /// Every window, for a brand-new listing. Matches `ServiceListing`'s own
  /// default so a service created here is bookable in the same slots as one
  /// created in code.
  static const List<BookingSlotRef> _defaultSlotIds = [
    'sl1',
    'sl2',
    'sl3',
    'sl4',
    'sl5',
    'sl6',
  ];

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _visitFeeController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ── Validation ──

  double get _price => double.tryParse(_priceController.text.trim()) ?? 0;

  double? get _originalPrice {
    final text = _originalPriceController.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  double get _visitFee =>
      double.tryParse(_visitFeeController.text.trim()) ?? 0;

  /// First problem that would make the listing wrong for a customer, or null.
  String? get _validationError {
    if (_titleController.text.trim().isEmpty) {
      return 'Give the service a name.';
    }
    if (_subCategory.isEmpty) {
      return 'Pick a sub-category.';
    }
    if (_price <= 0) {
      return 'Set a starting price above zero.';
    }
    if (_originalPrice != null && _originalPrice! <= _price) {
      // Otherwise the customer's card draws a struck-through price that is
      // lower than the one being charged.
      return 'The original price must be higher than the starting price.';
    }
    if (_durationController.text.trim().isEmpty) {
      return 'Say roughly how long the job takes.';
    }
    if (_slots.isEmpty) {
      return 'Pick at least one bookable window.';
    }
    return null;
  }

  double? get _discountPercent {
    final original = _originalPrice;
    if (original == null || original <= _price) return null;
    return ((original - _price) / original) * 100;
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
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
            color: AppTokens.tertiaryText,
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
                color: AppColors.secondaryText,
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
                color: AppTokens.danger,
              ),
            ),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  Future<void> _handleSave() async {
    final String? error = _validationError;
    if (error != null) {
      setState(() => _showErrors = true);
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          ),
          backgroundColor: AppTokens.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final ServiceListing saved;
    if (_isNew) {
      saved = ServiceListing(
        title: _titleController.text.trim(),
        category: _category,
        subCategory: _subCategory,
        startingPrice: _price,
        originalPrice: _originalPrice,
        visitFee: _visitFee,
        durationLabel: _durationController.text.trim(),
        availability: _availability,
        isEmergency: _isEmergency,
        isActive: _isActive,
        description: _descriptionController.text.trim(),
        inclusions: _inclusions,
        exclusions: _exclusions,
        requirements: _requirements,
        slots: _slots,
      );
    } else {
      saved = widget.service!
        ..title = _titleController.text.trim()
        ..category = _category
        ..subCategory = _subCategory
        ..startingPrice = _price
        ..originalPrice = _originalPrice
        ..visitFee = _visitFee
        ..durationLabel = _durationController.text.trim()
        ..availability = _availability
        ..isEmergency = _isEmergency
        ..isActive = _isActive
        ..description = _descriptionController.text.trim()
        ..inclusions = _inclusions
        ..exclusions = _exclusions
        ..requirements = _requirements
        ..slots = _slots;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _isNew ? 'Service added.' : 'Service updated.',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: AppTokens.successStrong,
        behavior: SnackBarBehavior.floating,
      ),
    );
    navigator.pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldPop = await _confirmDiscard();
        if (shouldPop && mounted) navigator.pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primaryText,
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              if (await _confirmDiscard()) {
                if (mounted) navigator.pop();
              }
            },
          ),
          title: Text(
            _isNew ? 'Add Service' : 'Edit Service',
            style: const TextStyle(
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── WHAT IT IS ──
              const ServiceFormLabel(
                label: 'Service name',
                hint: 'What a customer is booking — "Deep Home Cleaning '
                    '(2 BHK)", not just "Cleaning".',
                isRequired: true,
              ),
              const SizedBox(height: 10),
              ServiceTextField(
                controller: _titleController,
                hintText: 'e.g. Split AC Service & Gas Top-up',
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 28),
              _divider(),
              const SizedBox(height: 28),

              ServiceCategorySelector(
                category: _category,
                subCategory: _subCategory,
                onChanged: (cat, sub) => setState(() {
                  _category = cat;
                  _subCategory = sub;
                  _hasChanges = true;
                }),
              ),

              const SizedBox(height: 28),
              _divider(),
              const SizedBox(height: 28),

              // ── WHAT IT COSTS ──
              const ServiceFormLabel(
                label: 'Pricing',
                hint: 'Services quote from, they do not price exactly. '
                    'Customers see this as "From ₹x".',
                isRequired: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldCaption('Starting price'),
                        const SizedBox(height: 6),
                        ServiceTextField(
                          controller: _priceController,
                          hintText: '0',
                          prefixText: '₹ ',
                          isNumeric: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldCaption('Was (optional)'),
                        const SizedBox(height: 6),
                        ServiceTextField(
                          controller: _originalPriceController,
                          hintText: '0',
                          prefixText: '₹ ',
                          isNumeric: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (_discountPercent != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppTokens.successSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_offer_outlined,
                        size: 14,
                        color: AppTokens.successText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_discountPercent!.toStringAsFixed(0)}% off will show '
                        'on the card',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTokens.successText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              _fieldCaption('Visit / call-out fee (optional)'),
              const SizedBox(height: 6),
              ServiceTextField(
                controller: _visitFeeController,
                hintText: '0',
                prefixText: '₹ ',
                isNumeric: true,
              ),
              const SizedBox(height: 6),
              const Text(
                'Charged on top and shown to the customer as a separate line, '
                'so it never looks like part of the service price.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),
              _divider(),
              const SizedBox(height: 28),

              // ── WHEN ──
              const ServiceFormLabel(
                label: 'How long it takes',
                hint: 'A range, in the words you would say on the phone. '
                    'Someone booking a service is budgeting their afternoon, '
                    'not just their money.',
                isRequired: true,
              ),
              const SizedBox(height: 10),
              ServiceTextField(
                controller: _durationController,
                hintText: 'e.g. 45-60 min, 3-4 hrs',
                textCapitalization: TextCapitalization.none,
              ),

              const SizedBox(height: 28),

              ServiceAvailabilitySelector(
                value: _availability,
                onChanged: (value) => setState(() {
                  _availability = value;
                  _hasChanges = true;
                }),
              ),

              const SizedBox(height: 24),

              ServiceSlotSelector(
                selected: _slots,
                onChanged: (value) => setState(() {
                  _slots = value;
                  _hasChanges = true;
                }),
              ),
              if (_showErrors && _slots.isEmpty) ...[
                const SizedBox(height: 8),
                _errorLine('Pick at least one bookable window.'),
              ],

              const SizedBox(height: 28),
              _divider(),
              const SizedBox(height: 28),

              // ── WHAT IT COVERS ──
              const ServiceFormLabel(
                label: 'Description',
                hint: 'In your own words. Left empty, the customer app builds '
                    'a sentence from the name and department instead.',
              ),
              const SizedBox(height: 10),
              ServiceTextField(
                controller: _descriptionController,
                hintText: 'What the visit actually involves...',
                maxLines: 5,
              ),

              const SizedBox(height: 28),

              ServiceTermsEditor(
                label: 'What the price includes',
                hint: 'The most requested thing on a services listing, and '
                    'the one that stops a dispute on the doorstep.',
                addHint: 'Add an inclusion',
                bulletIcon: Icons.check_rounded,
                bulletColor: AppTokens.successStrong,
                items: _inclusions,
                onChanged: (value) => setState(() {
                  _inclusions = value;
                  _hasChanges = true;
                }),
              ),

              const SizedBox(height: 26),

              ServiceTermsEditor(
                label: 'What it does not include',
                hint: 'Parts, materials, anything quoted separately. Stating '
                    'this up front is what keeps a 4.8 rating a 4.8.',
                addHint: 'Add an exclusion',
                bulletIcon: Icons.close_rounded,
                bulletColor: AppTokens.danger,
                items: _exclusions,
                onChanged: (value) => setState(() {
                  _exclusions = value;
                  _hasChanges = true;
                }),
              ),

              const SizedBox(height: 26),

              ServiceTermsEditor(
                label: 'What the customer needs ready',
                hint: 'Water supply, parking, a power point. Shown before '
                    'booking, not after.',
                addHint: 'Add a requirement',
                bulletIcon: Icons.info_outline_rounded,
                bulletColor: AppTokens.warningText,
                items: _requirements,
                onChanged: (value) => setState(() {
                  _requirements = value;
                  _hasChanges = true;
                }),
              ),

              const SizedBox(height: 28),
              _divider(),
              const SizedBox(height: 28),

              // ── FLAGS ──
              ServiceToggleRow(
                label: 'Emergency call-out',
                hint: 'Puts this service in the customer app\'s emergency '
                    'rail. Only for work you can attend within the hour.',
                value: _isEmergency,
                activeColor: AppTokens.danger,
                onChanged: (value) => setState(() {
                  _isEmergency = value;
                  _hasChanges = true;
                }),
              ),
              const SizedBox(height: 10),
              ServiceToggleRow(
                label: 'Listed',
                hint: 'Off keeps the service in your catalogue but hides it '
                    'from customers.',
                value: _isActive,
                onChanged: (value) => setState(() {
                  _isActive = value;
                  _hasChanges = true;
                }),
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
              // A new listing is savable from the start; an edit needs a
              // change to save, matching the shop editor.
              onPressed: (_isNew || _hasChanges) && !_isSaving
                  ? _handleSave
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.action,
                disabledBackgroundColor: AppTokens.mutedText,
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
                  : Text(
                      _isNew ? 'Add Service' : 'Update Service',
                      style: const TextStyle(
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

  Widget _divider() => const Divider(
        color: AppTokens.divider,
        thickness: 1.5,
        height: 1,
      );

  Widget _fieldCaption(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.secondaryText,
        ),
      );

  Widget _errorLine(String text) => Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 14,
            color: AppTokens.danger,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppTokens.danger,
            ),
          ),
        ],
      );
}
