import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme.dart';
import '../../shared/models/history_item.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  const OrderDetailsScreen({
    super.key,
    required this.recordId,
  });

  final String recordId;

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  int _rating = 5;
  final _reviewController = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _loadExistingReview();
  }

  Future<void> _loadExistingReview() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRating = prefs.getInt('review_rating_${widget.recordId}');
    final savedReview = prefs.getString('review_text_${widget.recordId}');
    if (savedRating != null) {
      setState(() {
        _rating = savedRating;
        if (savedReview != null) _reviewController.text = savedReview;
        _submitted = true;
      });
    }
  }

  Future<void> _submitReview() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('review_rating_${widget.recordId}', _rating);
    await prefs.setString('review_text_${widget.recordId}', _reviewController.text.trim());
    setState(() => _submitted = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully! Thank you.')),
      );
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extraItem = GoRouterState.of(context).extra as HistoryItem?;

    if (extraItem == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'Order Details',
            style: pjs(size: 18, weight: FontWeight.w700, color: const Color(0xFF0F172A)),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Center(
        child: Text(
          'Order details not found.',
          style: pjs(size: 14, color: const Color(0xFF64748B)),
        ),
      ),
      );
    }

    final record = extraItem.purchaseRecord;
    final product = extraItem.product;
    final formattedDate = DateFormat('MMM d, y • h:mm a').format(record.createdAt.toLocal());
    final formattedAmount = '${record.amount.toStringAsFixed(2)} ${record.currency}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: pjs(
            size: 18,
            weight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Product Summary Card ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: product?.imageUrl != null &&
                              product!.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _ImageFallback(),
                            )
                          : _ImageFallback(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product?.name ?? 'Purchased Product',
                            style: pjs(
                              size: 15,
                              weight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (product?.merchant != null &&
                              product!.merchant!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Sold by ${product.merchant}',
                              style: pjs(
                                  size: 12, color: const Color(0xFF64748B)),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            formattedAmount,
                            style: pjs(
                              size: 16,
                              weight: FontWeight.w800,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Transaction Info ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Summary',
                      style: pjs(
                        size: 14,
                        weight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Order ID', value: record.id),
                    const Divider(height: 16),
                    _InfoRow(
                        label: 'PayPal Order Reference',
                        value: record.paypalOrderId ?? 'Verified Sandbox'),
                    const Divider(height: 16),
                    _InfoRow(label: 'Purchase Date', value: formattedDate),
                    const Divider(height: 16),
                    _InfoRow(
                      label: 'Status',
                      value: record.status.toUpperCase(),
                      valueColor: const Color(0xFF059669),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Product Review & Rating Section ───────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                      _submitted ? 'Your Product Review' : 'Rate & Review Product',
                      style: pjs(
                        size: 16,
                        weight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _submitted
                          ? 'Thank you for reviewing this purchase.'
                          : 'Share your feedback to help improve AI recommendations.',
                      style: pjs(size: 12.5, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),

                    // Star rating selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          onPressed: () {
                            setState(() => _rating = star);
                          },
                          icon: Icon(
                            star <= _rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _reviewController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Write your review about this product...',
                        hintStyle: pjs(size: 13, color: const Color(0xFF94A3B8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        _submitted ? 'Update Review' : 'Submit Review',
                        style: pjs(
                          size: 15,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: pjs(size: 13, color: const Color(0xFF64748B)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: pjs(
              size: 13,
              weight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _ImageFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.shopping_bag_outlined,
          size: 32, color: Color(0xFF94A3B8)),
    );
  }
}
