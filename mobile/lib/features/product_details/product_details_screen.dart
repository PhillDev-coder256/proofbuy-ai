import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../core/networking/repositories_providers.dart';
import '../../core/widgets/shimmer_widgets.dart';
import '../../features/product_comparison/constraint_badge.dart';
import '../../shared/models/ranked_product.dart';
import 'selected_product_provider.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productResultId,
  });

  final String productResultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check GoRouter extra first, fall back to Riverpod selectedProductProvider
    final extraProduct = GoRouterState.of(context).extra as RankedProduct?;
    final storedProduct = ref.watch(selectedProductProvider);
    final product = extraProduct ?? storedProduct;

    if (product == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'Product Details',
            style: pjs(
              size: 18,
              weight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Text(
            'Product details unavailable.',
            style: pjs(size: 15, color: const Color(0xFF64748B)),
          ),
        ),
      );
    }

    return _ProductDetailsView(
      product: product,
      productResultId: product.productResultId ?? productResultId,
    );
  }
}

class _ProductDetailsView extends ConsumerStatefulWidget {
  const _ProductDetailsView({
    required this.product,
    required this.productResultId,
  });

  final RankedProduct product;
  final String productResultId;

  @override
  ConsumerState<_ProductDetailsView> createState() =>
      _ProductDetailsViewState();
}

class _ProductDetailsViewState extends ConsumerState<_ProductDetailsView> {
  late PageController _pageController;
  int _currentPage = 0;
  Future<ProductData?>? _detailFuture;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final id = widget.product.productData.channel3ProductId;
    if (id != null && id.isNotEmpty) {
      _detailFuture =
          ref.read(productDetailRepositoryProvider).getProductDetail(id);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FutureBuilder<ProductData?>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SafeArea(child: ProductDetailsShimmer());
          }
          // Use enriched data if available, otherwise fall back to original
          final effectiveData = snapshot.data ?? widget.product.productData;
          return _buildContent(context, effectiveData);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductData data) {
    final specs = data.specs;
    final techSpecs = specs != null
        ? specs.entries
            .where((e) => e.key != 'description' && e.key != 'features')
            .toList()
        : <MapEntry<String, dynamic>>[];

    // Effective description: top-level field first, then from specs
    final description = data.description ??
        (specs != null && specs['description'] is String
            ? specs['description'] as String
            : null);

    // Key features: top-level field first, then from specs
    final keyFeatures = (data.keyFeatures != null && data.keyFeatures!.isNotEmpty)
        ? data.keyFeatures!
        : (specs != null && specs['features'] is List
            ? (specs['features'] as List).map((e) => e.toString()).toList()
            : <String>[]);

    // Price formatting
    String priceText = '';
    if (data.price != null) {
      try {
        final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
        priceText = fmt.format(data.price);
      } catch (_) {
        priceText = '\$${data.price}'.trim();
      }
    }

    // Best offer
    ProductOffer? bestOffer;
    if (data.allOffers.isNotEmpty) {
      bestOffer =
          data.allOffers.reduce((a, b) => a.price < b.price ? a : b);
    }
    final displayPrice = bestOffer != null ? bestOffer.price : data.price;
    String displayPriceText = priceText;
    if (bestOffer != null) {
      try {
        final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
        displayPriceText = fmt.format(bestOffer.price);
      } catch (_) {
        displayPriceText = '\$${bestOffer.price}'.trim();
      }
    }

    final hasImages = data.allImages.isNotEmpty;
    final images = data.allImages;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── SECTION 1: IMAGE GALLERY ──────────────────────────────────
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  child: hasImages
                      ? PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          onPageChanged: (idx) {
                            setState(() => _currentPage = idx);
                          },
                          itemBuilder: (context, idx) {
                            final img = images[idx];
                            final imageUrl = img.cleanedUrl ?? img.url;
                            return CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 300,
                              placeholder: (ctx, url) => ProofShimmer(
                                child: ShimmerBox(
                                  width: double.infinity,
                                  height: 300,
                                  radius: 0,
                                ),
                              ),
                              errorWidget: (ctx, url, error) =>
                                  const _ImagePlaceholder(),
                            );
                          },
                        )
                      : (data.imageUrl != null && data.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: data.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 300,
                              placeholder: (ctx, url) => ProofShimmer(
                                child: ShimmerBox(
                                  width: double.infinity,
                                  height: 300,
                                  radius: 0,
                                ),
                              ),
                              errorWidget: (ctx, url, error) =>
                                  const _ImagePlaceholder(),
                            )
                          : const _ImagePlaceholder()),
                ),

                // Floating back button
                Positioned(
                  top: 48,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),

                // Dot indicators (only if multiple images)
                if (images.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (idx) {
                        final isCurrent = idx == _currentPage;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isCurrent ? 8 : 6,
                          height: isCurrent ? 8 : 6,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? ProofBuyColors.accent
                                : const Color(0xFFCBD5E1),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),

            // ── PADDED CONTENT ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ── SECTION 2: PRODUCT INFO ─────────────────────────────
                  // Brand / merchant
                  if (data.merchant != null && data.merchant!.isNotEmpty) ...[
                    Text(
                      data.merchant!,
                      style: pjs(
                        size: 12,
                        color: const Color(0xFF64748B),
                        weight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Product title
                  Text(
                    data.name,
                    style: pjs(
                      size: 24,
                      weight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Ratings row
                  if (data.ratings != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF59E0B),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data.ratings!.value.toStringAsFixed(1),
                          style: pjs(
                            size: 13,
                            weight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${data.ratings!.count} reviews)',
                          style: pjs(
                            size: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Category pill
                  if (data.categoryTitle != null &&
                      data.categoryTitle!.isNotEmpty) ...[
                    Chip(
                      label: Text(
                        data.categoryTitle!,
                        style: pjs(size: 11, weight: FontWeight.w500),
                      ),
                      backgroundColor: const Color(0xFFEFF6FF),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    const SizedBox(height: 8),
                  ],

                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),

                  // ── SECTION 3: PRICE ────────────────────────────────────
                  if (displayPriceText.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          displayPriceText,
                          style: pjs(
                            size: 24,
                            weight: FontWeight.w800,
                            color: const Color(0xFF2563EB),
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (bestOffer?.compareAtPrice != null &&
                            bestOffer!.compareAtPrice! > (displayPrice ?? 0)) ...[
                          const SizedBox(width: 8),
                          Text(
                            NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                                .format(bestOffer.compareAtPrice),
                            style: pjs(
                              size: 16,
                              color: const Color(0xFF94A3B8),
                              weight: FontWeight.w400,
                            ).copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Availability badge
                    if (data.allOffers.isNotEmpty) ...[
                      _buildAvailabilityBadge(
                          data.allOffers.first.availability),
                      const SizedBox(height: 8),
                    ],

                    const SizedBox(height: 4),
                  ],

                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 16),

                  // ── SECTION 4: ALL OFFERS ──────────────────────────────
                  if (data.allOffers.isNotEmpty) ...[
                    Text(
                      'Available From',
                      style: pjs(
                        size: 14,
                        weight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.allOffers.length,
                        itemBuilder: (context, idx) {
                          return _OfferCard(offer: data.allOffers[idx]);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 16),
                  ],

                  // ── SECTION 5: DESCRIPTION ─────────────────────────────
                  if (description != null && description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: pjs(
                        size: 14,
                        weight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: pjs(
                        size: 13,
                        color: const Color(0xFF475569),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── SECTION 6: KEY FEATURES ────────────────────────────
                  if (keyFeatures.isNotEmpty) ...[
                    Text(
                      'Key Features',
                      style: pjs(
                        size: 14,
                        weight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...keyFeatures.map(
                      (f) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 15,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                f,
                                style: pjs(
                                  size: 13,
                                  color: const Color(0xFF334155),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── SECTION 7: TECHNICAL SPECIFICATIONS ───────────────
                  if (techSpecs.isNotEmpty) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          'Technical Specifications',
                          style: pjs(
                            size: 14,
                            weight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: techSpecs.map((entry) {
                                return Container(
                                  width:
                                      (MediaQuery.of(context).size.width - 72) /
                                          2,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: pjs(
                                          size: 11,
                                          color: const Color(0xFF94A3B8),
                                          weight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        entry.value?.toString() ?? '—',
                                        style: pjs(
                                          size: 13,
                                          weight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── SECTION 8: MATERIALS ───────────────────────────────
                  if (data.materials != null &&
                      data.materials!.isNotEmpty) ...[
                    Text(
                      'Materials',
                      style: pjs(
                        size: 14,
                        weight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: data.materials!.map((m) {
                        return Chip(
                          label: Text(
                            m,
                            style: pjs(size: 12),
                          ),
                          backgroundColor: const Color(0xFFF1F5F9),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── SECTION 9: AI EXPLANATION ──────────────────────────
                  if (widget.product.explanation != null &&
                      widget.product.explanation!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded,
                                  size: 16, color: Color(0xFF2563EB)),
                              const SizedBox(width: 6),
                              Text(
                                'AI Match Analysis',
                                style: pjs(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.explanation!,
                            style: pjs(
                              size: 12.5,
                              color: const Color(0xFF1E293B),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── SECTION 10: CONSTRAINT RESULTS ────────────────────
                  if (widget.product.constraintResults.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verified Evidence Specs',
                            style: pjs(
                              size: 14,
                              weight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...widget.product.constraintResults.entries.map(
                            (e) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      e.key,
                                      style: pjs(
                                        size: 12.5,
                                        color: const Color(0xFF334155),
                                        weight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  ConstraintBadge(
                                    attribute: e.key,
                                    result: e.value,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── SECTION 11: AI MATCH CONFIDENCE ───────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'AI Match Confidence',
                              style:
                                  pjs(size: 12, color: const Color(0xFF64748B)),
                            ),
                            Text(
                              '${(widget.product.rankingConfidence * 100).toStringAsFixed(0)}%',
                              style: pjs(
                                size: 12,
                                weight: FontWeight.w700,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: widget.product.rankingConfidence,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE2E8F0),
                            color: ProofBuyColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── SECTION 12: BUY WITH PAYPAL ────────────────────────
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(selectedProductProvider.notifier)
                          .select(widget.product);
                      context.go(
                        '/review/${widget.productResultId}',
                        extra: widget.product,
                      );
                    },
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(27),
                        color: const Color(0xFF0070BA),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x300070BA),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Buy with PayPal',
                            style: pjs(
                              size: 16,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── SECTION 13: VIEW ON RETAILER ───────────────────────
                  if (data.sourceUrl != null &&
                      data.sourceUrl!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(data.sourceUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: Text(
                        'View on retailer site',
                        style: pjs(size: 14, weight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityBadge(String availability) {
    final inStock = availability.toLowerCase().contains('instock') ||
        availability.toLowerCase().contains('in stock');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: inStock
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        inStock ? 'In Stock' : 'Out of Stock',
        style: pjs(
          size: 12,
          weight: FontWeight.w600,
          color: inStock ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  final ProductOffer offer;

  @override
  Widget build(BuildContext context) {
    String priceText = '';
    try {
      final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
      priceText = fmt.format(offer.price);
    } catch (_) {
      priceText = '\$${offer.price}';
    }

    final inStock = offer.availability.toLowerCase().contains('instock') ||
        offer.availability.toLowerCase().contains('in stock');

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offer.domain,
            style: pjs(
              size: 13,
              weight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            priceText,
            style: pjs(
              size: 16,
              weight: FontWeight.w700,
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            inStock ? 'In Stock' : 'Out of Stock',
            style: pjs(
              size: 11,
              color: inStock
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse(offer.url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ProofBuyColors.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(32),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: pjs(size: 12, weight: FontWeight.w600),
              ),
              child: Text(
                'Shop Now',
                style: pjs(
                  size: 12,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Icons.shopping_bag_outlined,
            size: 56, color: Color(0xFF94A3B8)),
      ),
    );
  }
}
