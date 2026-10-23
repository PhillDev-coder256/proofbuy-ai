import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme.dart';
import '../../core/networking/repositories_providers.dart';
import '../../core/widgets/error_widget.dart';
import '../../shared/models/ranked_product.dart';
import '../../shared/models/shopping_session.dart';

part 'product_search_screen.g.dart';

/// In-memory cache of fetched products for the current session.
/// Used by [ProductComparisonNotifier] to avoid a duplicate API call.
class _CachedProductsNotifier extends Notifier<List<RankedProduct>?> {
  @override
  List<RankedProduct>? build() => null;

  void set(List<RankedProduct> products) => state = products;
}

final cachedProductsProvider =
    NotifierProvider<_CachedProductsNotifier, List<RankedProduct>?>(
        _CachedProductsNotifier.new);

@riverpod
class ProductSearchNotifier extends _$ProductSearchNotifier {
  @override
  Future<ShoppingSession> build(String sessionId) async {
    final session = await ref
        .read(shoppingRepositoryProvider)
        .getSession(sessionId);
    // Pre-fetch and cache products so the comparison screen skips the API call.
    final products =
        await ref.read(productsRepositoryProvider).getProducts(sessionId);
    ref.read(cachedProductsProvider.notifier).set(products);
    return session;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProductSearchScreen — animated loading screen
// ─────────────────────────────────────────────────────────────────────────────

class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<ProductSearchScreen> createState() =>
      _ProductSearchScreenState();
}

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen> {
  // -1 means nothing highlighted yet; increments to 4
  int _currentStep = -1;
  bool _navigated = false;
  bool _dataReady = false;

  Timer? _timer;

  static const _steps = [
    'Understanding your requirements',
    'Finding relevant products',
    'Checking specifications',
    'Comparing prices and availability',
    'Preparing AI recommendations',
  ];

  static const _stepIcons = [
    Icons.psychology_outlined,
    Icons.search_rounded,
    Icons.check_circle_outline_rounded,
    Icons.price_check_rounded,
    Icons.auto_awesome_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (!mounted) return;
      setState(() {
        if (_currentStep < 4) {
          _currentStep++;
        }
      });
      // If data was already ready but we hadn't hit step 1 yet, navigate now
      if (_dataReady && _currentStep >= 1 && !_navigated) {
        _navigate();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigate() {
    if (_navigated) return;
    _navigated = true;
    context.go('/review-requirements/${widget.sessionId}');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productSearchProvider(widget.sessionId));

    // React to data / error
    ref.listen<AsyncValue<ShoppingSession>>(
      productSearchProvider(widget.sessionId),
      (_, next) {
        if (next.hasValue && next.value != null) {
          if (_currentStep >= 1) {
            _navigate();
          } else {
            _dataReady = true;
          }
        }
      },
    );

    if (state.hasError) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FF),
        body: SafeArea(
          child: ProofBuyErrorWidget(
            message: state.error.toString(),
            onRetry: () =>
                ref.invalidate(productSearchProvider(widget.sessionId)),
          ),
        ),
      );
    }

    final session = state.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back arrow
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Color(0xFF0A0E2E),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Analyzing ',
                      style: pjs(
                        size: 26,
                        weight: FontWeight.bold,
                        color: const Color(0xFF0A0E2E),
                      ),
                    ),
                    TextSpan(
                      text: 'Your Request',
                      style: pjs(
                        size: 26,
                        weight: FontWeight.bold,
                        color: const Color(0xFF6C47FF),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Our AI is working through your brief to find the best products.',
                style: pjs(size: 14, color: const Color(0xFF9CA3AF)),
              ),

              const SizedBox(height: 20),

              // Brief card
              if (session != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 18,
                        color: Color(0xFF6C47FF),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '"${session.briefText}"',
                          style: pjs(
                            size: 13,
                            color: const Color(0xFF4B5563),
                            style: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Centered illustration
              Center(
                child: Image.asset(
                  'assets/images/home-image.png',
                  width: 240,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    width: 240,
                    height: 200,
                    child: Icon(Icons.smart_toy_outlined,
                        size: 80, color: Color(0xFF9CA3AF)),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 5-step timeline
              ..._buildTimeline(),

              const SizedBox(height: 24),

              // Sample products section
              Text(
                'Sample Products',
                style: pjs(
                  size: 15,
                  weight: FontWeight.w700,
                  color: const Color(0xFF0A0E2E),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) =>
                      _MockProductCard(index: index),
                ),
              ),

              const SizedBox(height: 20),

              // Info banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Color(0xFF1A73E8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Results are ranked by AI score, price, and availability.',
                        style: pjs(size: 12, color: const Color(0xFF1A73E8)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTimeline() {
    final widgets = <Widget>[];

    for (int i = 0; i < _steps.length; i++) {
      widgets.add(_StepRow(
        index: i,
        label: _steps[i],
        icon: _stepIcons[i],
        currentStep: _currentStep,
      ));

      if (i < _steps.length - 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Container(
              width: 2,
              height: 20,
              color: const Color(0xFFE5E7EB),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step Row
// ─────────────────────────────────────────────────────────────────────────────

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.label,
    required this.icon,
    required this.currentStep,
  });

  final int index;
  final String label;
  final IconData icon;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final isDone = index < currentStep;
    final isActive = index == currentStep;

    Widget leadingCircle;
    if (isDone) {
      leadingCircle = Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFF16A34A),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 18, color: Colors.white),
      );
    } else if (isActive) {
      leadingCircle = Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFF6C47FF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      );
    } else {
      // Pending — dotted border
      leadingCircle = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFD1D5DB),
            width: 1.5,
          ),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            '...',
            style: pjs(size: 10, color: const Color(0xFF9CA3AF)),
          ),
        ),
      );
    }

    final String rightLabel;
    if (isDone) {
      rightLabel = '${index + 1}s';
    } else if (isActive) {
      rightLabel = '';
    } else {
      rightLabel = '-';
    }

    return Row(
      children: [
        leadingCircle,
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: pjs(
              size: 14,
              weight: isDone || isActive ? FontWeight.w600 : FontWeight.w400,
              color: isDone
                  ? const Color(0xFF16A34A)
                  : isActive
                      ? const Color(0xFF0A0E2E)
                      : const Color(0xFF9CA3AF),
            ),
          ),
        ),
        if (rightLabel.isNotEmpty)
          Text(
            rightLabel,
            style: pjs(
              size: 12,
              color: isDone
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF9CA3AF),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock product card for the sample horizontal section
// ─────────────────────────────────────────────────────────────────────────────

class _MockProductCard extends StatelessWidget {
  const _MockProductCard({required this.index});

  final int index;

  static const _mockNames = [
    'Laptop Pro X',
    'UltraBook 15',
    'WorkStation Z',
    'Budget Flex',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 28,
              color: Color(0xFFD1D5DB),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _mockNames[index % _mockNames.length],
              style: pjs(
                size: 11,
                weight: FontWeight.w600,
                color: const Color(0xFF0A0E2E),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$---.--',
            style: pjs(
              size: 12,
              weight: FontWeight.w700,
              color: const Color(0xFF6C47FF),
            ),
          ),
        ],
      ),
    );
  }
}
