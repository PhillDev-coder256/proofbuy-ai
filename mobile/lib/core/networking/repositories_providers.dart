import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'api_client.dart';
import 'checkout_repository.dart';
import 'products_repository.dart';
import 'shopping_repository.dart';
import 'transactions_repository.dart';

part 'repositories_providers.g.dart';

@riverpod
ShoppingRepository shoppingRepository(Ref ref) =>
    ShoppingRepository(ref.watch(apiClientProvider));

@riverpod
ProductsRepository productsRepository(Ref ref) =>
    ProductsRepository(ref.watch(apiClientProvider));

@riverpod
CheckoutRepository checkoutRepository(Ref ref) =>
    CheckoutRepository(ref.watch(apiClientProvider));

@riverpod
TransactionsRepository transactionsRepository(Ref ref) =>
    TransactionsRepository(ref.watch(apiClientProvider));
