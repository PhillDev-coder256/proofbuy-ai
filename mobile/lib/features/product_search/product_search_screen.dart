import 'package:flutter/material.dart';

class ProductSearchScreen extends StatelessWidget {
  const ProductSearchScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Searching Products')),
      body: const Center(child: Text('Product Search')),
    );
  }
}
