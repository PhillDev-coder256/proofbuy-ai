import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Displays a constraint check result as a coloured [Chip].
///
/// [result] should be one of: 'PASS', 'FAIL', 'UNKNOWN'.
class ConstraintBadge extends StatelessWidget {
  const ConstraintBadge({
    super.key,
    required this.attribute,
    required this.result,
  });

  final String attribute;
  final String result;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (result.toUpperCase()) {
      'PASS' => (ProofBuyColors.pass, Icons.check_circle),
      'FAIL' => (ProofBuyColors.fail, Icons.cancel),
      _ => (ProofBuyColors.unknown, Icons.help_outline),
    };

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(
        attribute,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
