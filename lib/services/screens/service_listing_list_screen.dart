import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../models/service_listing_model.dart';
import '../widgets/service_listing_filters.dart';
import '../widgets/service_listing_list_item.dart';
import '../widgets/service_listing_search_bar.dart';
import 'service_listing_edit_screen.dart';

/// The seller's service catalogue.
///
/// Mirrors `SellerProductListScreen`, over `dummyServiceListings`: the
/// services backend has no tables yet, so this list is the source of truth
/// for the session the same way the shop module's is.
class ServiceListingListScreen extends StatefulWidget {
  const ServiceListingListScreen({super.key});

  @override
  State<ServiceListingListScreen> createState() =>
      _ServiceListingListScreenState();
}

class _ServiceListingListScreenState extends State<ServiceListingListScreen> {
  /// The expanded row, by listing id. An id rather than an index so the panel
  /// stays on the same service when a filter reorders the list.
  String? _expandedId;

  String _selectedFilter = 'All';
  String _searchQuery = '';

  List<ServiceListing> get _filteredServices {
    return dummyServiceListings.where((service) {
      switch (_selectedFilter) {
        case 'Active':
          if (!service.isActive) return false;
        case 'Paused':
          if (service.isActive) return false;
        case 'Available Now':
          if (service.availability != ServiceAvailability.now) return false;
        case 'Emergency':
          if (!service.isEmergency) return false;
        case 'Discounted':
          if (!service.hasDiscount) return false;
        case 'High Rated':
          if (service.rating < 4.5) return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!service.title.toLowerCase().contains(query) &&
            !service.category.toLowerCase().contains(query) &&
            !service.subCategory.toLowerCase().contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _expandedId = null;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _expandedId = null;
    });
  }

  Future<void> _openEditor({ServiceListing? service}) async {
    final result = await Navigator.push<ServiceListing>(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceListingEditScreen(service: service),
      ),
    );

    if (result == null) return;

    setState(() {
      if (service == null) {
        dummyServiceListings.insert(0, result);
        _expandedId = result.id;
      }
      // An edit mutates the listing in place, so there is nothing to swap in.
    });
  }

  void _confirmDelete(ServiceListing service) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete this service?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16.5,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        content: Text(
          '"${service.title}" will stop appearing for customers. Bookings '
          'already taken against it are not affected.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.secondaryText,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Keep it',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              setState(() {
                dummyServiceListings.removeWhere((s) => s.id == service.id);
                if (_expandedId == service.id) _expandedId = null;
              });
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppTokens.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = _filteredServices;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ServiceListingSearchBar(
              serviceCount: services.length,
              onSearchChanged: _onSearchChanged,
            ),

            ServiceListingFilters(
              selectedFilter: _selectedFilter,
              onFilterChanged: _onFilterChanged,
            ),

            Expanded(
              child: services.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];

                        return ServiceListingListItem(
                          service: service,
                          isSelected: _expandedId == service.id,
                          onTap: () => setState(() {
                            _expandedId =
                                _expandedId == service.id ? null : service.id;
                          }),
                          onToggleStatus: (val) {
                            setState(() => service.isActive = val);
                          },
                          onEdit: () => _openEditor(service: service),
                          onDelete: () => _confirmDelete(service),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 4),
        child: FloatingActionButton.extended(
          onPressed: _openEditor,
          backgroundColor: AppTokens.inkFill,
          elevation: 3,
          highlightElevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
          label: const Text(
            'Add Service',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off_rounded : Icons.handyman_outlined,
              size: 56,
              color: AppTokens.faintText,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'No services found' : 'No services yet',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTokens.mutedText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? 'Try a different search term or filter'
                  : 'Tap "Add Service" to list what you do',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppTokens.faintText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
