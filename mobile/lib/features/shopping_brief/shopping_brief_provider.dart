import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/errors/app_exception.dart';
import '../../core/networking/repositories_providers.dart';
import '../../shared/models/shopping_session.dart';

part 'shopping_brief_provider.g.dart';

@riverpod
class ShoppingBriefNotifier extends _$ShoppingBriefNotifier {
  @override
  AsyncValue<ShoppingSession?> build() => const AsyncData(null);

  Future<void> submitBrief(String brief) async {
    state = const AsyncLoading();
    try {
      final session =
          await ref.read(shoppingRepositoryProvider).submitBrief(brief);
      state = AsyncData(session);
    } on AppException catch (e, st) {
      state = AsyncError(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
