import 'package:supabase_flutter/supabase_flutter.dart';
import '../../modules/admin/models/dashboard_models.dart';

/// Real Supabase-backed Dashboard Service.
/// Prices stored in céntimos — always divide by 100 to display.
class DashboardService {
  final _db = Supabase.instance.client;

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final now = DateTime.now();
      final todayLocal = DateTime(now.year, now.month, now.day);
      final monthLocal = DateTime(now.year, now.month, 1);

      // ── Run all queries in parallel for speed ──────────────────────────────
      final results = await Future.wait([
        // 0: Stats queries on productos (active only)
        _db
            .from('productos')
            .select('stock_total, precio_venta')
            .eq('activo', true),

        // 1: All orders (for counts & sales totals)
        _db.from('ordenes').select('total, estado, fecha_creacion'),

        // 2: Active users count
        _db.from('usuarios').select('id'),

        // 3: Total returns count (all statuses)
        _db.from('devoluciones').select('id'),

        // 4: Average review score
        _db.from('resenas').select('calificacion'),

        // 5: Recent 10 products
        _db
            .from('productos')
            .select('nombre, stock_total, precio_venta')
            .eq('activo', true)
            .order('creado_en', ascending: false)
            .limit(10),

        // 6: Latest 10 paid orders
        _db
            .from('ordenes')
            .select(
                'numero_orden, nombre_cliente, email_cliente, total, estado, fecha_creacion')
            .eq('estado', 'Pagado')
            .order('fecha_creacion', ascending: false)
            .limit(10),

        // 7: Latest 10 active users
        _db
            .from('usuarios')
            .select('nombre, email')
            .order('fecha_registro', ascending: false)
            .limit(10),

        // 8: All categories
        _db.from('categorias').select('nombre, slug').order('nombre'),

        // 9: Top 10 brands
        _db.from('marcas').select('nombre').order('nombre').limit(10),

        // 10: Top 10 coupons
        // 10: Top 10 coupons from stats view
        _db.from('coupon_stats').select().limit(10),
      ]);

      // ── Productos (result[0]) ─────────────────────────────────────────────
      final productos = results[0] as List;
      final totalProductos = productos.length;
      final totalStock = productos.fold<int>(
          0, (sum, p) => sum + ((p['stock_total'] ?? 0) as int));
      final valorInventario = productos.fold<double>(
          0,
          (sum, p) =>
              sum +
              ((p['precio_venta'] ?? 0) as int) *
                  ((p['stock_total'] ?? 0) as int) /
                  100);

      // ── Órdenes (result[1]) ───────────────────────────────────────────────
      final ordenes = results[1] as List;
      final totalPedidos = ordenes.length;

      double ventasHoy = 0;
      double ventasMes = 0;
      int ordenesEnProceso = 0;

      for (final o in ordenes) {
        final estado = o['estado'] as String? ?? '';
        final totalRaw = o['total'];
        final total = (totalRaw is int)
            ? totalRaw / 100.0
            : (totalRaw is num)
                ? totalRaw.toDouble() / 100.0
                : 0.0;
        final fechaStr = o['fecha_creacion'] as String? ?? '';

        // Parsear correctamente la fecha (Supabase devuelve UTC)
        DateTime? fechaOrden;
        if (fechaStr.isNotEmpty) {
          fechaOrden = DateTime.tryParse(fechaStr)?.toLocal();
        }

        // Cancelado: no contar | Reembolsada: restar | Resto: sumar
        final esCancelada = estado == 'Cancelado';
        final esReembolsada = estado == 'Reembolsada';

        if (fechaOrden != null && !esCancelada) {
          final fechaLocal =
              DateTime(fechaOrden.year, fechaOrden.month, fechaOrden.day);

          // Ventas hoy
          if (fechaLocal == todayLocal) {
            if (esReembolsada) {
              ventasHoy -= total;
            } else {
              ventasHoy += total;
            }
          }

          // Ventas mes
          if (!fechaLocal.isBefore(monthLocal)) {
            if (esReembolsada) {
              ventasMes -= total;
            } else {
              ventasMes += total;
            }
          }
        }

        if (estado == 'Pagado') {
          ordenesEnProceso++;
        }
      }

      // ── Usuarios (result[2]) ──────────────────────────────────────────────
      final clientesActivos = (results[2] as List).length;

      // ── Devoluciones (result[3]) ──────────────────────────────────────────
      final devolucionesTotal = (results[3] as List).length;

      // ── Reseñas (result[4]) ───────────────────────────────────────────────
      final resenas = results[4] as List;
      final reseniasPromedio = resenas.isEmpty
          ? 0.0
          : resenas.fold<double>(
                  0, (sum, r) => sum + ((r['calificacion'] ?? 0) as num)) /
              resenas.length;

      // ── Build models ──────────────────────────────────────────────────────
      final stats = DashboardStats(
        totalProductos: totalProductos,
        totalStock: totalStock,
        valorInventario: valorInventario,
        totalPedidos: totalPedidos,
        ventasHoy: ventasHoy,
        ventasMes: ventasMes,
        clientesActivos: clientesActivos,
        ordenesEnProceso: ordenesEnProceso,
        devolucionesActivas: devolucionesTotal,
        reseniasPromedio: reseniasPromedio,
      );

      // ── Recent products (result[5]) ───────────────────────────────────────
      final recentProducts = (results[5] as List)
          .map((p) => Product(
                nombre: p['nombre'] ?? '',
                stockTotal: (p['stock_total'] ?? 0) as int,
                precioVenta: ((p['precio_venta'] ?? 0) as int) / 100.0,
                category: '',
              ))
          .toList();

      // ── Recent paid orders (result[6]) ────────────────────────────────────
      final recentOrders = (results[6] as List)
          .map((o) => Order(
                id: '',
                numeroOrden: o['numero_orden'] ?? '',
                nombreCliente: o['nombre_cliente'] ?? '',
                emailCliente: o['email_cliente'] ?? '',
                total: ((o['total'] ?? 0) as int) / 100.0,
                estado: o['estado'] ?? '',
                fechaCreacion: o['fecha_creacion'] != null
                    ? DateTime.tryParse(o['fecha_creacion']) ?? DateTime.now()
                    : DateTime.now(),
              ))
          .toList();

      // ── Recent users (result[7]) ──────────────────────────────────────────
      final recentUsers = (results[7] as List)
          .map((u) => DashboardUser(
                nombre: u['nombre'] ?? '',
                email: u['email'] ?? '',
              ))
          .toList();

      // ── Categories (result[8]) ────────────────────────────────────────────
      final categories = (results[8] as List)
          .map((c) => DashboardCategory(
                nombre: c['nombre'] ?? '',
                slug: c['slug'] ?? '',
              ))
          .toList();

      // ── Brands (result[9]) ────────────────────────────────────────────────
      final brands = (results[9] as List)
          .map((b) => DashboardBrand(nombre: b['nombre'] ?? ''))
          .toList();

      // ── Coupons (result[10]) ──────────────────────────────────────────────
      final coupons = (results[10] as List).map((c) {
        final codigo = c['code'] as String? ?? c['codigo'] as String? ?? '';
        final tipo =
            c['discount_type'] as String? ?? c['tipo'] as String? ?? '';
        final valRaw = c['value'] ?? c['valor'] ?? 0;
        final valor = (valRaw is num) ? valRaw.toDouble() : 0.0;

        final esPorcentaje = tipo.toLowerCase().contains('percent') ||
            tipo.toLowerCase().contains('porcentaje');

        return DashboardCoupon(
          codigo: codigo,
          descuentoPorcentaje: esPorcentaje ? valor : 0.0,
          montoFijo: !esPorcentaje ? valor : 0.0,
        );
      }).toList();

      return {
        'stats': stats,
        'recentOrders': recentOrders,
        'recentProducts': recentProducts,
        'recentUsers': recentUsers,
        'categories': categories,
        'brands': brands,
        'coupons': coupons,
        'rawOrders': ordenes,
      };
    } catch (e) {
      print('DashboardService error: $e');
      return {
        'stats': DashboardStats.empty(),
        'recentOrders': <Order>[],
        'recentProducts': <Product>[],
        'products': <Product>[],
        'recentUsers': <DashboardUser>[],
        'categories': <DashboardCategory>[],
        'brands': <DashboardBrand>[],
        'coupons': <DashboardCoupon>[],
      };
    }
  }
}
