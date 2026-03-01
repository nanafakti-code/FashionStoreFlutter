import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/producto_model.dart';
import '../../data/models/resena_model.dart';
import '../../data/models/extra_models.dart';
import '../../data/models/devolucion_model.dart';
import '../../data/models/coupon_model.dart';

class AdminService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ───── Dashboard Stats ─────
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // 1. Total Pedidos
      final countOrdersRes =
          await _supabase.from('ordenes').select('id').count(CountOption.exact);

      // 2. Ingresos Totales y Desglose de Ventas (Hoy vs Mes)
      final revenueRes =
          await _supabase.from('ordenes').select('total, fecha_creacion');
      int totalRevenue = 0;
      int salesToday = 0;
      int salesThisMonth = 0;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final startOfMonth = DateTime(now.year, now.month, 1);

      for (var row in revenueRes) {
        final total = (row['total'] as num).toInt();
        final date = DateTime.parse(row['fecha_creacion']);

        totalRevenue += total;

        if (date.isAfter(startOfDay)) {
          salesToday += total;
        }
        if (date.isAfter(startOfMonth)) {
          salesThisMonth += total;
        }
      }

      // 3. Usuarios totales
      final countUsersRes = await _supabase
          .from('usuarios')
          .select('id')
          .count(CountOption.exact);

      // 4. Productos totales y Valor de Inventario
      final productsRes = await _supabase.from('productos').select(
          'id, precio_venta, stock_total'); // Ajustar si usas variantes para precio exacto

      int totalProducts = productsRes.length;
      int totalStock = 0;
      int inventoryValue = 0;

      for (var p in productsRes) {
        final stock = (p['stock_total'] as num).toInt();
        final price = (p['precio_venta'] as num).toInt();
        totalStock += stock;
        inventoryValue += (stock * price);
      }

      // 5. Pedidos recientes
      final recentOrdersResponse = await _supabase
          .from('ordenes')
          .select('*, items_orden(*)')
          .order('fecha_creacion', ascending: false)
          .limit(5);

      // 6. Operaciones Pendientes
      final pendingOrdersCount = await _supabase
          .from('ordenes')
          .select('id')
          .inFilter('estado',
              ['Pendiente', 'Procesando']) // Ajustar estados según tu lógica
          .count(CountOption.exact);

      final pendingReturnsCount = await _supabase
          .from('devoluciones') // Asegúrate que la tabla exista
          .select('id')
          .eq('estado', 'Pendiente')
          .count(CountOption.exact);

      return {
        'total_orders': countOrdersRes.count,
        'total_revenue': totalRevenue,
        'sales_today': salesToday,
        'sales_this_month': salesThisMonth,
        'total_users': countUsersRes.count,
        'total_products': totalProducts,
        'total_stock': totalStock,
        'inventory_value': inventoryValue,
        'recent_orders': recentOrdersResponse,
        'pending_orders': pendingOrdersCount.count,
        'pending_returns': pendingReturnsCount.count,
      };
    } catch (e) {
      print('Error fetching dashboard stats via Supabase: $e');
      return {};
    }
  }

  // ───── Productos CRUD ─────
  Future<List<ProductoModel>> getProducts(
      {int limit = 50, int offset = 0, bool? activo}) async {
    try {
      var query = _supabase.from('productos').select(
          '*, categorias(nombre), imagenes_producto(url, es_principal)');

      if (activo != null) {
        query = query.eq('activo', activo);
      }

      final response =
          await query.range(offset, offset + limit - 1).order('nombre');

      return (response as List).map((p) => ProductoModel.fromJson(p)).toList();
    } catch (e) {
      print('Error fetching products via Supabase: $e');
      return [];
    }
  }

  Future<bool> createProduct(Map<String, dynamic> data,
      {List<Map<String, dynamic>>? variants}) async {
    try {
      // Separar imagen_principal del resto de datos
      String? mainImage = data['imagen_principal'];
      // Crear copia modificable de los datos
      final productData = Map<String, dynamic>.from(data);
      productData.remove('imagen_principal');

      // 1. Insertar producto y obtener ID
      final res = await _supabase
          .from('productos')
          .insert(productData)
          .select()
          .single();
      final productId = res['id'];

      // 2. Insertar imagen principal en tabla imagenes_producto
      if (mainImage != null && mainImage.isNotEmpty) {
        await _supabase.from('imagenes_producto').insert({
          'producto_id': productId,
          'url': mainImage,
          'es_principal': true,
          'orden': 1, // Default order
        });
      }

      // 3. Insertar variantes si existen
      if (variants != null && variants.isNotEmpty) {
        final variantsToInsert = variants.map((v) {
          return {
            ...v,
            'producto_id': productId,
            // Asegurar SKU
            'sku_variante': v['sku_variante'] ??
                'VAR-${DateTime.now().millisecondsSinceEpoch}-${v['talla']}',
            // Asegurar nombre_variante para cumplir constraint (Schema legacy?)
            'nombre_variante': v['nombre_variante'] ??
                '${v['talla']} ${v['color'] ?? ''}'.trim(),
            // Asegurar precio_venta/precio_adicional si el schema lo requiere
            'precio_venta': v['precio_venta'] ?? data['precio_venta'] ?? 0,
            'precio_adicional': v['precio_adicional'] ?? 0,
          };
        }).toList();
        await _supabase.from('variantes_producto').insert(variantsToInsert);
      }
      return true;
    } catch (e) {
      print('Error creating product/variants via Supabase: $e');
      return false;
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final productData = Map<String, dynamic>.from(data);
      // Extraer imagen si existe para actualizarla en su tabla
      String? mainImage = productData['imagen_principal'];
      productData.remove('imagen_principal');

      if (productData.isNotEmpty) {
        await _supabase.from('productos').update(productData).eq('id', id);
      }

      // Actualizar imagen principal si se proporciona
      if (mainImage != null && mainImage.isNotEmpty) {
        // Borrar anterior principal (o actualizar si supiéramos el ID)
        await _supabase
            .from('imagenes_producto')
            .update({'es_principal': false}).eq('producto_id', id);

        // Insertar nueva (o hacer upsert)
        await _supabase.from('imagenes_producto').insert({
          'producto_id': id,
          'url': mainImage,
          'es_principal': true,
          'orden': 1
        });
      }

      return true;
    } catch (e) {
      print('Error updating product via Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _supabase.from('productos').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting product via Supabase: $e');
      return false;
    }
  }

  Future<bool> toggleProductActive(String id, bool active) async {
    try {
      await _supabase.from('productos').update({'activo': active}).eq('id', id);
      return true;
    } catch (e) {
      print('Error toggling product active via Supabase: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getProductVariants(
      String productId) async {
    try {
      final response = await _supabase
          .from('variantes_producto')
          .select()
          .eq('producto_id', productId);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching variants via Supabase: $e');
      return [];
    }
  }

  // ───── Categorías ─────
  Future<List<CategoriaModel>> getCategories() async {
    try {
      final response =
          await _supabase.from('categorias').select().order('nombre');
      return (response as List).map((c) => CategoriaModel.fromJson(c)).toList();
    } catch (e) {
      print('Error fetching categories via Supabase: $e');
      return [];
    }
  }

  Future<bool> createCategory(Map<String, dynamic> data) async {
    try {
      await _supabase.from('categorias').insert(data);
      return true;
    } catch (e) {
      print('Error creating category via Supabase: $e');
      return false;
    }
  }

  Future<bool> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('categorias').update(data).eq('id', id);
      return true;
    } catch (e) {
      print('Error updating category via Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _supabase.from('categorias').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting category via Supabase: $e');
      return false;
    }
  }

  // ───── Marcas ─────
  Future<List<MarcaModel>> getBrands() async {
    try {
      final response = await _supabase.from('marcas').select().order('nombre');
      return (response as List).map((m) => MarcaModel.fromJson(m)).toList();
    } catch (e) {
      print('Error fetching brands via Supabase: $e');
      return [];
    }
  }

  Future<bool> createBrand(Map<String, dynamic> data) async {
    try {
      await _supabase.from('marcas').insert(data);
      return true;
    } catch (e) {
      print('Error creating brand via Supabase: $e');
      return false;
    }
  }

  Future<bool> updateBrand(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('marcas').update(data).eq('id', id);
      return true;
    } catch (e) {
      print('Error updating brand via Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteBrand(String id) async {
    try {
      await _supabase.from('marcas').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting brand via Supabase: $e');
      return false;
    }
  }

  // ───── Usuarios ─────
  Future<List<Map<String, dynamic>>> getUsers({int limit = 50}) async {
    try {
      final response = await _supabase.from('usuarios').select().limit(limit);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching users via Supabase: $e');
      return [];
    }
  }

  Future<bool> updateUserRole(String userId, String role) async {
    try {
      await _supabase.from('usuarios').update({'rol': role}).eq('id', userId);
      return true;
    } catch (e) {
      print('Error updating user role via Supabase: $e');
      return false;
    }
  }

  // ───── Reseñas ─────
  // ───── Reseñas ─────
  // ───── Reseñas ─────
  Future<List<ResenaModel>> getReviews({String? estado, int limit = 50}) async {
    try {
      var query = _supabase
          .from(
              'resenas') // Changed from reseñas to resenas based on error hint
          .select('*, usuarios(nombre, email), productos(nombre)');

      if (estado != null) {
        query = query.eq('estado', estado);
      }
      final response =
          await query.limit(limit).order('creada_en', ascending: false);
      return (response as List).map((r) => ResenaModel.fromJson(r)).toList();
    } catch (e) {
      print('Error fetching reviews (resenas): $e');
      return [];
    }
  }

  Future<bool> updateReviewStatus(String reviewId, String nuevoEstado) async {
    try {
      await _supabase
          .from('resenas')
          .update({'estado': nuevoEstado}).eq('id', reviewId);
      return true;
    } catch (e) {
      print('Error updating review status via Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteReview(String id) async {
    try {
      await _supabase.from('resenas').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting review via Supabase: $e');
      return false;
    }
  }

  // ───── Cupones ─────
  Future<List<CouponModel>> getCoupons() async {
    try {
      final response = await _supabase.from('coupons').select().order('code');
      return (response as List).map((c) => CouponModel.fromJson(c)).toList();
    } catch (e) {
      print('Error fetching coupons via Supabase: $e');
      return [];
    }
  }

  Future<bool> createCoupon(Map<String, dynamic> data) async {
    try {
      // Handle empty string as null just in case
      final assignedUserId = data['assigned_user_id']?.toString().trim();
      final finalAssignedId =
          (assignedUserId != null && assignedUserId.isNotEmpty)
              ? assignedUserId
              : null;

      // Data expected to match CouponModel structure or be adaptable
      await _supabase.from('coupons').insert({
        'code': data['code'],
        'description': data['description'],
        'discount_type': data['discount_type'],
        'value': data['value'],
        'min_order_value': data['min_order_value'],
        'max_uses_global': data['max_uses_global'],
        'max_uses_per_user': data['max_uses_per_user'] ?? 1,
        'expiration_date': data['expiration_date'],
        'is_active': data['is_active'] ?? true,
        'assigned_user_id': finalAssignedId,
      });
      return true;
    } catch (e) {
      print('Error creating coupon via Supabase: $e');
      return false;
    }
  }

  Future<bool> updateCoupon(String id, Map<String, dynamic> data) async {
    try {
      final assignedUserId = data['assigned_user_id']?.toString().trim();
      final finalAssignedId =
          (assignedUserId != null && assignedUserId.isNotEmpty)
              ? assignedUserId
              : null;

      await _supabase.from('coupons').update({
        'code': data['code'],
        'description': data['description'],
        'discount_type': data['discount_type'],
        'value': data['value'],
        'min_order_value': data['min_order_value'],
        'max_uses_global': data['max_uses_global'],
        'max_uses_per_user': data['max_uses_per_user'] ?? 1,
        'expiration_date': data['expiration_date'],
        'is_active': data['is_active'] ?? true,
        'assigned_user_id': finalAssignedId,
      }).eq('id', id);
      return true;
    } catch (e) {
      print('Error updating coupon via Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteCoupon(String id) async {
    try {
      await _supabase.from('coupons').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting coupon via Supabase: $e');
      return false;
    }
  }

  // Used by Admin Panel or others if needed
  Future<CouponModel?> getCouponByCode(String code) async {
    try {
      final response = await _supabase
          .from('coupons')
          .select()
          .eq('code', code)
          .maybeSingle();

      if (response != null) {
        return CouponModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting coupon via Supabase: $e');
      return null;
    }
  }

  // ───── Devoluciones ─────
  Future<List<DevolucionModel>> getReturns({String? estado}) async {
    try {
      var query = _supabase
          .from('devoluciones')
          .select('*, ordenes(*, items_orden(*))');
      if (estado != null) {
        query = query.eq('estado', estado);
      }
      final response = await query.order('fecha_solicitud', ascending: false);
      final returns =
          (response as List).map((r) => DevolucionModel.fromJson(r)).toList();

      // También incluir pedidos con estado "Solicitud Pendiente" que no tienen devolución registrada
      if (estado == null || estado == 'Pendiente') {
        try {
          final orderIds = returns.map((r) => r.ordenId).toSet();
          final pendingOrders = await _supabase
              .from('ordenes')
              .select('*')
              .eq('estado', 'Solicitud Pendiente')
              .order('fecha_creacion', ascending: false);

          for (var orderJson in (pendingOrders as List)) {
            final orderId = orderJson['id'] as String;
            // Solo crear entrada sintética si no existe devolución para ese pedido
            if (!orderIds.contains(orderId)) {
              returns.add(DevolucionModel(
                id: 'order-$orderId', // ID sintético para distinguirlo
                ordenId: orderId,
                numeroDevolucion: 'SOL-${orderJson['numero_orden'] ?? orderId}',
                motivo: 'Solicitud de devolución pendiente',
                estado: 'Solicitud Pendiente',
                fechaSolicitud: orderJson['fecha_creacion'] != null
                    ? DateTime.tryParse(orderJson['fecha_creacion'] as String)
                    : null,
                importeReembolso: orderJson['total'] as int?,
              ));
            }
          }
        } catch (e) {
          print('Error fetching pending return orders: $e');
        }
      }

      return returns;
    } catch (e) {
      print('Error fetching returns via Supabase: $e');
      return [];
    }
  }

  Future<bool> updateReturnStatus(String returnId, String estado) async {
    try {
      await _supabase
          .from('devoluciones')
          .update({'estado': estado}).eq('id', returnId);
      return true;
    } catch (e) {
      print('Error updating return status via Supabase: $e');
      return false;
    }
  }

  // ───── Newsletter & Campañas ─────
  Future<List<NewsletterModel>> getNewsletterSubscribers({bool? active}) async {
    try {
      // Changed 'newsletter' to 'newsletter_subscriptions'
      var query = _supabase.from('newsletter_subscriptions').select();
      if (active != null) {
        query = query.eq('activo', active);
      }
      final response = await query.order('created_at', ascending: false);
      return (response as List)
          .map((n) => NewsletterModel.fromJson(n))
          .toList();
    } catch (e) {
      print('Error fetching newsletter subscribers via Supabase: $e');
      return [];
    }
  }

  Future<List<CampanaModel>> getCampaigns() async {
    try {
      // Changed 'campañas' to 'campanas_email'
      final response = await _supabase
          .from('campanas_email')
          .select()
          .order('fecha_envio', ascending: false);
      return (response as List).map((c) => CampanaModel.fromJson(c)).toList();
    } catch (e) {
      print('Error fetching campaigns via Supabase: $e');
      return [];
    }
  }

  Future<bool> createCampaign(Map<String, dynamic> data) async {
    try {
      await _supabase.from('campanas_email').insert(data);
      return true;
    } catch (e) {
      print('Error creating campaign via Supabase: $e');
      return false;
    }
  }

  Future<bool> updateCampaign(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('campanas_email').update(data).eq('id', id);
      return true;
    } catch (e) {
      print('Error updating campaign via Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteCampaign(String id) async {
    try {
      await _supabase.from('campanas_email').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting campaign via Supabase: $e');
      return false;
    }
  }

  Future<bool> sendCampaign(String id) async {
    try {
      // TODO: Integrar con Resend API
      // Por ahora simulamos el envío actualizando el estado
      await _supabase.from('campanas_email').update({
        'estado': 'Enviada',
        'fecha_envio': DateTime.now().toIso8601String(),
        'total_enviados': 100, // Simulación
      }).eq('id', id);
      return true;
    } catch (e) {
      print('Error sending campaign via Supabase: $e');
      return false;
    }
  }

  Future<bool> duplicateCampaign(String originalId) async {
    try {
      // 1. Obtener la campaña original
      final original = await _supabase
          .from('campanas_email')
          .select()
          .eq('id', originalId)
          .single();

      // 2. Crear copia limpia
      final copy = {
        'nombre': 'Copia de ${original['nombre']}',
        'asunto': original['asunto'],
        'descripcion': original['descripcion'],
        'contenido_html': original['contenido_html'],
        'estado': 'Borrador',
        'tipo_segmento': original['tipo_segmento'],
        'creada_en': DateTime.now().toIso8601String(),
        // Reset métricas
        'total_destinatarios': 0,
        'total_enviados': 0,
        'total_abiertos': 0,
        'total_clicks': 0,
        'fecha_envio': null,
        'fecha_programada': null,
      };

      // 3. Insertar
      await _supabase.from('campanas_email').insert(copy);
      return true;
    } catch (e) {
      print('Error duplicating campaign via Supabase: $e');
      return false;
    }
  }

  // ───── Storage (imágenes) ─────
  Future<String?> uploadProductImage(String fileName, List<int> bytes) async {
    try {
      final path = 'products/$fileName';
      // En algunas versiones de supabase_flutter es upload, en otras uploadBinary
      // Si upload pide un File, usamos uploadBinary para List<int>
      await _supabase.storage
          .from(
              'product-images') // Updated to product-images (singular) per storage-setup.md
          .uploadBinary(path, Uint8List.fromList(bytes));
      return _supabase.storage.from('product-images').getPublicUrl(path);
    } catch (e) {
      print('Error uploading image via Supabase: $e');
      return null;
    }
  }

  // ───── Ofertas ─────
  Future<List<Map<String, dynamic>>> getProductsForOffers() async {
    try {
      final response = await _supabase
          .from('productos')
          .select(
              'id, nombre, precio_venta, precio_original, activo, variantes_producto(imagen_url), imagenes_producto(url)')
          .eq('activo', true)
          .order('nombre');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching products for offers: $e');
      return [];
    }
  }

  /// Sets an offer: saves current precio_venta as precio_original,
  /// then updates precio_venta to the new discounted price.
  Future<bool> setProductOffer(
      String productId, int nuevoPrecioVenta, int precioOriginal) async {
    try {
      await _supabase.from('productos').update({
        'precio_original': precioOriginal,
        'precio_venta': nuevoPrecioVenta,
      }).eq('id', productId);
      return true;
    } catch (e) {
      print('Error setting product offer: $e');
      return false;
    }
  }

  /// Removes an offer: restores precio_venta from precio_original, clears precio_original.
  Future<bool> removeProductOffer(String productId, int precioOriginal) async {
    try {
      await _supabase.from('productos').update({
        'precio_venta': precioOriginal,
        'precio_original': null,
      }).eq('id', productId);
      return true;
    } catch (e) {
      print('Error removing product offer: $e');
      return false;
    }
  }

  /// Removes ALL offers: restores precio_venta from precio_original for every product on offer.
  Future<int> removeAllOffers() async {
    try {
      final response = await _supabase
          .from('productos')
          .select('id, precio_original')
          .not('precio_original', 'is', null);
      final products = List<Map<String, dynamic>>.from(response as List);
      int count = 0;
      for (final p in products) {
        await _supabase.from('productos').update({
          'precio_venta': p['precio_original'],
          'precio_original': null,
        }).eq('id', p['id']);
        count++;
      }
      return count;
    } catch (e) {
      print('Error removing all offers: $e');
      return 0;
    }
  }

  /// Applies a percentage discount to all active products that have no current offer.
  Future<int> applyBulkDiscount(int percent) async {
    try {
      final response = await _supabase
          .from('productos')
          .select('id, precio_venta')
          .eq('activo', true)
          .isFilter('precio_original', null);
      final products = List<Map<String, dynamic>>.from(response as List);
      int count = 0;
      for (final p in products) {
        final precioVenta = p['precio_venta'] as int;
        final nuevoPrecio = (precioVenta * (100 - percent) / 100).round();
        await _supabase.from('productos').update({
          'precio_original': precioVenta,
          'precio_venta': nuevoPrecio,
        }).eq('id', p['id']);
        count++;
      }
      return count;
    } catch (e) {
      print('Error applying bulk discount: $e');
      return 0;
    }
  }
}
