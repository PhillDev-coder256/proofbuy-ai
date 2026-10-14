// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_brief_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ShoppingBriefNotifier)
final shoppingBriefProvider = ShoppingBriefNotifierProvider._();

final class ShoppingBriefNotifierProvider
    extends
        $NotifierProvider<ShoppingBriefNotifier, AsyncValue<ShoppingSession?>> {
  ShoppingBriefNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shoppingBriefProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shoppingBriefNotifierHash();

  @$internal
  @override
  ShoppingBriefNotifier create() => ShoppingBriefNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ShoppingSession?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ShoppingSession?>>(value),
    );
  }
}

String _$shoppingBriefNotifierHash() =>
    r'424deaabfd3f38a682a1d7a401ad0f925b5e23fa';

abstract class _$ShoppingBriefNotifier
    extends $Notifier<AsyncValue<ShoppingSession?>> {
  AsyncValue<ShoppingSession?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<ShoppingSession?>, AsyncValue<ShoppingSession?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ShoppingSession?>,
                AsyncValue<ShoppingSession?>
              >,
              AsyncValue<ShoppingSession?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
