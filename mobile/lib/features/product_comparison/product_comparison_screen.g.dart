// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_comparison_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductComparisonNotifier)
final productComparisonProvider = ProductComparisonNotifierFamily._();

final class ProductComparisonNotifierProvider
    extends
        $AsyncNotifierProvider<ProductComparisonNotifier, List<RankedProduct>> {
  ProductComparisonNotifierProvider._({
    required ProductComparisonNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productComparisonProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productComparisonNotifierHash();

  @override
  String toString() {
    return r'productComparisonProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProductComparisonNotifier create() => ProductComparisonNotifier();

  @override
  bool operator ==(Object other) {
    return other is ProductComparisonNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productComparisonNotifierHash() =>
    r'61c0e0b663090fb3edd37514d45b949c5c6033a5';

final class ProductComparisonNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ProductComparisonNotifier,
          AsyncValue<List<RankedProduct>>,
          List<RankedProduct>,
          FutureOr<List<RankedProduct>>,
          String
        > {
  ProductComparisonNotifierFamily._()
    : super(
        retry: null,
        name: r'productComparisonProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductComparisonNotifierProvider call(String sessionId) =>
      ProductComparisonNotifierProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'productComparisonProvider';
}

abstract class _$ProductComparisonNotifier
    extends $AsyncNotifier<List<RankedProduct>> {
  late final _$args = ref.$arg as String;
  String get sessionId => _$args;

  FutureOr<List<RankedProduct>> build(String sessionId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<RankedProduct>>, List<RankedProduct>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<RankedProduct>>, List<RankedProduct>>,
              AsyncValue<List<RankedProduct>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
