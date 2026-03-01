import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/pedido_model.dart';
import '../models/devolucion_model.dart';

class InvoiceService {
  /// Genera un PDF de la factura para el pedido proporcionado
  Future<File> generateInvoicePdf(PedidoModel pedido) async {
    final pdf = pw.Document();

    // Cargar fuente para soporte de símbolos (opcional, pero recomendado)
    // final font = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
    // final ttf = pw.Font.ttf(font);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(pedido),
          pw.SizedBox(height: 20),
          _buildCustomerInfo(pedido),
          pw.SizedBox(height: 20),
          _buildInvoiceTable(pedido),
          pw.SizedBox(height: 20),
          _buildTotals(pedido),
          pw.SizedBox(height: 40),
          pw.Center(
            child: pw.Text(
              'Gracias por su compra en FashionStore',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/Factura_${pedido.numeroOrden}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildHeader(PedidoModel pedido) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'FashionStore',
              style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green900),
            ),
            pw.Text('E-commerce de electrónica reacondicionada'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('FACTURA',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text('Nº Pedido: ${pedido.numeroOrden}'),
            pw.Text(
                'Fecha: ${pedido.fechaCreacion?.day}/${pedido.fechaCreacion?.month}/${pedido.fechaCreacion?.year}'),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCustomerInfo(PedidoModel pedido) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('DATOS DEL CLIENTE',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Nombre: ${pedido.nombreCliente ?? 'N/A'}'),
          pw.Text('Email: ${pedido.emailCliente ?? 'N/A'}'),
          pw.Text('Teléfono: ${pedido.telefonoCliente ?? 'N/A'}'),
          if (pedido.direccionEnvio != null)
            pw.Text(
                'Dirección: ${pedido.direccionEnvio!['direccion']}, ${pedido.direccionEnvio!['ciudad']} (${pedido.direccionEnvio!['cp']})'),
        ],
      ),
    );
  }

  pw.Widget _buildInvoiceTable(PedidoModel pedido) {
    final headers = ['Producto', 'Cantidad', 'Precio Unit.', 'Subtotal'];

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: pedido.items
          .map((item) => [
                item.nombreProducto ?? 'Producto',
                '${item.cantidad}',
                '${item.precioUnitarioEnEuros.toStringAsFixed(2)} EUR',
                '${item.subtotalEnEuros.toStringAsFixed(2)} EUR',
              ])
          .toList(),
      headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildTotals(PedidoModel pedido) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
                'Subtotal: ${pedido.subtotalEnEuros.toStringAsFixed(2)} EUR'),
            if (pedido.descuento > 0)
              pw.Text(
                  'Descuento: -${pedido.descuentoEnEuros.toStringAsFixed(2)} EUR',
                  style: const pw.TextStyle(color: PdfColors.red)),
            pw.Text('Envío: ${pedido.envioEnEuros.toStringAsFixed(2)} EUR'),
            pw.Divider(),
            pw.Text(
              'TOTAL: ${pedido.totalEnEuros.toStringAsFixed(2)} EUR',
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green900),
            ),
          ],
        ),
      ],
    );
  }

  /// Envía la factura por email al cliente
  Future<bool> sendInvoiceEmail(PedidoModel pedido, File pdfFile) async {
    final smtpServer = _getSmtpServer();
    if (smtpServer == null) {
      print('SMTP Server not configured');
      return false;
    }

    if (pedido.emailCliente == null || pedido.emailCliente!.isEmpty) {
      print('Cliente email null or empty');
      return false;
    }

    final message = Message()
      ..from = Address(dotenv.get('SMTP_USER'), 'FashionStore')
      ..recipients.add(pedido.emailCliente!)
      ..subject = 'Tu factura de FashionStore - Pedido #${pedido.numeroOrden}'
      ..html = '''
        <div style="font-family: Arial, sans-serif; background-color: #f3f4f6; padding: 40px 20px; color: #333;">
          <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
            <div style="background-color: #10b981; padding: 30px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 28px; letter-spacing: 1px;">FashionStore</h1>
            </div>
            <div style="padding: 40px 30px;">
              <h2 style="color: #111827; font-size: 22px; margin-top: 0;">¡Hola ${pedido.nombreCliente}! 👋</h2>
              <p style="font-size: 16px; line-height: 1.6; color: #4b5563;">
                Queremos agradecerte enormemente por tu compra en <strong>FashionStore</strong>. Nos hace mucha ilusión que hayas confiado en nosotros.
              </p>
              <div style="background-color: #f9fafb; border-left: 4px solid #10b981; padding: 15px 20px; margin: 25px 0;">
                <p style="margin: 0; font-size: 16px; color: #374151;">
                  <strong>Nº de Pedido:</strong> #${pedido.numeroOrden}<br>
                  <strong>Total:</strong> ${pedido.totalEnEuros.toStringAsFixed(2)} EUR
                </p>
              </div>
              <p style="font-size: 16px; line-height: 1.6; color: #4b5563;">
                Hemos adjuntado la factura oficial de tu pedido a este correo en formato PDF. Allí podrás encontrar todos los detalles de los productos que has adquirido.
              </p>
              <p style="font-size: 16px; line-height: 1.6; color: #4b5563; margin-bottom: 0;">
                Si tienes cualquier duda, no dudes en responder a este correo. ¡Estamos aquí para ayudarte!
              </p>
            </div>
            <div style="background-color: #f9fafb; padding: 20px; text-align: center; border-top: 1px solid #e5e7eb;">
              <p style="margin: 0; font-size: 14px; color: #6b7280;">
                Con ♥ desde el equipo de <strong>FashionStore</strong>
              </p>
            </div>
          </div>
        </div>
      '''
      ..attachments.add(FileAttachment(pdfFile));

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    }
  }

  SmtpServer? _getSmtpServer() {
    final user = dotenv.maybeGet('SMTP_USER');
    final pass = dotenv.maybeGet('SMTP_PASS');

    if (user == null || pass == null || user.isEmpty || pass.isEmpty) {
      print('SMTP_USER o SMTP_PASS no encontrados en .env');
      return null;
    }

    return gmail(user, pass);
  }

  /// Genera un PDF de la factura rectificativa para un reembolso
  Future<File> generateRefundPdf(
      PedidoModel pedido, DevolucionModel devolucion) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildRefundHeader(pedido, devolucion),
          pw.SizedBox(height: 20),
          _buildCustomerInfo(pedido),
          pw.SizedBox(height: 20),
          _buildRefundTable(pedido, devolucion),
          pw.SizedBox(height: 20),
          _buildRefundTotals(pedido, devolucion),
          pw.SizedBox(height: 40),
          pw.Center(
            child: pw.Text(
              'Lamentamos que tu experiencia no haya sido la deseada',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file =
        File("${output.path}/Factura_${pedido.numeroOrden}_Reembolso.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildRefundHeader(PedidoModel pedido, DevolucionModel devolucion) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'FashionStore',
              style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red900),
            ),
            pw.Text('E-commerce de electrónica reacondicionada'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('FACTURA RECTIFICATIVA',
                style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red800)),
            pw.Text('Nº Devolución: ${devolucion.numeroDevolucion}'),
            pw.Text('Pedido Ref: ${pedido.numeroOrden}'),
            pw.Text(
                'Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildRefundTable(PedidoModel pedido, DevolucionModel devolucion) {
    final headers = ['Producto', 'Cantidad', 'Precio Unit.', 'Subtotal'];

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: pedido.items
          .map((item) => [
                item.nombreProducto ?? 'Producto',
                '${item.cantidad}',
                '-${item.precioUnitarioEnEuros.toStringAsFixed(2)} EUR',
                '-${item.subtotalEnEuros.toStringAsFixed(2)} EUR',
              ])
          .toList(),
      headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.red800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildRefundTotals(PedidoModel pedido, DevolucionModel devolucion) {
    final refAmount = devolucion.importeReembolso != null
        ? (devolucion.importeReembolso! / 100.0)
        : pedido.totalEnEuros;

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'TOTAL REEMBOLSADO: ${refAmount.toStringAsFixed(2)} EUR',
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red900),
            ),
          ],
        ),
      ],
    );
  }

  /// Envía la factura rectificativa por email al cliente
  Future<bool> sendRefundEmail(
      PedidoModel pedido, DevolucionModel devolucion, File pdfFile) async {
    final smtpServer = _getSmtpServer();
    if (smtpServer == null) {
      print('SMTP Server not configured');
      return false;
    }

    if (pedido.emailCliente == null || pedido.emailCliente!.isEmpty) {
      print('Cliente email null or empty');
      return false;
    }

    final refAmount = devolucion.importeReembolso != null
        ? (devolucion.importeReembolso! / 100.0)
        : pedido.totalEnEuros;

    final message = Message()
      ..from = Address(dotenv.get('SMTP_USER'), 'FashionStore')
      ..recipients.add(pedido.emailCliente!)
      ..subject = 'Reembolso procesado - Pedido #${pedido.numeroOrden}'
      ..html = '''
        <div style="font-family: Arial, sans-serif; background-color: #f3f4f6; padding: 40px 20px; color: #333;">
          <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
            <div style="background-color: #ef4444; padding: 30px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 28px; letter-spacing: 1px;">FashionStore</h1>
            </div>
            <div style="padding: 40px 30px;">
              <h2 style="color: #111827; font-size: 22px; margin-top: 0;">¡Hola ${pedido.nombreCliente}! 👋</h2>
              <p style="font-size: 16px; line-height: 1.6; color: #4b5563;">
                Te informamos que hemos procesado correctamente el reembolso de tu devolución.
              </p>
              <div style="background-color: #fce8e8; border-left: 4px solid #ef4444; padding: 15px 20px; margin: 25px 0;">
                <p style="margin: 0; font-size: 16px; color: #374151;">
                  <strong>Ref. Pedido:</strong> #${pedido.numeroOrden}<br>
                  <strong>Nº Devolución:</strong> #${devolucion.numeroDevolucion}<br>
                  <strong>Total Reembolsado:</strong> ${refAmount.toStringAsFixed(2)} EUR
                </p>
              </div>
              <p style="font-size: 16px; line-height: 1.6; color: #4b5563;">
                Hemos adjuntado la factura rectificativa a este correo. El abono se reflejará en tu cuenta en un plazo de 3 a 5 días laborables dependiendo de tu banco.
              </p>
              <p style="font-size: 16px; line-height: 1.6; color: #4b5563; margin-bottom: 0;">
                Esperamos volver a verte pronto. ¡Estamos aquí para ayudarte!
              </p>
            </div>
            <div style="background-color: #f9fafb; padding: 20px; text-align: center; border-top: 1px solid #e5e7eb;">
              <p style="margin: 0; font-size: 14px; color: #6b7280;">
                Con ♥ desde el equipo de <strong>FashionStore</strong>
              </p>
            </div>
          </div>
        </div>
      '''
      ..attachments.add(FileAttachment(pdfFile));

    try {
      final sendReport = await send(message, smtpServer);
      print('Refund Message sent: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('Refund Message not sent. \n' + e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    }
  }

  /// Envía un correo con las instrucciones para la devolución
  Future<bool> sendReturnRequestEmail(
      PedidoModel pedido, DevolucionModel devolucion) async {
    final smtpServer = _getSmtpServer();
    if (smtpServer == null) return false;

    if (pedido.emailCliente == null || pedido.emailCliente!.isEmpty) {
      return false;
    }

    final message = Message()
      ..from = Address(dotenv.get('SMTP_USER'), 'FashionStore')
      ..recipients.add(pedido.emailCliente!)
      ..subject =
          'Instrucciones para tu devolución - Devolución #${devolucion.numeroDevolucion}'
      ..html = '''
        <div style="font-family: Arial, sans-serif; background-color: #f3f4f6; padding: 40px 20px; color: #333;">
          <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
            <div style="background-color: #3b82f6; padding: 30px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 28px; letter-spacing: 1px;">FashionStore</h1>
            </div>
            <div style="padding: 40px 30px;">
              <h2 style="color: #111827; font-size: 22px; margin-top: 0;">¡Hola ${pedido.nombreCliente}! 👋</h2>
              <p style="font-size: 16px; line-height: 1.6; color: #4b5563;">
                Hemos recibido tu solicitud de devolución para el pedido <strong>#${pedido.numeroOrden}</strong>.
              </p>
              
              <div style="background-color: #f3f8ff; border-left: 4px solid #3b82f6; padding: 15px 20px; margin: 25px 0;">
                <p style="margin: 0; font-size: 16px; color: #374151;">
                  <strong>Referencia de Devolución:</strong> #${devolucion.numeroDevolucion}
                </p>
              </div>

              <h3 style="color: #111827; font-size: 18px;">Instrucciones de entrega:</h3>
              <ol style="font-size: 16px; line-height: 1.8; color: #4b5563; padding-left: 20px;">
                <li><strong>Prepara el paquete:</strong> Introduce los artículos en su embalaje original o uno similar que garantice su protección.</li>
                <li><strong>Incluye el albarán:</strong> Imprime este correo o anota el número de devolución en un papel dentro del paquete.</li>
                <li><strong>Nuestra dirección:</strong> Envía el paquete a la siguiente dirección:
                  <div style="background-color: #f9fafb; padding: 10px; margin: 10px 0; border: 1px solid #e5e7eb; border-radius: 4px;">
                    FashionStore Returns Dept.<br>
                    Calle de la Moda, 123<br>
                    28001 Madrid, España
                  </div>
                </li>
                <li><strong>Conserva el resguardo:</strong> Te recomendamos utilizar un método de envío con seguimiento.</li>
              </ol>

              <p style="font-size: 16px; line-height: 1.6; color: #4b5563; margin-top: 30px;">
                Una vez recibamos y verifiquemos el estado de los artículos, procederemos con el reembolso en un plazo máximo de 14 días.
              </p>
              
              <p style="font-size: 16px; line-height: 1.6; color: #4b5563; margin-bottom: 0;">
                Si tienes alguna duda, responde a este correo.
              </p>
            </div>
            <div style="background-color: #f9fafb; padding: 20px; text-align: center; border-top: 1px solid #e5e7eb;">
              <p style="margin: 0; font-size: 14px; color: #6b7280;">
                Atentamente, el equipo de <strong>FashionStore</strong>
              </p>
            </div>
          </div>
        </div>
      ''';

    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      print('Return Request Email error: $e');
      return false;
    }
  }

  /// Envía un correo notificando al cliente que el estado de su pedido ha cambiado
  Future<bool> sendOrderStatusUpdateEmail(
      PedidoModel pedido, String newStatus) async {
    final smtpServer = _getSmtpServer();
    if (smtpServer == null) return false;

    if (pedido.emailCliente == null || pedido.emailCliente!.isEmpty) {
      return false;
    }

    // Determinar colores según el estado (basado en la UI de administración)
    String headerColor = '#10b981'; // Default Green (Entregado)
    String textColor = '#064e3b';
    String bgColor = '#f0fdf4';
    String accentColor = '#10b981';

    if (newStatus == 'Pendiente') {
      headerColor = '#f59e0b'; // Amber
      textColor = '#78350f';
      bgColor = '#fffbeb';
      accentColor = '#f59e0b';
    } else if (newStatus == 'Confirmado') {
      headerColor = '#0ea5e9'; // Sky Blue
      textColor = '#0c4a6e';
      bgColor = '#f0f9ff';
      accentColor = '#0ea5e9';
    } else if (newStatus == 'Enviado') {
      headerColor = '#6366f1'; // Indigo
      textColor = '#312e81';
      bgColor = '#eef2ff';
      accentColor = '#6366f1';
    } else if (newStatus == 'Entregado') {
      headerColor = '#10b981'; // Green
      textColor = '#064e3b';
      bgColor = '#f0fdf4';
      accentColor = '#10b981';
    } else if (newStatus == 'Cancelado') {
      headerColor = '#ef4444'; // Red
      textColor = '#7f1d1d';
      bgColor = '#fef2f2';
      accentColor = '#ef4444';
    }

    final isDelivered = newStatus == 'Entregado';
    final isCancelled = newStatus == 'Cancelado';

    String subjectPrefix = 'Actualización de tu pedido #${pedido.numeroOrden}';
    if (isDelivered) subjectPrefix = '¡Pedido entregado con éxito! 🥳';
    if (isCancelled)
      subjectPrefix = 'Tu pedido #${pedido.numeroOrden} ha sido cancelado';

    final message = Message()
      ..from = Address(dotenv.get('SMTP_USER'), 'FashionStore')
      ..recipients.add(pedido.emailCliente!)
      ..subject = '$subjectPrefix - $newStatus'
      ..html = isDelivered
          ? '''
        <div style="font-family: Arial, sans-serif; background-color: #f3f4f6; padding: 40px 20px; color: #333; text-align: center;">
          <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 10px 25px rgba(0,0,0,0.1);">
            <div style="background-color: #10b981; padding: 40px 30px; text-align: center;">
              <div style="background-color: rgba(255,255,255,0.2); width: 80px; height: 80px; border-radius: 50%; margin: 0 auto 20px; line-height: 80px; text-align: center;">
                <span style="font-size: 40px; vertical-align: middle;">🎁</span>
              </div>
              <h1 style="color: #ffffff; margin: 0; font-size: 32px; font-weight: 800;">¡Entregado!</h1>
              <p style="color: #d1fae5; margin: 10px 0 0; font-size: 18px;">Tu pedido de FashionStore ya ha llegado.</p>
            </div>
            <div style="padding: 40px 30px; text-align: center;">
              <h2 style="color: #111827; font-size: 24px; margin-top: 0;">¡Hola ${pedido.nombreCliente}! 👋</h2>
              <p style="font-size: 16px; line-height: 1.6; color: #4b5563;">
                Estamos encantados de confirmarte que tu pedido <strong>#${pedido.numeroOrden}</strong> ha sido entregado correctamente. ¡Esperamos que disfrutes mucho de tu nueva adquisición!
              </p>
              
              <div style="background-color: #f0fdf4; border: 2px dashed #10b981; border-radius: 12px; padding: 25px; margin: 30px 0;">
                <p style="margin: 0; font-size: 16px; color: #064e3b; line-height: 1.5;">
                  <strong>"La tecnología es mejor cuando une a las personas."</strong><br>
                  Gracias por confiar en nosotros para tus compras de electrónica.
                </p>
              </div>

              <p style="font-size: 16px; line-height: 1.6; color: #4b5563;">
                ¡Gracias por confiar en nosotros para tus compras de electrónica! Esperamos volver a verte pronto.
              </p>
              
              <p style="font-size: 14px; line-height: 1.6; color: #9ca3af; margin-top: 40px; margin-bottom: 0;">
                Si por alguna razón no has recibido el paquete o hay algún problema, por favor contacta con nosotros de inmediato respondiendo a este correo.
              </p>
            </div>
            <div style="background-color: #f9fafb; padding: 30px; text-align: center; border-top: 1px solid #e5e7eb;">
              <p style="margin: 0; font-size: 14px; color: #6b7280; font-weight: bold;">
                FashionStore - Tecnología Reacondicionada con Estilo
              </p>
              <p style="margin: 5px 0 0; font-size: 12px; color: #9ca3af;">
                © 2026 FashionStore. Todos los derechos reservados.
              </p>
            </div>
          </div>
        </div>
        '''
          : isCancelled
              ? '''
          <div style="font-family: Arial, sans-serif; background-color: #f3f4f6; padding: 40px 20px; color: #333; text-align: center;">
            <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 10px 25px rgba(0,0,0,0.1);">
              <div style="background-color: #ef4444; padding: 40px 30px; text-align: center;">
                <div style="background-color: rgba(255,255,255,0.2); width: 80px; height: 80px; border-radius: 50%; margin: 0 auto 20px; line-height: 80px; text-align: center;">
                  <span style="font-size: 40px; vertical-align: middle;">⚠️</span>
                </div>
                <h1 style="color: #ffffff; margin: 0; font-size: 30px; font-weight: 800;">Pedido Cancelado</h1>
                <p style="color: #fee2e2; margin: 10px 0 0; font-size: 16px;">Referencia del pedido: #${pedido.numeroOrden}</p>
              </div>
              <div style="padding: 40px 30px; text-align: center;">
                <h2 style="color: #111827; font-size: 22px; margin-top: 0;">Lo sentimos, ${pedido.nombreCliente}</h2>
                <p style="font-size: 16px; line-height: 1.6; color: #4b5563;">
                  Te informamos que tu pedido ha sido <strong>Cancelado</strong>. Entendemos que esto pueda ser un inconveniente y lamentamos las molestias.
                </p>
                
                <div style="background-color: #fef2f2; border: 1px solid #fecaca; border-radius: 12px; padding: 20px; margin: 25px 0; text-align: left;">
                  <p style="margin: 0; font-size: 14px; color: #7f1d1d; line-height: 1.5;">
                    <strong>¿Qué sucede ahora?</strong><br>
                    • Si ya has realizado el pago, el reembolso se procesará automáticamente en un plazo de 24-48 horas.<br>
                    • Recibirás el importe en el mismo método de pago que utilizaste.<br>
                    • Los artículos vuelven a estar disponibles en nuestro inventario.
                  </p>
                </div>

                <p style="font-size: 16px; line-height: 1.6; color: #4b5563;">
                  Si tienes alguna pregunta sobre el motivo de la cancelación o si crees que ha sido un error, nuestro equipo de atención al cliente está a tu disposición.
                </p>
                
                <p style="font-size: 14px; line-height: 1.6; color: #9ca3af; margin-top: 30px; margin-bottom: 0;">
                  Basta con que respondas directamente a este correo electrónico para hablar con nosotros.
                </p>
              </div>
              <div style="background-color: #f9fafb; padding: 30px; text-align: center; border-top: 1px solid #e5e7eb;">
                <p style="margin: 0; font-size: 14px; color: #6b7280; font-weight: bold;">
                  FashionStore - Atención al Cliente
                </p>
              </div>
            </div>
          </div>
          '''
              : '''
          <div style="font-family: Arial, sans-serif; background-color: #f3f4f6; padding: 40px 20px; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.08);">
              <div style="background-color: $headerColor; padding: 30px; text-align: center;">
                <h1 style="color: #ffffff; margin: 0; font-size: 28px; letter-spacing: 1px;">FashionStore</h1>
              </div>
              <div style="padding: 40px 30px;">
                <h2 style="color: #111827; font-size: 22px; margin-top: 0;">¡Hola ${pedido.nombreCliente}! 👋</h2>
                <p style="font-size: 16px; line-height: 1.6; color: #4b5563;">
                  Te informamos que hay novedades importantes sobre tu pedido <strong>#${pedido.numeroOrden}</strong>.
                </p>
                
                <div style="background-color: $bgColor; border-radius: 8px; border-left: 6px solid $accentColor; padding: 20px; margin: 30px 0; text-align: center;">
                  <p style="margin: 0; font-size: 14px; text-transform: uppercase; letter-spacing: 1px; color: #6b7280; font-weight: bold;">
                    Nuevo Estado Actualizado
                  </p>
                  <p style="margin: 10px 0 0 0; font-size: 24px; color: $textColor; font-weight: bold;">
                    $newStatus
                  </p>
                </div>

                <p style="font-size: 16px; line-height: 1.6; color: #4b5563;">
                  Estamos trabajando para que recibas tus productos lo antes posible. Puedes hacer un seguimiento detallado desde tu perfil de usuario.
                </p>
                
                
                <p style="font-size: 14px; line-height: 1.6; color: #9ca3af; margin-top: 40px; margin-bottom: 0; text-align: center;">
                  ¿Alguna duda? Responde a este correo y nuestro equipo de soporte te ayudará encantado.
                </p>
              </div>
              <div style="background-color: #f9fafb; padding: 25px; text-align: center; border-top: 1px solid #e5e7eb;">
                <p style="margin: 0; font-size: 14px; color: #6b7280;">
                  Atentamente, el equipo de <strong>FashionStore</strong>
                </p>
              </div>
            </div>
          </div>
        ''';

    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      print('Order Status Update Email error: $e');
      return false;
    }
  }

  /// Envía un correo notificando al cliente que el estado de su devolución ha cambiado
  Future<bool> sendReturnStatusUpdateEmail(
      PedidoModel pedido, DevolucionModel devolucion, String newStatus) async {
    final smtpServer = _getSmtpServer();
    if (smtpServer == null) return false;

    if (pedido.emailCliente == null || pedido.emailCliente!.isEmpty) {
      return false;
    }

    final message = Message()
      ..from = Address(dotenv.get('SMTP_USER'), 'FashionStore')
      ..recipients.add(pedido.emailCliente!)
      ..subject =
          'Actualización de tu devolución #${devolucion.numeroDevolucion} - $newStatus'
      ..html = '''
        <div style="font-family: Arial, sans-serif; background-color: #f3f4f6; padding: 40px 20px; color: #333;">
          <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
            <div style="background-color: #3b82f6; padding: 30px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 28px; letter-spacing: 1px;">FashionStore</h1>
            </div>
            <div style="padding: 40px 30px;">
              <h2 style="color: #111827; font-size: 22px; margin-top: 0;">¡Hola ${pedido.nombreCliente}! 👋</h2>
              <p style="font-size: 16px; line-height: 1.6; color: #4b5563;">
                Te informamos que el estado de tu solicitud de devolución <strong>#${devolucion.numeroDevolucion}</strong> para el pedido #${pedido.numeroOrden} ha cambiado.
              </p>
              
              <div style="background-color: #eff6ff; border-left: 4px solid #3b82f6; padding: 15px 20px; margin: 25px 0; text-align: center;">
                <p style="margin: 0; font-size: 18px; color: #1e3a8a; font-weight: bold;">
                  Nuevo Estado: $newStatus
                </p>
              </div>

              <p style="font-size: 16px; line-height: 1.6; color: #4b5563;">
                Estamos procesando tu solicitud y te mantendremos informado de cualquier novedad adicional.
              </p>
              
              <p style="font-size: 16px; line-height: 1.6; color: #4b5563; margin-top: 30px; margin-bottom: 0;">
                Si tienes alguna pregunta, puedes responder directamente a este correo electrónico.
              </p>
            </div>
            <div style="background-color: #f9fafb; padding: 20px; text-align: center; border-top: 1px solid #e5e7eb;">
              <p style="margin: 0; font-size: 14px; color: #6b7280;">
                Gracias por confiar en <strong>FashionStore</strong>
              </p>
            </div>
          </div>
        </div>
      ''';

    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      print('Return Status Update Email error: $e');
      return false;
    }
  }
}
