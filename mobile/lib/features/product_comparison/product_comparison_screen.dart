import 'package:flutter/material.dart';

class ProductComparisonScreen extends StatelessWidget {
  const ProductComparisonScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Results')),
      body: const Center(child: Text('Product Comparison')),
    );
  }
}
