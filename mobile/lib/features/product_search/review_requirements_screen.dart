import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/networking/repositories_providers.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/shimmer_widgets.dart';
import '../../shared/models/shopping_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final reviewSessionProvider =
    FutureProvider.autoDispose.family<ShoppingSession, String>(
  (ref, sessionId) =>
      ref.read(shoppingRepositoryProvider).getSession(sessionId),
);

// ─────────────────────────────────────────────────────────────────────────────
// Helpers — attribute display metadata
// ─────────────────────────────────────────────────────────────────────────────

IconData _iconFor(String attribute) {
  final a = attribute.toLowerCase();
  if (a.contains('price') || a.contains('budget') || a.contains('cost')) {
    return Icons.attach_money_rounded;
  }
  if (a.contains('ram') || a.contains('memory')) return Icons.memory_outlined;
  if (a.contains('storage') || a.contains('disk') || a.contains('ssd')) {
    return Icons.storage_rounded;
  }
  if (a.contains('battery') || a.contains('battery_life')) {
    return Icons.battery_charging_full_rounded;
  }
  if (a.contains('display') || a.contains('screen') || a.contains('size')) {
    return Icons.monitor_rounded;
  }
  if (a.contains('processor') || a.contains('cpu') || a.contains('chip')) {
    return Icons.developer_board_rounded;
  }
  if (a.contains('gpu') || a.contains('graphics')) {
    return Icons.videogame_asset_outlined;
  }
  if (a.contains('camera') || a.contains('mp') || a.contains('megapixel')) {
    return Icons.camera_alt_outlined;
  }
  if (a.contains('brand') || a.contains('manufacturer')) {
    return Icons.business_outlined;
  }
  if (a.contains('color') || a.contains('colour')) {
    return Icons.color_lens_outlined;
  }
  if (a.contains('weight') || a.contains('kg') || a.contains('gram')) {
    return Icons.scale_outlined;
  }
  if (a.contains('os') || a.contains('operating') || a.contains('system')) {
    return Icons.computer_rounded;
  }
  if (a.contains('wireless') || a.contains('bluetooth') || a.contains('wifi')) {
    return Icons.wifi_rounded;
  }
  if (a.contains('noise') || a.contains('cancell')) {
    return Icons.headphones_rounded;
  }
  if (a.contains('model')) return Icons.info_outline_rounded;
  if (a.contains('resolution')) return Icons.high_quality_rounded;
  if (a.contains('refresh')) return Icons.refresh_rounded;
  if (a.contains('zoom')) return Icons.zoom_in_rounded;
  if (a.contains('waterproof') || a.contains('water')) {
    return Icons.water_drop_outlined;
  }
  if (a.contains('gender')) return Icons.people_outline_rounded;
  if (a.contains('material')) return Icons.layers_outlined;
  if (a.contains('style')) return Icons.style_outlined;
  return Icons.tune_rounded;
}

String _labelFor(String attribute) {
  // Convert snake_case to Title Case, expand known abbreviations
  const known = {
    'ram_gb': 'Minimum RAM',
    'storage_gb': 'Minimum Storage',
    'battery_life_hours': 'Battery Life',
    'display_size_inches': 'Display Size',
    'refresh_rate_hz': 'Refresh Rate',
    'megapixels': 'Camera Resolution',
    'has_noise_cancellation': 'Noise Cancellation',
    'is_wireless': 'Wireless',
    'has_5g': '5G Support',
    'has_nfc': 'NFC',
    'is_mirrorless': 'Mirrorless',
    'is_smart': 'Smart TV',
    'has_hdr': 'HDR',
    'is_waterproof': 'Waterproof',
    'is_foldable': 'Foldable',
    'has_microphone': 'Built-in Microphone',
    'optical_zoom_x': 'Optical Zoom',
    'video_resolution': 'Video Resolution',
    'battery_mah': 'Battery Capacity',
    'camera_mp': 'Camera Megapixels',
  };
  if (known.containsKey(attribute)) return known[attribute]!;
  return attribute
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

String _operatorLabel(String op) {
  switch (op) {
    case 'gte': return '≥';
    case 'lte': return '≤';
    case 'eq':  return '=';
    case 'neq': return '≠';
    case 'contains': return 'includes';
    default: return op;
  }
}

String _formatValue(dynamic value, String? unit) {
  final v = value?.toString() ?? '';
  if (v == 'true') return 'Yes';
  if (v == 'false') return 'No';
  if (unit != null && unit.isNotEmpty) return '$v $unit';
  return v;
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
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
  // Editable copies of what the AI extracted
  String _category = '';
  double _maxPrice = 1200;
  String _budgetCurrency = 'USD';

  // Dynamic constraints from AI — list of {attribute, operator, value, unit}
  List<Map<String, dynamic>> _constraints = [];

  // Soft preferences as editable tags
  List<String> _softPrefs = [];

  // Additional requirements the user types in
  List<String> _additionalReqs = [];
  final _addReqController = TextEditingController();

  bool _initialized = false;
  String _briefText = '';

  @override
  void dispose() {
    _addReqController.dispose();
    super.dispose();
  }

  void _initFromSession(ShoppingSession session) {
    if (_initialized) return;
    _initialized = true;

    _briefText = session.briefText;
    final reqs = session.requirementsJson ?? {};

    // Category
    _category = (reqs['product_category'] as String? ?? '').trim();

    // Budget
    final bMax = reqs['budget_max'];
    if (bMax != null) {
      _maxPrice = (double.tryParse(bMax.toString()) ?? 1200).clamp(1, 50000).toDouble();
    }
    _budgetCurrency = (reqs['budget_currency'] as String? ?? 'USD').toUpperCase();

    // Hard constraints — keep ALL of them dynamically
    final rawConstraints = reqs['hard_constraints'];
    if (rawConstraints is List) {
      _constraints = rawConstraints
          .whereType<Map>()
          .map((c) => Map<String, dynamic>.from(c))
          .toList();
    }

    // Soft preferences — extract use-case descriptors as tags
    final softPrefs = reqs['soft_preferences'];
    if (softPrefs is List) {
      _softPrefs = softPrefs
          .whereType<Map>()
          .map((p) => p['attribute']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // Use case as a soft pref tag if present
    final useCase = reqs['use_case'];
    if (useCase is String && useCase.isNotEmpty && !_softPrefs.contains(useCase)) {
      _softPrefs.insert(0, useCase);
    }
  }

  void _reset() {
    setState(() {
      _initialized = false;
      _constraints = [];
      _softPrefs = [];
      _additionalReqs = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(reviewSessionProvider(widget.sessionId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FF),
      body: SafeArea(
        child: sessionAsync.when(
          loading: () => const ReviewRequirementsShimmer(),
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
        // ── Top bar ─────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: Color(0xFF0A0E2E)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              Row(
                children: List.generate(3, (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == 1
                        ? const Color(0xFF6C47FF)
                        : const Color(0xFFD1D5DB),
                    shape: BoxShape.circle,
                  ),
                )),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.pop(),
                child: Text('Cancel',
                    style: pjs(
                        size: 14,
                        weight: FontWeight.w600,
                        color: const Color(0xFF6B7280))),
              ),
            ],
          ),
        ),

        // ── Header ─────────────────────────────────────────────────────────
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
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'Review Your ',
                          style: pjs(
                            size: 24,
                            weight: FontWeight.bold,
                            color: const Color(0xFF0A0E2E),
                          ),
                        ),
                        TextSpan(
                          text: 'Requirements',
                          style: pjs(
                            size: 24,
                            weight: FontWeight.bold,
                            color: const Color(0xFF6C47FF),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confirm or adjust before searching.',
                      style: pjs(size: 12, color: const Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/home-image.png',
                width: 70,
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 70,
                  height: 70,
                  child: Icon(Icons.smart_toy_outlined,
                      size: 36, color: Color(0xFF6C47FF)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // ── Scrollable body ─────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Original brief card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 16, color: Color(0xFF6C47FF)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _briefText,
                          style: pjs(
                            size: 12,
                            color: const Color(0xFF374151),
                            style: FontStyle.italic,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.go('/brief'),
                        child: Text('Edit',
                            style: pjs(
                              size: 12,
                              weight: FontWeight.w600,
                              color: const Color(0xFF6C47FF),
                            )),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section header
                Row(
                  children: [
                    Text('Interpreted Requirements',
                        style: pjs(
                          size: 15,
                          weight: FontWeight.bold,
                          color: const Color(0xFF0A0E2E),
                        )),
                    const Spacer(),
                    GestureDetector(
                      onTap: _reset,
                      child: Row(
                        children: [
                          const Icon(Icons.refresh_rounded,
                              size: 14, color: Color(0xFF6C47FF)),
                          const SizedBox(width: 4),
                          Text('Reset',
                              style: pjs(
                                  size: 13, color: const Color(0xFF6C47FF))),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Category ───────────────────────────────────────────────
                if (_category.isNotEmpty)
                  _DynamicCard(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: _category,
                    onEdit: null, // read-only
                  ),

                if (_category.isNotEmpty) const SizedBox(height: 10),

                // ── Price / Budget ─────────────────────────────────────────
                _PriceCard(
                  price: _maxPrice,
                  currency: _budgetCurrency,
                  onChanged: (v) => setState(() => _maxPrice = v),
                ),

                const SizedBox(height: 10),

                // ── All dynamic constraints from AI ────────────────────────
                // Skip price (already shown above), show everything else
                ..._constraints
                    .where((c) {
                      final attr = (c['attribute'] as String? ?? '').toLowerCase();
                      return !attr.contains('price') && !attr.contains('budget');
                    })
                    .map((c) {
                      final attr = c['attribute'] as String? ?? '';
                      final op   = c['operator']  as String? ?? 'eq';
                      final val  = c['value'];
                      final unit = c['unit']       as String?;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DynamicCard(
                          icon: _iconFor(attr),
                          label: _labelFor(attr),
                          value:
                              '${_operatorLabel(op)} ${_formatValue(val, unit)}',
                          badge: _operatorLabel(op),
                          onEdit: () => _editConstraint(c),
                        ),
                      );
                    }),

                // ── Soft preferences (use case / purposes) ─────────────────
                if (_softPrefs.isNotEmpty) ...[
                  _TagsCard(
                    icon: Icons.widgets_outlined,
                    label: 'Purpose / Use Case',
                    tags: _softPrefs,
                    onRemove: (t) => setState(() => _softPrefs.remove(t)),
                  ),
                  const SizedBox(height: 10),
                ],

                // ── Additional requirements ────────────────────────────────
                _AdditionalCard(
                  items: _additionalReqs,
                  controller: _addReqController,
                  onAdd: (v) => setState(() {
                    _additionalReqs.add(v);
                    _addReqController.clear();
                  }),
                  onRemove: (v) =>
                      setState(() => _additionalReqs.remove(v)),
                ),

                const SizedBox(height: 24),

                // ── CTA ────────────────────────────────────────────────────
                GestureDetector(
                  onTap: () =>
                      context.go('/results/${widget.sessionId}'),
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
                        const Icon(Icons.auto_awesome_rounded,
                            size: 18, color: Colors.white),
                        const SizedBox(width: 10),
                        Text('Find Best Products',
                            style: pjs(
                              size: 16,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            )),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 18, color: Colors.white),
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

  void _editConstraint(Map<String, dynamic> constraint) {
    // Simple edit dialog for the constraint value
    final attr  = constraint['attribute'] as String? ?? '';
    final ctrl  = TextEditingController(
        text: constraint['value']?.toString() ?? '');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_labelFor(attr),
            style: pjs(size: 16, weight: FontWeight.w700,
                color: const Color(0xFF0A0E2E))),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: pjs(size: 15, color: const Color(0xFF0A0E2E)),
          decoration: InputDecoration(
            hintText: 'Enter value…',
            hintStyle: pjs(size: 14, color: const Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color(0xFF6C47FF), width: 2)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: pjs(size: 14, color: const Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                constraint['value'] = ctrl.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: Text('Save',
                style: pjs(size: 14,
                    weight: FontWeight.w700,
                    color: const Color(0xFF6C47FF))),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dynamic constraint card — shows any attribute/value pair
// ─────────────────────────────────────────────────────────────────────────────

class _DynamicCard extends StatelessWidget {
  const _DynamicCard({
    required this.icon,
    required this.label,
    required this.value,
    this.badge,
    this.onEdit,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? badge;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF6C47FF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: pjs(size: 11,
                        color: const Color(0xFF9CA3AF))),
                const SizedBox(height: 2),
                Text(value,
                    style: pjs(size: 14,
                        weight: FontWeight.w600,
                        color: const Color(0xFF0A0E2E))),
              ],
            ),
          ),
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_outlined,
                    size: 14, color: Color(0xFF6C47FF)),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Price slider card
// ─────────────────────────────────────────────────────────────────────────────

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.price,
    required this.currency,
    required this.onChanged,
  });

  final double price;
  final String currency;
  final ValueChanged<double> onChanged;

  String get _symbol {
    const m = {
      'USD': '\$', 'EUR': '€', 'GBP': '£', 'KES': 'KSh',
      'NGN': '₦', 'GHS': '₵', 'ZAR': 'R', 'INR': '₹',
    };
    return m[currency] ?? '$currency ';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.attach_money_rounded,
                    size: 16, color: Color(0xFF6C47FF)),
              ),
              const SizedBox(width: 12),
              Text('Maximum Price',
                  style: pjs(size: 11, color: const Color(0xFF9CA3AF))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$_symbol${price.toStringAsFixed(0)}',
            style: pjs(
              size: 20,
              weight: FontWeight.w800,
              color: const Color(0xFF6C47FF),
            ),
          ),
          Slider(
            value: price.clamp(100, 50000),
            min: 100,
            max: 50000,
            divisions: 499,
            activeColor: const Color(0xFF6C47FF),
            inactiveColor: const Color(0xFFE5E7EB),
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_symbol}100',
                  style: pjs(size: 10, color: const Color(0xFF9CA3AF))),
              Text('${_symbol}50,000',
                  style: pjs(size: 10, color: const Color(0xFF9CA3AF))),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tags card (soft preferences)
// ─────────────────────────────────────────────────────────────────────────────

class _TagsCard extends StatelessWidget {
  const _TagsCard({
    required this.icon,
    required this.label,
    required this.tags,
    required this.onRemove,
  });

  final IconData icon;
  final String label;
  final List<String> tags;
  final void Function(String) onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF6C47FF)),
              ),
              const SizedBox(width: 12),
              Text(label,
                  style: pjs(size: 13,
                      weight: FontWeight.w600,
                      color: const Color(0xFF0A0E2E))),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((t) => Chip(
              label: Text(t,
                  style: pjs(size: 12, color: const Color(0xFF6C47FF))),
              backgroundColor: const Color(0xFFF5F3FF),
              deleteIcon: const Icon(Icons.close, size: 13,
                  color: Color(0xFF6C47FF)),
              onDeleted: () => onRemove(t),
              side: const BorderSide(color: Color(0xFFDDD6FE)),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Additional requirements card
// ─────────────────────────────────────────────────────────────────────────────

class _AdditionalCard extends StatelessWidget {
  const _AdditionalCard({
    required this.items,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> items;
  final TextEditingController controller;
  final void Function(String) onAdd;
  final void Function(String) onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_circle_outline_rounded,
                    size: 16, color: Color(0xFF6C47FF)),
              ),
              const SizedBox(width: 12),
              Text('Additional Requirements',
                  style: pjs(size: 13,
                      weight: FontWeight.w600,
                      color: const Color(0xFF0A0E2E))),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((r) => Chip(
                label: Text(r,
                    style: pjs(size: 12, color: const Color(0xFF0A0E2E))),
                deleteIcon: const Icon(Icons.close, size: 13,
                    color: Color(0xFF6B7280)),
                onDeleted: () => onRemove(r),
                backgroundColor: const Color(0xFFF3F4F6),
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: pjs(size: 13, color: const Color(0xFF0A0E2E)),
                  decoration: InputDecoration(
                    hintText: 'Add a requirement…',
                    hintStyle: pjs(size: 13, color: const Color(0xFF9CA3AF)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF6C47FF), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  onSubmitted: (v) {
                    if (v.trim().isNotEmpty) onAdd(v.trim());
                  },
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final v = controller.text.trim();
                  if (v.isNotEmpty) onAdd(v);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C47FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
