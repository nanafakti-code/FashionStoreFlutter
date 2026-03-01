import 'package:supabase_flutter/supabase_flutter.dart';
import 'email_service.dart';
import 'auth_service.dart';
import 'package:uuid/uuid.dart';

/// Servicio de Newsletter
class NewsletterService {
  final _supabase = Supabase.instance.client;

  /// Suscribirse al newsletter
  Future<bool> subscribe(String email, {String? nombre}) async {
    try {
      final emailClean = email.toLowerCase().trim();

      // Verificar si ya existe en newsletter_subscriptions y tiene código
      final existingSub = await _supabase
          .from('newsletter_subscriptions')
          .select('id, codigo_descuento')
          .eq('email', emailClean)
          .maybeSingle();

      if (existingSub != null) {
        // Ya está suscrito
        print('User already subscribed to newsletter.');
        return false;
      }

      // 1. Generar código de descuento único
      final String uuidPart = const Uuid().v4().substring(0, 6).toUpperCase();
      final String discountCode = 'NEWS-$uuidPart';

      // Intentar obtener el ID del usuario si está logueado
      final userId = AuthService().userId;

      // 2. Crear el cupón en la tabla coupons
      await _supabase.from('coupons').insert({
        'code': discountCode,
        'description': 'Cupón del 10% por suscripción a la Newsletter',
        'discount_type': 'PERCENTAGE',
        'value': 10,
        'min_order_value': 0,
        'max_uses_global': 1,
        'max_uses_per_user': 1,
        'expiration_date':
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'is_active': true,
        'assigned_user_id': userId,
      });

      // 3. Registrar la suscripción
      await _supabase.from('newsletter_subscriptions').insert({
        'email': emailClean,
        'nombre': nombre,
        'activo': true,
        'codigo_descuento': discountCode,
        'usado': false,
        // No enviamos created_at porque tiene valor default de DB (now())
      });

      // 4. Enviar email de bienvenida
      await EmailService().sendNewsletterWelcomeEmail(
        toEmail: emailClean,
        discountCode: discountCode,
      );

      return true;
    } catch (e) {
      print('Error subscribing: $e');
      return false;
    }
  }

  /// Desuscribirse
  Future<bool> unsubscribe(String email) async {
    try {
      await _supabase
          .from('newsletter_subscriptions')
          .update({'activo': false}).eq('email', email.toLowerCase().trim());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verificar si está suscrito
  Future<bool> isSubscribed(String email) async {
    try {
      final response = await _supabase
          .from('newsletter_subscriptions')
          .select('activo')
          .eq('email', email.toLowerCase().trim())
          .maybeSingle();
      return response != null && response['activo'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener cantidad de suscriptores activos
  Future<int> getActiveSubscribersCount() async {
    try {
      final response = await _supabase
          .from('newsletter_subscriptions')
          .select('id')
          .eq('activo', true)
          .count(CountOption.exact);
      return response.count;
    } catch (e) {
      return 0;
    }
  }
}
