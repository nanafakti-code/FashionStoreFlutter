import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_store_flutter/app/data/models/reviewable_item_model.dart';
import 'package:fashion_store_flutter/app/data/services/review_service.dart';
import 'package:fashion_store_flutter/app/providers/auth_provider.dart';

final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});

class ReviewNotifier
    extends StateNotifier<AsyncValue<List<ReviewableItemModel>>> {
  final Ref _ref;
  final ReviewService _reviewService;

  ReviewNotifier(this._ref, this._reviewService)
      : super(const AsyncValue.loading()) {
    loadReviewableItems();
  }

  Future<void> loadReviewableItems() async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authNotifierProvider).user;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final items = await _reviewService.getReviewableItems(user.id);
      state = AsyncValue.data(items);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> submitReview({
    required String productId,
    required String ordenId,
    required int rating,
    required String comment,
  }) async {
    try {
      final user = _ref.read(authNotifierProvider).user;
      if (user == null) return false;

      final success = await _reviewService.submitReview(
        userId: user.id,
        productId: productId,
        ordenId: ordenId,
        rating: rating,
        comment: comment,
      );

      if (success) {
        // Refrescar la lista de items reseñables tras el envío exitoso
        await loadReviewableItems();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final reviewsProvider = StateNotifierProvider<ReviewNotifier,
    AsyncValue<List<ReviewableItemModel>>>((ref) {
  return ReviewNotifier(ref, ref.watch(reviewServiceProvider));
});
