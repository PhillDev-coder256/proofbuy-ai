// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the PayPal checkout state machine.
///
/// SECURITY INVARIANT: [CheckoutState.success] is ONLY set when the backend
/// capture response has `verified == true`.  A `verified == false` response
/// always transitions to [CheckoutState.failure].

@ProviderFor(CheckoutNotifier)
final checkoutProvider = CheckoutNotifierProvider._();

/// Drives the PayPal checkout state machine.
///
/// SECURITY INVARIANT: [CheckoutState.success] is ONLY set when the backend
/// capture response has `verified == true`.  A `verified == false` response
/// always transitions to [CheckoutState.failure].
final class CheckoutNotifierProvider
    extends $NotifierProvider<CheckoutNotifier, CheckoutState> {
  /// Drives the PayPal checkout state machine.
  ///
  /// SECURITY INVARIANT: [CheckoutState.success] is ONLY set when the backend
  /// capture response has `verified == true`.  A `verified == false` response
  /// always transitions to [CheckoutState.failure].
  CheckoutNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkoutProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkoutNotifierHash();

  @$internal
  @override
  CheckoutNotifier create() => CheckoutNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckoutState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckoutState>(value),
    );
  }
}

String _$checkoutNotifierHash() => r'd4150189114ad724991451a4facfbdc21ed4241a';

/// Drives the PayPal checkout state machine.
///
/// SECURITY INVARIANT: [CheckoutState.success] is ONLY set when the backend
/// capture response has `verified == true`.  A `verified == false` response
/// always transitions to [CheckoutState.failure].

abstract class _$CheckoutNotifier extends $Notifier<CheckoutState> {
  CheckoutState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CheckoutState, CheckoutState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CheckoutState, CheckoutState>,
              CheckoutState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
