import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/networking/repositories_providers.dart';
import '../../core/widgets/error_widget.dart';

/// Sort options for the products browse page.
enum _ProductSort { priceLow, priceHigh, rating, newest }

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key, this.category});

  final String? category;

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  _ProductSort _sort = _ProductSort.priceLow;
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await ref.read(productsRepositoryProvider).getRandomProducts(limit: 24);
      final filtered = widget.category == null
          ? products
          : products.where((p) {
              final cat = p['category_title'] as String?;
              return cat == widget.category;
            }).toList();
      setState(() {
        _products = filtered;
        _loading = false;
      });
      _applySort();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _applySort() {
    switch (_sort) {
      case _ProductSort.priceLow:
        _products.sort((a, b) {
          final pa = (a['price'] as num?) ?? 0;
          final pb = (b['price'] as num?) ?? 0;
          return pa.compareTo(pb);
        });
      case _ProductSort.priceHigh:
        _products.sort((a, b) {
          final pa = (a['price'] as num?) ?? 0;
          final pb = (b['price'] as num?) ?? 0;
          return pb.compareTo(pa);
        });
      case _ProductSort.rating:
        _products.sort((a, b) {
          final ra = (a['ratings'] as Map?)?['value'] as num?;
          final rb = (b['ratings'] as Map?)?['value'] as num?;
          return (rb ?? 0).compareTo(ra ?? 0);
        });
      case _ProductSort.newest:
        break;
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'Price on request';
    return '\$${(price as num).toStringAsFixed(2)}';
  }

  String _merchant(Map<String, dynamic> p) => p['merchant'] ?? 'Verified Store';

  String _category(Map<String, dynamic> p) => p['category_title'] ?? 'General';

  double _rating(Map<String, dynamic> p) {
    final r = p['ratings'];
    if (r is Map) return (r['value'] as num?)?.toDouble() ?? 0.0;
    return 0.0;
  }

  String _image(Map<String, dynamic> p) =>
      p['image_url'] as String? ?? '';

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> p) {
    final name = p['name'] as String? ?? 'Product';
    final price = _formatPrice(p['price']);
    final merchant = _merchant(p);
    final category = _category(p);
    final rating = _rating(p);
    final imageUrl = _image(p);

    return GestureDetector(
      onTap: () {
        final id = p['channel3_product_id'] ?? p['id'] ?? '';
        context.go('/product/$id');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 40,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 40,
                          color: Color(0xFF2563EB),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: pjs(
                      size: 13.5,
                      weight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (rating > 0) ...[
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: pjs(
                            size: 11,
                            weight: FontWeight.w600,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category,
                          style: pjs(
                            size: 9.5,
                            weight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    price,
                    style: pjs(
                      size: 15,
                      weight: FontWeight.w800,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    merchant,
                    style: pjs(
                      size: 11,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'All Products',
          style: pjs(
            size: 18,
            weight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Sort dropdown
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<_ProductSort>(
                value: _sort,
                icon: const Icon(
                  Icons.sort_rounded,
                  size: 20,
                  color: Color(0xFF2563EB),
                ),
                items: [
                  DropdownMenuItem(
                    value: _ProductSort.priceLow,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_upward_rounded, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text('Price: Low', style: pjs(size: 12, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: _ProductSort.priceHigh,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_downward_rounded, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text('Price: High', style: pjs(size: 12, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: _ProductSort.rating,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text('Top Rated', style: pjs(size: 12, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _sort = v);
                  _applySort();
                },
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ProofBuyErrorWidget(
                    message: _error!,
                    onRetry: _loadProducts,
                  )
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFF94A3B8)),
                            SizedBox(height: 12),
                            Text('No products found',
                                style: pjs(size: 15, color: Color(0xFF64748B))),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) =>
                            _buildProductCard(context, _products[index]),
                      ),
      ),
    );
  }
}
