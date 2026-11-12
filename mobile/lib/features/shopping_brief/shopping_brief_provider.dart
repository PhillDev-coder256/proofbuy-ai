import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/errors/app_exception.dart';
import '../../core/firestore/firestore_service.dart';
import '../../features/auth/auth_repository.dart';
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

      // Persist shopping session to Firestore
      final user = ref.read(currentUserProvider);
      if (user != null) {
        await FirestoreService().saveShoppingSession(
          sessionId: session.id,
          briefText: brief,
          requirementsJson: session.requirementsJson ?? {},
          status: session.status,
        );
      }

      state = AsyncData(session);
    } on AppException catch (e, st) {
      state = AsyncError(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
