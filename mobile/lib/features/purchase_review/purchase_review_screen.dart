import 'package:flutter/material.dart';

class PurchaseReviewScreen extends StatelessWidget {
  const PurchaseReviewScreen({super.key, required this.productResultId});

  final String productResultId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Review')),
      body: const Center(child: Text('Purchase Review')),
    );
  }
}
