import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'dart:async';

class StripeWebViewDialog extends StatefulWidget {
  final String url;
  final String successUrl;
  final String cancelUrl;

  const StripeWebViewDialog({
    super.key,
    required this.url,
    required this.successUrl,
    required this.cancelUrl,
  });

  static Future<dynamic> show(
    BuildContext context, {
    required String url,
    required String successUrl,
    required String cancelUrl,
  }) {
    return showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StripeWebViewDialog(
        url: url,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      ),
    );
  }

  @override
  State<StripeWebViewDialog> createState() => _StripeWebViewDialogState();
}

class _StripeWebViewDialogState extends State<StripeWebViewDialog> {
  final _controller = WebviewController();
  bool _isInitialized = false;
  StreamSubscription? _urlSubscription;

  @override
  void initState() {
    super.initState();
    _initWebview();
  }

  Future<void> _initWebview() async {
    try {
      await _controller.initialize();
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.loadUrl(widget.url);

      _urlSubscription = _controller.url.listen((url) {
        debugPrint('🌐 WebView URL: $url');
        // Usamos detectores de éxito/cancelación basándonos en la estructura de la URL
        if (url.contains('checkout/success') || url.contains('session_id=')) {
          if (mounted) Navigator.of(context).pop(url);
        } else if (url.contains('canceled=true') ||
            url.contains('checkout?canceled')) {
          if (mounted) Navigator.of(context).pop('canceled');
        }
      });

      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('❌ Error initializing WebView Windows: $e');
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Error al abrir la ventana de pago. Asegúrate de tener WebView2 instalado.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _urlSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 1000,
        height: 800,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 18, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    'Pago Seguro con Stripe',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Cerrar sin finalizar',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  if (_isInitialized)
                    Webview(_controller)
                  else
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
