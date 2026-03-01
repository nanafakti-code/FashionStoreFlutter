import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:logger/logger.dart';

class EmailService {
  final Logger _logger = Logger();

  /// Instancia de Singleton
  static final EmailService _instance = EmailService._internal();

  factory EmailService() {
    return _instance;
  }

  EmailService._internal();

  /// Configuración del servidor SMTP
  SmtpServer _getSmtpServer() {
    final String username = dotenv.env['SMTP_USER'] ?? '';
    final String password = dotenv.env['SMTP_PASS'] ?? '';

    if (username.isEmpty || password.isEmpty) {
      _logger.w(
          '⚠️ Faltan las credenciales SMTP_USER o SMTP_PASS en el archivo .env');
    }

    return gmail(username, password);
  }

  /// Envía un correo electrónico de bienvenida
  Future<bool> sendWelcomeEmail({
    required String toEmail,
    required String? nombre,
  }) async {
    final String emailUsername = dotenv.env['SMTP_USER'] ?? '';

    if (emailUsername.isEmpty || emailUsername == 'AQUI_TU_CORREO@gmail.com') {
      _logger.w(
          '⚠️ Por favor, configura tu correo real en SMTP_USER en el archivo .env');
      // Devolvemos exitoso aunque no se envíe para no bloquear el flujo
      return true;
    }

    if (kIsWeb) {
      _logger.i(
          '🌐 MODO WEB: El paquete mailer no soporta envíos de email directos en el navegador debido a las restricciones de Socket TCP. Saltando envío real para el correo $toEmail. Para web, se requerirá enviar esto vía backend (ej: Supabase Edge Functions o servicio Cloud).');
      return true;
    }

    final String recipientName =
        nombre?.isNotEmpty == true ? nombre! : 'Usuario';

    // Configurar el mensaje
    final message = Message()
      ..from = Address(emailUsername, 'FashionStore')
      ..recipients.add(toEmail)
      ..subject = '¡Bienvenido a FashionStore, $recipientName! 🎉'
      ..html = '''
        <!DOCTYPE html>
        <html lang="es">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Bienvenido a FashionStore</title>
          <style>
            body { font-family: 'Helvetica Neue', Arial, sans-serif; background-color: #f6f9fc; margin: 0; padding: 0; }
            .container { max-width: 600px; margin: 40px auto; background: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
            .header { background-color: #000000; padding: 30px; text-align: center; }
            .header h1 { color: #ffffff; margin: 0; font-size: 28px; letter-spacing: 1px; }
            .content { padding: 40px; color: #333333; line-height: 1.6; }
            .content h2 { color: #000000; font-size: 22px; margin-top: 0; }
            .btn { display: inline-block; background-color: #000000; color: #ffffff; padding: 12px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; margin-top: 20px; text-align: center; }
            .footer { background-color: #f1f5f9; padding: 20px; text-align: center; font-size: 14px; color: #64748b; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>FASHIONSTORE</h1>
            </div>
            <div class="content">
              <h2>¡Hola, $recipientName! 👋</h2>
              <p>Estamos muy emocionados de darte la bienvenida a FashionStore, el mejor lugar para encontrar ropa de moda con un estilo único.</p>
              <p>Tu cuenta ha sido creada exitosamente. A partir de ahora, podrás disfrutar de una experiencia de compra rápida, guardar tus favoritos y realizar un seguimiento de tus pedidos.</p>
              <div style="text-align: center;">
                <a href="#" class="btn">Explorar el catálogo</a>
              </div>
              <p style="margin-top: 30px;">Si tienes alguna pregunta, no dudes en responder a este correo. ¡Estamos aquí para ayudarte!</p>
              <p>El equipo de FashionStore.</p>
            </div>
            <div class="footer">
              <p>&copy; ${DateTime.now().year} FashionStore. Todos los derechos reservados.</p>
            </div>
          </div>
        </body>
        </html>
      ''';

    try {
      final smtpServer = _getSmtpServer();
      final sendReport = await send(message, smtpServer);
      _logger.i(
          '✅ Correo de bienvenida enviado a: $toEmail. Message: ${sendReport.toString()}');
      return true;
    } on MailerException catch (e) {
      _logger.e('❌ Error enviando correo (MailerException): ${e.message}');
      for (var p in e.problems) {
        _logger.e('Problema: ${p.code}: ${p.msg}');
      }
      return false;
    } catch (e) {
      _logger.e('❌ Error inesperado enviando correo: $e');
      return false;
    }
  }

  /// Envía un correo con un cupón de descuento por suscribirse a la newsletter
  Future<bool> sendNewsletterWelcomeEmail({
    required String toEmail,
    required String discountCode,
  }) async {
    final String emailUsername = dotenv.env['SMTP_USER'] ?? '';

    if (emailUsername.isEmpty || emailUsername == 'AQUI_TU_CORREO@gmail.com') {
      _logger.w(
          '⚠️ Por favor, configura tu correo real en SMTP_USER en el archivo .env');
      return true;
    }

    if (kIsWeb) {
      _logger.i('🌐 MODO WEB: Saltando envío real para el correo $toEmail.');
      return true;
    }

    final message = Message()
      ..from = Address(emailUsername, 'FashionStore')
      ..recipients.add(toEmail)
      ..subject = '¡Bienvenido a la Newsletter de FashionStore! 🎉'
      ..html = '''
        <!DOCTYPE html>
        <html lang="es">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Bienvenido a la Newsletter</title>
          <style>
            body { font-family: 'Helvetica Neue', Arial, sans-serif; background-color: #f6f9fc; margin: 0; padding: 0; }
            .container { max-width: 600px; margin: 40px auto; background: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
            .header { background-color: #000000; padding: 30px; text-align: center; }
            .header h1 { color: #ffffff; margin: 0; font-size: 28px; letter-spacing: 1px; }
            .content { padding: 40px; color: #333333; line-height: 1.6; text-align: center; }
            .content h2 { color: #000000; font-size: 22px; margin-top: 0; }
            .discount-box { background-color: #f1f5f9; border: 2px dashed #00aa45; padding: 20px; border-radius: 8px; margin: 30px 0; display: inline-block; }
            .discount-code { font-size: 28px; font-weight: bold; color: #00aa45; letter-spacing: 2px; }
            .btn { display: inline-block; background-color: #000000; color: #ffffff; padding: 12px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; margin-top: 10px; text-align: center; }
            .footer { background-color: #f1f5f9; padding: 20px; text-align: center; font-size: 14px; color: #64748b; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>FASHIONSTORE</h1>
            </div>
            <div class="content">
              <h2>¡Gracias por suscribirte! 💌</h2>
              <p>Te damos la bienvenida a nuestra comunidad. Serás el primero en enterarte de nuestras últimas colecciones, tendencias y ofertas exclusivas.</p>
              <p>Como agradecimiento, aquí tienes un cupón del <strong>10% de descuento</strong> para tu próxima compra:</p>
              
              <div class="discount-box">
                <div class="discount-code">$discountCode</div>
              </div>
              
              <p>¡No lo dejes escapar! Entra ahora y descubre tus nuevos favoritos.</p>
              
              <div>
                <a href="#" class="btn">Ir a la tienda</a>
              </div>
            </div>
            <div class="footer">
              <p>&copy; ${DateTime.now().year} FashionStore. Todos los derechos reservados.</p>
            </div>
          </div>
        </body>
        </html>
      ''';

    try {
      final smtpServer = _getSmtpServer();
      final sendReport = await send(message, smtpServer);
      _logger.i(
          '✅ Correo Newsletter enviado a: $toEmail. Message: ${sendReport.toString()}');
      return true;
    } on MailerException catch (e) {
      _logger.e('❌ Error enviando correo Newsletter: ${e.message}');
      return false;
    } catch (e) {
      _logger.e('❌ Error inesperado enviando correo Newsletter: $e');
      return false;
    }
  }
}
