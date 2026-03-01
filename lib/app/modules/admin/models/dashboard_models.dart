class DashboardStats {
  final int totalProductos;
  final int totalStock;
  final double valorInventario;
  final int totalPedidos;
  final double ventasHoy;
  final double ventasMes;
  final int clientesActivos;
  final int ordenesEnProceso;
  final int devolucionesActivas;
  final double reseniasPromedio;

  DashboardStats({
    required this.totalProductos,
    required this.totalStock,
    required this.valorInventario,
    required this.totalPedidos,
    required this.ventasHoy,
    required this.ventasMes,
    required this.clientesActivos,
    required this.ordenesEnProceso,
    required this.devolucionesActivas,
    required this.reseniasPromedio,
  });
  factory DashboardStats.empty() => DashboardStats(
        totalProductos: 0,
        totalStock: 0,
        valorInventario: 0,
        totalPedidos: 0,
        ventasHoy: 0,
        ventasMes: 0,
        clientesActivos: 0,
        ordenesEnProceso: 0,
        devolucionesActivas: 0,
        reseniasPromedio: 0,
      );
}

class Product {
  final String nombre;
  final int stockTotal;
  final double precioVenta;
  final String? imageUrl;
  final String category;

  Product({
    required this.nombre,
    required this.stockTotal,
    required this.precioVenta,
    this.imageUrl,
    required this.category,
  });
}

class Order {
  final String id;
  final String numeroOrden;
  final String nombreCliente;
  final String emailCliente;
  final double total;
  final String estado;
  final DateTime fechaCreacion;

  Order({
    required this.id,
    required this.numeroOrden,
    required this.nombreCliente,
    required this.emailCliente,
    required this.total,
    required this.estado,
    required this.fechaCreacion,
  });
}

class DashboardUser {
  final String nombre;
  final String email;

  DashboardUser({required this.nombre, required this.email});
}

class DashboardCategory {
  final String nombre;
  final String slug;

  DashboardCategory({required this.nombre, required this.slug});
}

class DashboardBrand {
  final String nombre;

  DashboardBrand({required this.nombre});
}

class DashboardCoupon {
  final String codigo;
  final double descuentoPorcentaje;
  final double montoFijo;

  DashboardCoupon({
    required this.codigo,
    required this.descuentoPorcentaje,
    required this.montoFijo,
  });
}
