import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_store_flutter/app/data/services/api_service.dart';
import 'package:fashion_store_flutter/app/data/services/auth_service.dart';
import 'package:fashion_store_flutter/app/data/services/cart_service.dart';
import 'package:fashion_store_flutter/app/data/services/product_service.dart';
import 'package:fashion_store_flutter/app/data/services/order_service.dart';
import 'package:fashion_store_flutter/app/data/services/return_service.dart';
import 'package:fashion_store_flutter/app/data/services/review_service.dart';
import 'package:fashion_store_flutter/app/data/services/coupon_service.dart';
import 'package:fashion_store_flutter/app/data/services/wishlist_service.dart';
import 'package:fashion_store_flutter/app/data/services/newsletter_service.dart';
import 'package:fashion_store_flutter/app/data/services/admin_service.dart';
import 'package:fashion_store_flutter/app/data/services/invoice_service.dart';

// ── Service Providers ──────────────────────────────────────────────────────

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final cartServiceProvider = Provider<CartService>((ref) => CartService());

final productServiceProvider =
    Provider<ProductService>((ref) => ProductService());

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

final returnServiceProvider = Provider<ReturnService>((ref) => ReturnService());

final reviewServiceProvider = Provider<ReviewService>((ref) => ReviewService());

final couponServiceProvider = Provider<CouponService>((ref) => CouponService());

final wishlistServiceProvider =
    Provider<WishlistService>((ref) => WishlistService());

final newsletterServiceProvider =
    Provider<NewsletterService>((ref) => NewsletterService());

final adminServiceProvider = Provider<AdminService>((ref) => AdminService());

final invoiceServiceProvider =
    Provider<InvoiceService>((ref) => InvoiceService());
