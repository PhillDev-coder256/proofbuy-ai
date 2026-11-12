import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/networking/repositories_providers.dart';
import '../../core/widgets/error_widget.dart';

/// Browse products by category. Tapping a category card shows products
/// within that category on the Products screen.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  List<String> _categories = [];
  bool _loading = true;
  String? _error;

  static const _categoryIcons = {
    'Laptops': Icons.laptop_mac_rounded,
    'Phones': Icons.smartphone_rounded,
    'Headphones': Icons.headphones_rounded,
    'Cameras': Icons.camera_alt_outlined,
    'Smartwatches': Icons.watch_rounded,
    'Accessories': Icons.cable_rounded,
    'Computers': Icons.desktop_mac_rounded,
    'Tablets': Icons.tablet_rounded,
    'Gaming': Icons.videogame_asset_rounded,
    'Audio': Icons.hearing_rounded,
    'TV & Home Theater': Icons.tv_rounded,
    'Kitchen': Icons.kitchen_rounded,
    'Furniture': Icons.chair_rounded,
    'General': Icons.shopping_bag_outlined,
  };

  static const _categoryColors = {
    'Laptops': Color(0xFFEFF6FF),
    'Phones': Color(0xFFDBEAFE),
    'Headphones': Color(0xFFE0F2FE),
    'Cameras': Color(0xFFFEF3C7),
    'Smartwatches': Color(0xFFD1FAE5),
    'Accessories': Color(0xFFF1F5F9),
    'Computers': Color(0xFFEFF6FF),
    'Tablets': Color(0xFFDBEAFE),
    'Gaming': Color(0xFFF3E8FF),
    'Audio': Color(0xFFE0F2FE),
    'TV & Home Theater': Color(0xFFFDECEA),
    'Kitchen': Color(0xFFD1FAE5),
    'Furniture': Color(0xFFFEF3C7),
    'General': Color(0xFFF1F5F9),
  };

  static const _categoryIconColors = {
    'Laptops': Color(0xFF2563EB),
    'Phones': Color(0xFF1D4ED8),
    'Headphones': Color(0xFF0284C7),
    'Cameras': Color(0xFFD97706),
    'Smartwatches': Color(0xFF059669),
    'Accessories': Color(0xFF475569),
    'Computers': Color(0xFF2563EB),
    'Tablets': Color(0xFF1D4ED8),
    'Gaming': Color(0xFF7C3AED),
    'Audio': Color(0xFF0284C7),
    'TV & Home Theater': Color(0xFFEF4444),
    'Kitchen': Color(0xFF059669),
    'Furniture': Color(0xFFD97706),
    'General': Color(0xFF475569),
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cats = await ref.read(productsRepositoryProvider).getCategories();
      setState(() {
        _categories = cats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  IconData _iconFor(String category) =>
      _categoryIcons[category] ?? Icons.shopping_bag_outlined;

  Color _bgColorFor(String category) =>
      _categoryColors[category] ?? const Color(0xFFF1F5F9);

  Color _iconColorFor(String category) =>
      _categoryIconColors[category] ?? const Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Categories',
          style: pjs(
            size: 18,
            weight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _loadCategories,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ProofBuyErrorWidget(
                    message: _error!,
                    onRetry: _loadCategories,
                  )
                : _categories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.category_outlined,
                                size: 48, color: Color(0xFF94A3B8)),
                            SizedBox(height: 12),
                            Text('No categories available',
                                style: pjs(size: 15, color: Color(0xFF64748B))),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.92,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return GestureDetector(
                            onTap: () => context
                                .go('/products?category=$category'),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color(0xFFE2E8F0)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: _bgColorFor(category),
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      _iconFor(category),
                                      size: 30,
                                      color: _iconColorFor(category),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    category,
                                    style: pjs(
                                      size: 14,
                                      weight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
