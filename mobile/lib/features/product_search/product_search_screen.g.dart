// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_search_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductSearchNotifier)
final productSearchProvider = ProductSearchNotifierFamily._();

final class ProductSearchNotifierProvider
    extends $AsyncNotifierProvider<ProductSearchNotifier, ShoppingSession> {
  ProductSearchNotifierProvider._({
    required ProductSearchNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productSearchNotifierHash();

  @override
  String toString() {
    return r'productSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProductSearchNotifier create() => ProductSearchNotifier();

  @override
  bool operator ==(Object other) {
    return other is ProductSearchNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productSearchNotifierHash() =>
    r'422debaa7e2104d3804c1b26777ca8cf9fe00c31';

final class ProductSearchNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ProductSearchNotifier,
          AsyncValue<ShoppingSession>,
          ShoppingSession,
          FutureOr<ShoppingSession>,
          String
        > {
  ProductSearchNotifierFamily._()
    : super(
        retry: null,
        name: r'productSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductSearchNotifierProvider call(String sessionId) =>
      ProductSearchNotifierProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'productSearchProvider';
}

abstract class _$ProductSearchNotifier extends $AsyncNotifier<ShoppingSession> {
  late final _$args = ref.$arg as String;
  String get sessionId => _$args;

  FutureOr<ShoppingSession> build(String sessionId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ShoppingSession>, ShoppingSession>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ShoppingSession>, ShoppingSession>,
              AsyncValue<ShoppingSession>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
