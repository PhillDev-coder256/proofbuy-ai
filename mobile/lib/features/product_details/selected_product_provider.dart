import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/ranked_product.dart';

class SelectedProductNotifier extends Notifier<RankedProduct?> {
  @override
  RankedProduct? build() => null;

  void select(RankedProduct product) {
    state = product;
  }
}

final selectedProductProvider =
    NotifierProvider<SelectedProductNotifier, RankedProduct?>(
  SelectedProductNotifier.new,
);
