import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

class WindowsPaymentServer {
  static HttpServer? _server;

  /// Inicia un servidor HTTP local en un puerto disponible aleatorio.
  /// Devuelve el puerto en el que está escuchando.
  static Future<int> start() async {
    stop(); // Detener cualquier servidor previo por seguridad
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    debugPrint('🚀 WindowsPaymentServer iniciado en puerto: ${_server!.port}');
    return _server!.port;
  }

  /// Espera a que el navegador redirija a este servidor local.
  /// Devuelve la ruta y query string (ej: /success?session_id=...).
  static Future<String?> waitForRedirect() async {
    if (_server == null) return null;

    final completer = Completer<String?>();

    _server!.listen((HttpRequest request) async {
      final uri = request.uri;
      debugPrint('🌐 WindowsPaymentServer recibió petición: $uri');

      // Respondemos al navegador con una página de éxito estilizada que se cierra sola
      request.response.headers.contentType = ContentType.html;
      request.response.write('''
        <!DOCTYPE html>
        <html lang="es">
        <head>
          <meta charset="UTF-8">
          <title>FashionStore - Pago Procesado</title>
          <style>
             body { 
               font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; 
               display: flex; flex-direction: column; align-items: center; justify-content: center; 
               height: 100vh; background-color: #f3f4f6; margin: 0; 
             }
             .card { 
               background: white; padding: 2.5rem; border-radius: 1rem; 
               box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05); 
               text-align: center; max-width: 400px;
             }
             .icon {
               display: flex; align-items: center; justify-content: center;
               width: 64px; height: 64px; border-radius: 50%; 
               background-color: #d1fae5; margin: 0 auto 1.5rem auto;
             }
             .icon svg { width: 32px; height: 32px; color: #10b981; }
             h1 { color: #111827; margin-top: 0; font-size: 1.5rem; }
             p { color: #6b7280; font-size: 1rem; line-height: 1.5; }
             .loader {
                border: 3px solid #f3f3f3; border-top: 3px solid #10b981;
                border-radius: 50%; width: 24px; height: 24px; animation: spin 1s linear infinite;
                margin: 1.5rem auto 0 auto;
             }
             @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
          </style>
        </head>
        <body>
          <div class="card">
             <div class="icon">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                   <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
             </div>
             <h1>¡Redirección completada!</h1>
             <p>Hemos procesado tu solicitud de Stripe. Ya puedes cerrar esta ventana de forma segura y volver a la app de FashionStore.</p>
             <div class="loader"></div>
             <p style="font-size: 0.875rem; margin-top: 1rem; color: #9ca3af;">Esta ventana se cerrará automáticamente...</p>
             <script>
                setTimeout(() => window.close(), 3500);
             </script>
          </div>
        </body>
        </html>
      ''');
      await request.response.close();

      if (!completer.isCompleted) {
        completer.complete(uri.toString());
      }
      stop();
    });

    return completer.future;
  }

  static void stop() {
    _server?.close(force: true);
    _server = null;
    debugPrint('🛑 WindowsPaymentServer detenido.');
  }
}
