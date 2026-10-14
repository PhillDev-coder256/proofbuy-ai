import 'package:flutter/material.dart';

class TransactionResultScreen extends StatelessWidget {
  const TransactionResultScreen({super.key, required this.purchaseId});

  final String purchaseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Result')),
      body: const Center(child: Text('Transaction Result')),
    );
  }
}
