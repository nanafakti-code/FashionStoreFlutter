import '../../modules/admin/models/dashboard_models.dart';

class MockDashboardService {
  Future<Map<String, dynamic>> getDashboardData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final stats = DashboardStats(
      totalProductos: 142,
      totalStock: 3850,
      valorInventario: 125430.50,
      totalPedidos: 1245,
      ventasHoy: 2450.80,
      ventasMes: 68900.25,
      clientesActivos: 892,
      ordenesEnProceso: 24,
      devolucionesActivas: 5,
      reseniasPromedio: 4.8,
    );

    final recentOrders = [
      Order(
        id: '1',
        numeroOrden: 'ORD-2024-001',
        nombreCliente: 'Ana Martínez',
        emailCliente: 'ana.martinez@email.com',
        total: 129.99,
        estado: 'Completado',
        fechaCreacion: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      Order(
        id: '2',
        numeroOrden: 'ORD-2024-002',
        nombreCliente: 'Carlos Ruiz',
        emailCliente: 'carlos.r@email.com',
        total: 89.50,
        estado: 'En Proceso',
        fechaCreacion: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Order(
        id: '3',
        numeroOrden: 'ORD-2024-003',
        nombreCliente: 'Laura García',
        emailCliente: 'laura.g@email.com',
        total: 245.00,
        estado: 'Pendiente',
        fechaCreacion: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Order(
        id: '4',
        numeroOrden: 'ORD-2024-004',
        nombreCliente: 'Miguel Ángel',
        emailCliente: 'miguel.a@email.com',
        total: 45.90,
        estado: 'Enviado',
        fechaCreacion: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Order(
        id: '5',
        numeroOrden: 'ORD-2024-005',
        nombreCliente: 'Sofía López',
        emailCliente: 'sofia.l@email.com',
        total: 189.99,
        estado: 'Completado',
        fechaCreacion: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    final topProducts = [
      Product(
        nombre: 'Nike Air Max 270',
        stockTotal: 45,
        precioVenta: 149.99,
        category: 'Calzado',
      ),
      Product(
        nombre: 'Adidas Ultraboost',
        stockTotal: 28,
        precioVenta: 179.99,
        category: 'Calzado',
      ),
      Product(
        nombre: 'Sudadera Essentials',
        stockTotal: 120,
        precioVenta: 59.99,
        category: 'Ropa',
      ),
      Product(
        nombre: 'Pantalón Cargo',
        stockTotal: 65,
        precioVenta: 45.50,
        category: 'Ropa',
      ),
      Product(
        nombre: 'Gorra NY Yankees',
        stockTotal: 200,
        precioVenta: 25.00,
        category: 'Accesorios',
      ),
    ];

    return {
      'stats': stats,
      'recentOrders': recentOrders,
      'topProducts': topProducts,
    };
  }
}
