import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../models/offer_model.dart';
import 'offer_add_edit_screen.dart';
import 'package:intl/intl.dart';

class ShopOffersScreen extends StatefulWidget {
  const ShopOffersScreen({super.key});

  @override
  State<ShopOffersScreen> createState() => _ShopOffersScreenState();
}

class _ShopOffersScreenState extends State<ShopOffersScreen> {
  late List<OfferModel> _offers;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _offers = List.from(dummyOffers);
  }

  List<OfferModel> get _filteredOffers {
    if (_searchQuery.isEmpty) return _offers;
    final query = _searchQuery.toLowerCase();
    return _offers.where((offer) {
      return offer.title.toLowerCase().contains(query) ||
             offer.category.toLowerCase().contains(query) ||
             offer.subCategory.toLowerCase().contains(query);
    }).toList();
  }

  int get _activeCount {
    final now = DateTime.now();
    return _offers.where((o) => o.startDate.isBefore(now) && o.endDate.isAfter(now)).length;
  }

  int get _upcomingCount {
    final now = DateTime.now();
    return _offers.where((o) => o.startDate.isAfter(now)).length;
  }

  int get _expiredCount {
    final now = DateTime.now();
    return _offers.where((o) => o.endDate.isBefore(now)).length;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _navigateToAddOffer() async {
    final newOffer = await Navigator.push<OfferModel>(
      context,
      MaterialPageRoute(builder: (_) => const OfferAddEditScreen()),
    );
    if (newOffer != null) {
      setState(() {
        _offers.insert(0, newOffer);
      });
    }
  }

  void _navigateToEditOffer(OfferModel offer) async {
    final updatedOffer = await Navigator.push<OfferModel>(
      context,
      MaterialPageRoute(builder: (_) => OfferAddEditScreen(offer: offer)),
    );
    if (updatedOffer != null) {
      setState(() {
        final index = _offers.indexWhere((o) => o.id == updatedOffer.id);
        if (index != -1) {
          _offers[index] = updatedOffer;
        }
      });
    }
  }

  void _confirmDeleteOffer(OfferModel offer) {
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
            const Text(
              'Delete Offer?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to delete this offer? This action cannot be undone.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppColors.primaryText)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _offers.removeWhere((o) => o.id == offer.id);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Delete', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── SINGLE OFFER DETAILS MODAL (DraggableScrollableSheet) ──
  void _showOfferDetails(OfferModel offer) {
    final now = DateTime.now();
    String status = 'Active';
    Color statusColor = const Color(0xFF10B981);
    if (offer.startDate.isAfter(now)) {
      status = 'Upcoming';
      statusColor = const Color(0xFFF59E0B);
    } else if (offer.endDate.isBefore(now)) {
      status = 'Expired';
      statusColor = const Color(0xFFEF4444);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _OfferDetailsDraggableSheet(
          offer: offer,
          status: status,
          statusColor: statusColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOffers = _filteredOffers;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Offers', style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
            Text('Manage your store offers', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.secondaryText)),
          ],
        ),
        automaticallyImplyLeading: false, // Managed by bottom nav
      ),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search offers...',
                        hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.secondaryText),
                        prefixIcon: Icon(Icons.search, color: AppColors.secondaryText),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.primaryText),
                    ),
                  ),
                ),
              ),

              // Summary Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Row(
                    children: [
                      _buildSummaryCard('Active', _activeCount, const Color(0xFF10B981)),
                      const SizedBox(width: 12),
                      _buildSummaryCard('Upcoming', _upcomingCount, const Color(0xFFF59E0B)),
                      const SizedBox(width: 12),
                      _buildSummaryCard('Expired', _expiredCount, const Color(0xFFEF4444)),
                    ],
                  ),
                ),
              ),

              // Offer List
              if (filteredOffers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_offer_outlined, size: 64, color: AppColors.secondaryText.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const Text('No offers found', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
                        const SizedBox(height: 8),
                        const Text('Try a different search.', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.secondaryText)),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
                        child: _buildOfferCard(filteredOffers[index]),
                      );
                    },
                    childCount: filteredOffers.length,
                  ),
                ),
              
              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
          
          // Floating Action Button
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton.extended(
              onPressed: _navigateToAddOffer,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Offer', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              count.toString().padLeft(2, '0'),
              style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(OfferModel offer) {
    final now = DateTime.now();
    String status = 'Active';
    Color statusColor = const Color(0xFF10B981); // Emerald
    
    if (offer.startDate.isAfter(now)) {
      status = 'Upcoming';
      statusColor = const Color(0xFFF59E0B); // Amber
    } else if (offer.endDate.isBefore(now)) {
      status = 'Expired';
      statusColor = const Color(0xFFEF4444); // Red
    }

    return GestureDetector(
      onTap: () => _showOfferDetails(offer),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
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
            // Top: Image and Actions
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF8FAFC),
                    child: offer.images.isNotEmpty
                        ? _buildCardImage(offer.images.first)
                        : const SizedBox(
                            height: 140,
                            child: Center(child: Icon(Icons.image, color: Colors.grey, size: 40)),
                          ),
                  ),
                ),
                if (offer.images.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${offer.images.length} photos',
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                // 3-dot menu — isolated from card tap via GestureDetector stop
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    // Absorb taps so they don't propagate to the card's onTap
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz, size: 20, color: AppColors.primaryText),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        offset: const Offset(0, 40),
                        onSelected: (value) {
                          if (value == 'view') {
                            _showOfferDetails(offer);
                          } else if (value == 'edit') {
                            _navigateToEditOffer(offer);
                          } else if (value == 'delete') {
                            _confirmDeleteOffer(offer);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'view', child: Text('View Offer', style: TextStyle(fontFamily: 'Poppins', fontSize: 14))),
                          const PopupMenuItem(value: 'edit', child: Text('Edit Offer', style: TextStyle(fontFamily: 'Poppins', fontSize: 14))),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete Offer', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          offer.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹${offer.newPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${offer.oldPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 14, color: AppColors.secondaryText, decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      if (offer.discountPercentage > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(${offer.discountPercentage.toStringAsFixed(0)}% OFF)',
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          offer.category,
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.secondaryText),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('dd MMM').format(offer.startDate)} - ${DateFormat('dd MMM').format(offer.endDate)}',
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renders a card image that preserves the full aspect ratio of the source.
  /// Uses BoxFit.contain inside a constrained container so no cropping occurs
  /// while keeping the card compact.
  Widget _buildCardImage(String path) {
    final isAsset = path.startsWith('assets/') || path.startsWith('assets\\');
    final Widget image;
    if (isAsset) {
      image = Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox(
          height: 140,
          child: Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 36)),
        ),
      );
    } else {
      image = Image.file(
        File(path),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox(
          height: 140,
          child: Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 36)),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 120,
        maxHeight: 200,
      ),
      child: image,
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────────
// OFFER DETAILS — DRAGGABLE SCROLLABLE BOTTOM SHEET
// This is the SINGLE Offer Details presentation component.
// Used by both card tap and 3-dot → View Offer.
// ────────────────────────────────────────────────────────────────────────────────

class _OfferDetailsDraggableSheet extends StatefulWidget {
  final OfferModel offer;
  final String status;
  final Color statusColor;

  const _OfferDetailsDraggableSheet({
    required this.offer,
    required this.status,
    required this.statusColor,
  });

  @override
  State<_OfferDetailsDraggableSheet> createState() => _OfferDetailsDraggableSheetState();
}

class _OfferDetailsDraggableSheetState extends State<_OfferDetailsDraggableSheet> {
  late PageController _pageController;
  int _currentImagePage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    // Ensure the sheet can't go past the status bar
    final maxExtent = 1.0 - (topPadding / MediaQuery.of(context).size.height);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: maxExtent.clamp(0.6, 0.95),
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle — not scrollable, always visible at top
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    // ── IMAGE SLIDER ──
                    if (widget.offer.images.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            color: const Color(0xFFF8FAFC),
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: widget.offer.images.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentImagePage = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return _buildModalImage(widget.offer.images[index]);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Page indicator dots
                      if (widget.offer.images.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              widget.offer.images.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: _currentImagePage == index ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _currentImagePage == index
                                      ? AppColors.primary
                                      : const Color(0xFFD1D5DB),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 24),

                    // ── TITLE + STATUS ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.offer.title,
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.status,
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: widget.statusColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── PRICING ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Text(
                            '₹${widget.offer.newPrice.toStringAsFixed(0)}',
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹${widget.offer.oldPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 16, color: AppColors.secondaryText, decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          if (widget.offer.discountPercentage > 0) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                '${widget.offer.discountPercentage.toStringAsFixed(0)}% OFF',
                                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── CATEGORY ──
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text('Category', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text('${widget.offer.category} > ${widget.offer.subCategory}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.primaryText)),
                    ),
                    const SizedBox(height: 16),

                    // ── OFFER PERIOD ──
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text('Offer Period', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            '${DateFormat('dd MMM yyyy').format(widget.offer.startDate)} - ${DateFormat('dd MMM yyyy').format(widget.offer.endDate)}',
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.primaryText),
                          ),
                        ],
                      ),
                    ),

                    // ── DESCRIPTION ──
                    if (widget.offer.description != null && widget.offer.description!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text('Description', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(widget.offer.description!, style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, color: AppColors.primaryText)),
                      ),
                    ],

                    // Bottom safe area padding
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Renders an image inside the modal slider, preserving full aspect ratio.
  Widget _buildModalImage(String path) {
    final isAsset = path.startsWith('assets/') || path.startsWith('assets\\');
    if (isAsset) {
      return Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
        ),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
        ),
      );
    }
  }
}
