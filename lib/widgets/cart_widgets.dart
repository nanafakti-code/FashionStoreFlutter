import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/carrito.dart';
import '../config/app_theme.dart';

/// Widget de item del carrito
class CartItemWidget extends StatelessWidget {
  final CarritoItem item;
  final ValueChanged<int>? onQuantityChanged;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const CartItemWidget({
    super.key,
    required this.item,
    this.onQuantityChanged,
    this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: item.productoImagen != null
                    ? CachedNetworkImage(
                        imageUrl: item.productoImagen!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
            ),

            const SizedBox(width: 12),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    item.productoNombre,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Variante (talla/color)
                  if (item.talla != null || item.color != null)
                    Text(
                      [
                        if (item.talla != null) 'Talla: ${item.talla}',
                        if (item.color != null) 'Color: ${item.color}',
                      ].join(' • '),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Precio y cantidad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Precio
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.precioEnEuros.toStringAsFixed(2)}€',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (item.cantidad > 1)
                            Text(
                              'Total: ${item.subtotalEnEuros.toStringAsFixed(2)}€',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),

                      // Selector de cantidad
                      QuantitySelector(
                        quantity: item.cantidad,
                        onChanged: onQuantityChanged,
                        max: item.productoStock ?? 99,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botón eliminar
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 20),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}

/// Selector de cantidad
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int>? onChanged;
  final int min;
  final int max;

  const QuantitySelector({
    super.key,
    required this.quantity,
    this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón menos
          _QuantityButton(
            icon: Icons.remove,
            onTap: quantity > min ? () => onChanged?.call(quantity - 1) : null,
          ),

          // Cantidad
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Botón más
          _QuantityButton(
            icon: Icons.add,
            onTap: quantity < max ? () => onChanged?.call(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? AppColors.text : Colors.grey[400],
        ),
      ),
    );
  }
}

/// Resumen del carrito
class CartSummaryWidget extends StatelessWidget {
  final CarritoResumen resumen;
  final VoidCallback? onCheckout;
  final bool showCheckoutButton;

  const CartSummaryWidget({
    super.key,
    required this.resumen,
    this.onCheckout,
    this.showCheckoutButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal
          _SummaryRow(
            label: 'Subtotal (${resumen.itemCount} productos)',
            value: '${resumen.subtotalEnEuros.toStringAsFixed(2)}€',
          ),

          // Envío
          if (resumen.envio > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Envío',
              value: '${resumen.envioEnEuros.toStringAsFixed(2)}€',
            ),
          ],

          // Descuento
          if (resumen.descuento > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Descuento',
              value: '-${resumen.descuentoEnEuros.toStringAsFixed(2)}€',
              valueColor: AppColors.primary,
            ),
          ],

          const Divider(height: 24),

          // Total
          _SummaryRow(
            label: 'Total',
            value: '${resumen.totalEnEuros.toStringAsFixed(2)}€',
            isTotal: true,
          ),

          // Botón checkout
          if (showCheckoutButton) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: resumen.isEmpty ? null : onCheckout,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Ir al pago'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.text : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isTotal ? AppColors.primary : AppColors.text),
          ),
        ),
      ],
    );
  }
}
