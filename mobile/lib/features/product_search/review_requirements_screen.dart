import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/networking/repositories_providers.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../shared/models/shopping_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final reviewSessionProvider =
    FutureProvider.autoDispose.family<ShoppingSession, String>(
  (ref, sessionId) => ref.read(shoppingRepositoryProvider).getSession(sessionId),
);

// ─────────────────────────────────────────────────────────────────────────────
// ReviewRequirementsScreen
// ─────────────────────────────────────────────────────────────────────────────

class ReviewRequirementsScreen extends ConsumerStatefulWidget {
  const ReviewRequirementsScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<ReviewRequirementsScreen> createState() =>
      _ReviewRequirementsScreenState();
}

class _ReviewRequirementsScreenState
    extends ConsumerState<ReviewRequirementsScreen> {
  // ── Editable state ────────────────────────────────────────────────────────
  String _category = '';
  double _maxPrice = 1200;
  String _minRam = 'Any';
  String _batteryLife = 'Any';
  List<String> _purposes = [];
  List<String> _additionalReqs = [];
  final TextEditingController _addReqController = TextEditingController();

  bool _initialized = false;

  static const _purposeOptions = [
    'Gaming',
    'Video Editing',
    'General Use',
    'Work',
    'Study',
  ];

  static const _categoryOptions = [
    'Laptops',
    'Phones',
    'Headphones',
    'Cameras',
    'TVs',
    'Other',
  ];

  static const _ramOptions = [
    'Any',
    '4 GB',
    '8 GB',
    '16 GB',
    '32 GB',
    '64 GB',
  ];

  static const _batteryOptions = [
    'Any',
    '4+ hours',
    '6+ hours',
    '8+ hours',
    '10+ hours',
    '12+ hours',
  ];

  @override
  void dispose() {
    _addReqController.dispose();
    super.dispose();
  }

  void _initFromSession(ShoppingSession session) {
    if (_initialized) return;
    _initialized = true;

    final reqs = session.requirementsJson ?? {};

    _category =
        reqs['product_category'] as String? ?? '';
    if (!_categoryOptions.contains(_category)) _category = '';

    final budgetMax = reqs['budget_max'];
    if (budgetMax != null) {
      final parsed = double.tryParse(budgetMax.toString()) ?? 1200;
      _maxPrice = parsed.clamp(100, 5000);
    }

    // Purposes from soft_preferences/use_case
    final softPrefs = reqs['soft_preferences'];
    if (softPrefs is Map) {
      final useCase = softPrefs['use_case'];
      if (useCase is List) {
        _purposes =
            useCase.whereType<String>().where(_purposeOptions.contains).toList();
      } else if (useCase is String && _purposeOptions.contains(useCase)) {
        _purposes = [useCase];
      }
    }

    // Hard constraints: ram_gb and battery_life
    final hardConstraints = reqs['hard_constraints'];
    if (hardConstraints is Map) {
      final ramGb = hardConstraints['ram_gb'];
      if (ramGb != null) {
        final ramStr = '$ramGb GB';
        _minRam = _ramOptions.contains(ramStr) ? ramStr : 'Any';
      }
      final battery = hardConstraints['battery_life'];
      if (battery != null) {
        _batteryLife = _batteryOptions.contains(battery.toString())
            ? battery.toString()
            : 'Any';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(reviewSessionProvider(widget.sessionId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FF),
      body: SafeArea(
        child: sessionAsync.when(
          loading: () =>
              const LoadingWidget(message: 'Loading session…'),
          error: (error, _) => ProofBuyErrorWidget(
            message: error.toString(),
            onRetry: () =>
                ref.invalidate(reviewSessionProvider(widget.sessionId)),
          ),
          data: (session) {
            _initFromSession(session);
            return _buildBody(context, session);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ShoppingSession session) {
    return Column(
      children: [
        // Top row: back | step dots | cancel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: Color(0xFF0A0E2E),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              // 3 step dots — dot 2 (index 1) purple
              Row(
                children: List.generate(3, (i) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == 1
                          ? const Color(0xFF6C47FF)
                          : const Color(0xFFD1D5DB),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Cancel',
                  style: pjs(
                    size: 14,
                    weight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Header row: title + image
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Review Your ',
                            style: pjs(
                              size: 26,
                              weight: FontWeight.bold,
                              color: const Color(0xFF0A0E2E),
                            ),
                          ),
                          TextSpan(
                            text: 'Requirements',
                            style: pjs(
                              size: 26,
                              weight: FontWeight.bold,
                              color: const Color(0xFF6C47FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Confirm or adjust before searching.',
                      style: pjs(
                        size: 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/home-image.png',
                width: 80,
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 80,
                  height: 80,
                  child: Icon(Icons.smart_toy_outlined,
                      size: 40, color: Color(0xFF6C47FF)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Scrollable requirements
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Original request card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: Color(0xFF6C47FF),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Your Brief',
                            style: pjs(
                              size: 13,
                              weight: FontWeight.bold,
                              color: const Color(0xFF0A0E2E),
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => context.go('/brief'),
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: Color(0xFF6C47FF),
                            ),
                            label: Text(
                              'Edit',
                              style: pjs(
                                size: 12,
                                color: const Color(0xFF6C47FF),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        session.briefText,
                        style: pjs(
                          size: 13,
                          color: const Color(0xFF6B7280),
                          style: FontStyle.italic,
                          height: 1.5,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section header
                Row(
                  children: [
                    Text(
                      'Interpreted Requirements',
                      style: pjs(
                        size: 15,
                        weight: FontWeight.bold,
                        color: const Color(0xFF0A0E2E),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _category = '';
                          _maxPrice = 1200;
                          _minRam = 'Any';
                          _batteryLife = 'Any';
                          _purposes = [];
                          _additionalReqs = [];
                          _initialized = false;
                        });
                      },
                      icon: const Icon(
                        Icons.refresh_rounded,
                        size: 14,
                        color: Color(0xFF6C47FF),
                      ),
                      label: Text(
                        'Reset',
                        style: pjs(
                          size: 13,
                          color: const Color(0xFF6C47FF),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 1. Category card
                _RequirementCard(
                  icon: Icons.category_outlined,
                  label: 'Category',
                  child: DropdownButton<String>(
                    value: _category.isEmpty ? null : _category,
                    hint: Text(
                      'Select category',
                      style: pjs(size: 14, color: const Color(0xFF9CA3AF)),
                    ),
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: _categoryOptions
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: pjs(
                                  size: 14,
                                  color: const Color(0xFF0A0E2E),
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // 2. Purpose card
                _RequirementCard(
                  icon: Icons.widgets_outlined,
                  label: 'Purpose',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _purposeOptions.map((p) {
                      final selected = _purposes.contains(p);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _purposes.remove(p);
                            } else {
                              _purposes.add(p);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF6C47FF)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            p,
                            style: pjs(
                              size: 13,
                              weight: FontWeight.w500,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // 3. Max Price card
                _RequirementCard(
                  icon: Icons.attach_money_rounded,
                  label: 'Maximum Price',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${_maxPrice.toStringAsFixed(0)}',
                        style: pjs(
                          size: 18,
                          weight: FontWeight.bold,
                          color: const Color(0xFF6C47FF),
                        ),
                      ),
                      Slider(
                        value: _maxPrice,
                        min: 100,
                        max: 5000,
                        divisions: 49,
                        activeColor: const Color(0xFF6C47FF),
                        inactiveColor: const Color(0xFFE5E7EB),
                        onChanged: (val) =>
                            setState(() => _maxPrice = val),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$100',
                            style: pjs(
                                size: 11,
                                color: const Color(0xFF9CA3AF)),
                          ),
                          Text(
                            '\$5,000',
                            style: pjs(
                                size: 11,
                                color: const Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 4. Min RAM card
                _RequirementCard(
                  icon: Icons.memory_outlined,
                  label: 'Minimum RAM',
                  child: DropdownButton<String>(
                    value: _minRam,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: _ramOptions
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r,
                                style: pjs(
                                  size: 14,
                                  color: const Color(0xFF0A0E2E),
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _minRam = val);
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // 5. Battery Life card
                _RequirementCard(
                  icon: Icons.battery_charging_full_rounded,
                  label: 'Battery Life',
                  child: DropdownButton<String>(
                    value: _batteryLife,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: _batteryOptions
                        .map((b) => DropdownMenuItem(
                              value: b,
                              child: Text(
                                b,
                                style: pjs(
                                  size: 14,
                                  color: const Color(0xFF0A0E2E),
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _batteryLife = val);
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // 6. Additional requirements card
                _RequirementCard(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Additional Requirements',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_additionalReqs.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _additionalReqs.map((req) {
                            return Chip(
                              label: Text(
                                req,
                                style: pjs(
                                    size: 12,
                                    color: const Color(0xFF0A0E2E)),
                              ),
                              deleteIcon: const Icon(Icons.close, size: 14),
                              onDeleted: () => setState(
                                  () => _additionalReqs.remove(req)),
                              backgroundColor: const Color(0xFFF3F4F6),
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _addReqController,
                              style: pjs(
                                  size: 13,
                                  color: const Color(0xFF0A0E2E)),
                              decoration: InputDecoration(
                                hintText: 'Add a requirement…',
                                hintStyle: pjs(
                                    size: 13,
                                    color: const Color(0xFF9CA3AF)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF6C47FF), width: 1.5),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                isDense: true,
                              ),
                              onSubmitted: (val) {
                                if (val.trim().isNotEmpty) {
                                  setState(() {
                                    _additionalReqs.add(val.trim());
                                    _addReqController.clear();
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              final val = _addReqController.text.trim();
                              if (val.isNotEmpty) {
                                setState(() {
                                  _additionalReqs.add(val);
                                  _addReqController.clear();
                                });
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C47FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.add,
                                  size: 20, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // CTA button
                GestureDetector(
                  onTap: () => context.go('/results/${widget.sessionId}'),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: ProofBuyGradients.button,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x406C47FF),
                          blurRadius: 20,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Find Best Products',
                          style: pjs(
                            size: 16,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Requirement card wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _RequirementCard extends StatelessWidget {
  const _RequirementCard({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF6C47FF)),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: pjs(
                  size: 14,
                  weight: FontWeight.w600,
                  color: const Color(0xFF0A0E2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
