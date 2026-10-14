// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_result_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches the [AppTransaction] for the given [transactionId].
///
/// This provider is only called after [CheckoutScreen] confirms that the
/// backend returned `verified == true`.  Do NOT navigate to this screen
/// from any other path.

@ProviderFor(transactionResult)
final transactionResultProvider = TransactionResultFamily._();

/// Fetches the [AppTransaction] for the given [transactionId].
///
/// This provider is only called after [CheckoutScreen] confirms that the
/// backend returned `verified == true`.  Do NOT navigate to this screen
/// from any other path.

final class TransactionResultProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppTransaction>,
          AppTransaction,
          FutureOr<AppTransaction>
        >
    with $FutureModifier<AppTransaction>, $FutureProvider<AppTransaction> {
  /// Fetches the [AppTransaction] for the given [transactionId].
  ///
  /// This provider is only called after [CheckoutScreen] confirms that the
  /// backend returned `verified == true`.  Do NOT navigate to this screen
  /// from any other path.
  TransactionResultProvider._({
    required TransactionResultFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'transactionResultProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionResultHash();

  @override
  String toString() {
    return r'transactionResultProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AppTransaction> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AppTransaction> create(Ref ref) {
    final argument = this.argument as String;
    return transactionResult(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionResultProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionResultHash() => r'dd3fc3b1da0a915a5d4a6bdef60e00f4d742dac2';

/// Fetches the [AppTransaction] for the given [transactionId].
///
/// This provider is only called after [CheckoutScreen] confirms that the
/// backend returned `verified == true`.  Do NOT navigate to this screen
/// from any other path.

final class TransactionResultFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AppTransaction>, String> {
  TransactionResultFamily._()
    : super(
        retry: null,
        name: r'transactionResultProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches the [AppTransaction] for the given [transactionId].
  ///
  /// This provider is only called after [CheckoutScreen] confirms that the
  /// backend returned `verified == true`.  Do NOT navigate to this screen
  /// from any other path.

  TransactionResultProvider call(String transactionId) =>
      TransactionResultProvider._(argument: transactionId, from: this);

  @override
  String toString() => r'transactionResultProvider';
}
