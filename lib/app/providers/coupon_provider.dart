import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_store_flutter/app/data/models/coupon_model.dart';
import 'package:fashion_store_flutter/app/data/services/coupon_service.dart';
import 'package:fashion_store_flutter/app/providers/auth_provider.dart';

final couponServiceProvider = Provider<CouponService>((ref) {
  return CouponService();
});

class UserCouponsNotifier extends StateNotifier<AsyncValue<List<CouponModel>>> {
  final Ref _ref;
  final CouponService _couponService;

  UserCouponsNotifier(this._ref, this._couponService)
      : super(const AsyncValue.loading()) {
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authNotifierProvider).user;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final coupons = await _couponService.getUserCoupons(user.id);
      state = AsyncValue.data(coupons);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final userCouponsProvider = StateNotifierProvider.autoDispose<
    UserCouponsNotifier, AsyncValue<List<CouponModel>>>((ref) {
  // Observar el estado de autenticación para recargar si el usuario cambia (logout/login)
  ref.watch(authNotifierProvider);
  return UserCouponsNotifier(ref, ref.watch(couponServiceProvider));
});
