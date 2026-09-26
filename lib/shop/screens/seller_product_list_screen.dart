import 'package:flutter/material.dart';
import '../models/seller_product_model.dart';
import '../widgets/seller_product_search_bar.dart';
import '../widgets/seller_product_filters.dart';
import '../widgets/seller_product_list_item.dart';
import 'seller_product_edit_screen.dart';
class SellerProductListScreen extends StatefulWidget {
  const SellerProductListScreen({super.key});

  @override
  State<SellerProductListScreen> createState() => _SellerProductListScreenState();
}

class _SellerProductListScreenState extends State<SellerProductListScreen> {
  int? _selectedProductIndex;
  String _selectedFilter = 'All';
  String _searchQuery = '';

  List<SellerProduct> get _filteredProducts {
    return dummySellerProducts.where((product) {
      // Filter logic
      if (_selectedFilter == 'Active' && !product.isActive) return false;
      if (_selectedFilter == 'Inactive' && product.isActive) return false;
      if (_selectedFilter == 'Offers' && !product.offerAvailable) return false;
      if (_selectedFilter == 'No Offers' && product.offerAvailable) return false;
      if (_selectedFilter == 'Low Stock' && product.receivedOrders <= 50) return false;
      if (_selectedFilter == 'High Rated' && product.rating < 4.5) return false;

      // Search logic
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!product.name.toLowerCase().contains(query) &&
            !product.category.toLowerCase().contains(query) &&
            !product.subCategory.toLowerCase().contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _selectedProductIndex = null;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _selectedProductIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── Smart header with title + search ───
            SellerProductSearchBar(
              productCount: products.length,
              onSearchChanged: _onSearchChanged,
            ),

            // ─── Segmented filter navigation ───
            SellerProductFilters(
              selectedFilter: _selectedFilter,
              onFilterChanged: _onFilterChanged,
            ),

            // ─── Product inventory list ───
            Expanded(
              child: products.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final originalIndex = dummySellerProducts.indexOf(product);
                        final isSelected = _selectedProductIndex == originalIndex;

                        return SellerProductListItem(
                          product: product,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedProductIndex =
                                  _selectedProductIndex == originalIndex ? null : originalIndex;
                            });
                          },
                          onToggleStatus: (val) {
                            setState(() => product.isActive = val);
                          },
                          onEdit: () async {
                            final didUpdate = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SellerProductEditScreen(product: product),
                              ),
                            );
                            if (didUpdate == true) {
                              setState(() {});
                            }
                          },
                          onDelete: () {
                            // UI only
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ─── Premium FAB ───
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 4),
        child: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Add Product
          },
          backgroundColor: const Color(0xFF1E3A5F),
          elevation: 3,
          highlightElevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
          label: const Text(
            'Add Product',
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
              isSearching ? Icons.search_off_rounded : Icons.inventory_2_outlined,
              size: 56,
              color: const Color(0xFFD1D5DB),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'No products found' : 'No products yet',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? 'Try a different search term or filter'
                  : 'Tap "Add Product" to get started',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFFBFC4CE),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
