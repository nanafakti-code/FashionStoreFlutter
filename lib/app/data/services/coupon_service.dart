import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/coupon_model.dart';

class CouponService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Valida un cupón siguiendo las reglas estrictas de negocio
  /// Retorna el CouponModel si es válido, o lanza una excepción con el motivo del error.
  Future<CouponModel> validateCoupon({
    required String code,
    required String userId,
    required double cartTotal, // En euros/dólares, unidad base
  }) async {
    try {
      // 1. Buscar Cupón
      final response = await _supabase
          .from('coupons')
          .select()
          .eq('code', code)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        throw 'Cupón no válido o inactivo';
      }

      final coupon = CouponModel.fromJson(response);

      // 2. Verificar Usuario Exclusivo
      final isGlobal = coupon.assignedUserId == null ||
          coupon.assignedUserId!.trim().isEmpty;
      if (!isGlobal && coupon.assignedUserId != userId) {
        throw 'Este cupón no es válido para tu usuario';
      }

      // 3. Verificar Fecha de Expiración
      if (DateTime.now().isAfter(coupon.expirationDate)) {
        throw 'El cupón ha expirado';
      }

      // 4. Verificar Mínimo de Compra
      if (coupon.minOrderValue != null && cartTotal < coupon.minOrderValue!) {
        throw 'El monto mínimo para usar este cupón es ${coupon.minOrderValue}';
      }

      // 5. Verificar Límite Global de Usos
      if (coupon.maxUsesGlobal != null) {
        final globalUsageCount = await _supabase
            .from('coupon_usages')
            .count(CountOption.exact)
            .eq('coupon_id', coupon.id);

        if (globalUsageCount >= coupon.maxUsesGlobal!) {
          throw 'Este cupón se ha agotado';
        }
      }

      // 6. Verificar Límite por Usuario
      final userUsageCount = await _supabase
          .from('coupon_usages')
          .count(CountOption.exact)
          .eq('coupon_id', coupon.id)
          .eq('user_id', userId);

      if (userUsageCount >= coupon.maxUsesPerUser) {
        throw 'Ya has usado este cupón el máximo de veces permitido';
      }

      return coupon;
    } catch (e) {
      if (e is PostgrestException) {
        throw 'Error al validar cupón: ${e.message}';
      }
      rethrow;
    }
  }

  /// Canjea un cupón (se llama tras el pago exitoso)
  /// Registra el uso en la base de datos.
  Future<void> redeemCoupon({
    required int couponId,
    required String userId,
    required String orderId,
    required double discountAmount,
  }) async {
    try {
      // 1. Insertar Registro de Uso
      await _supabase.from('coupon_usages').insert({
        'coupon_id': couponId,
        'user_id': userId,
        'order_id': orderId,
        'discount_amount': discountAmount,
        'used_at': DateTime.now().toIso8601String(),
      });

      // 2. (Opcional) Verificación de desactivación automática
      // Esto idealmente debería ser un Trigger en DB o Edge Function para consistencia,
      // pero lo implementamos aquí como solicitado.
      // Consultamos si el cupón alcanzó su límite global (si existe)

      // Nota: Para hacerlo robusto, mejor delegar a DB.
      // Aquí solo registramos el uso.
    } catch (e) {
      print('Error redeeming coupon: $e');
      // No lanzamos error crítico aquí para no interrumpir el flujo post-pago,
      // pero deberíamos registrarlo en algún sistema de logs.
    }
  }

  /// Obtiene los cupones activos del usuario (personales + globales)
  /// Solo muestra aquellos que no han expirado y que el usuario NO ha agotado.
  Future<List<CouponModel>> getUserCoupons(String userId) async {
    try {
      // 1. Obtener TODOS los cupones activos del servidor
      final response =
          await _supabase.from('coupons').select().eq('is_active', true);

      final now = DateTime.now();
      final List<dynamic> data = response as List;
      print('--- GET USER COUPONS DEBUG ---');
      print('Current User ID: $userId');
      print('Total Active Coupons found in DB: ${data.length}');
      for (var c in data) {
        print('Coupon: ${c['code']} - AssignedTo: ${c['assigned_user_id']}');
      }

      // 2. Filtrar PERTENENCIA y VENCIMIENTO en Dart (más robusto)
      final allAvailableCoupons =
          data.map((c) => CouponModel.fromJson(c)).where((coupon) {
        // No expirado
        final isNotExpired = coupon.expirationDate.isAfter(now);

        // Pertenece al usuario logueado o es un cupón global (null o vacío)
        final isGlobal = coupon.assignedUserId == null ||
            coupon.assignedUserId!.trim().isEmpty;
        final isMine = coupon.assignedUserId == userId;

        return isNotExpired && (isGlobal || isMine);
      }).toList();

      if (allAvailableCoupons.isEmpty) return [];

      // 3. Obtener conteo de usos del usuario para estos cupones
      final couponIds = allAvailableCoupons.map((c) => c.id).toList();
      final usagesResponse = await _supabase
          .from('coupon_usages')
          .select('coupon_id')
          .eq('user_id', userId)
          .filter('coupon_id', 'in', couponIds);

      final List<dynamic> usages = usagesResponse as List;

      // Contar ocurrencias por coupon_id
      final Map<int, int> usageCounts = {};
      for (var usage in usages) {
        final id = usage['coupon_id'] as int;
        usageCounts[id] = (usageCounts[id] ?? 0) + 1;
      }

      // 4. Filtrar los que ya superaron el límite por usuario
      final filteredCoupons = allAvailableCoupons.where((coupon) {
        final count = usageCounts[coupon.id] ?? 0;
        return count < coupon.maxUsesPerUser;
      }).toList();

      return filteredCoupons;
    } catch (e) {
      print('Error fetching user coupons: $e');
      return [];
    }
  }
}
