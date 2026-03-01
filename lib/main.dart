import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async'; // For StreamSubscription
import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Ensure GoRouter type is available
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/data/services/supabase_service.dart';
import 'app/routes/app_router.dart';
import 'config/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    await dotenv.load();
    print('✅ Environment variables loaded');

    await SupabaseService.initialize();
    print('✅ Supabase initialized');

    await Hive.initFlutter();
    await Hive.openBox('cart_box');
    print('✅ Hive initialized');

    runApp(
      const ProviderScope(
        child: FashionStoreApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('❌ Error during initialization: $e');
    print('Stack trace: $stackTrace');
    runApp(ErrorApp(error: e.toString()));
  }
}

class FashionStoreApp extends ConsumerWidget {
  const FashionStoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return DeepLinkHandler(
      router: router,
      child: MaterialApp.router(
        title: 'FashionStore',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],
      ),
    );
  }
}

class DeepLinkHandler extends StatefulWidget {
  final Widget child;
  final GoRouter router;

  const DeepLinkHandler({super.key, required this.child, required this.router});

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      // Ignore
    }

    // Listen for new links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    print('🔗 Deep link received: $uri');

    // Normalize path.
    // Stripe might return: fashionstore://success/checkout/success?session_id=...
    // uri.path might be /checkout/success

    String targetPath = uri.path;
    if (uri.queryParameters.isNotEmpty) {
      targetPath += '?${uri.query.isNotEmpty ? uri.query : ''}';
      // Reconstruct query manually if needed or just use default uri string handling
      // GoRouter expects path + query
    }

    // If empty path (e.g. fashionstore://success), ignore or go home
    if (targetPath.isEmpty || targetPath == '/') return;

    // Navigate
    widget.router.push(targetPath);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Fallback app shown when initialization fails
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text(
                'Error de Inicialización',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
