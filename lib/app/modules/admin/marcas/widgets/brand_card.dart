import 'package:flutter/material.dart';
import 'package:fashion_store_flutter/config/theme/app_colors.dart';
import '../admin_brands_controller.dart';

class BrandCard extends StatelessWidget {
  final AdminBrand brand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BrandCard({
    super.key,
    required this.brand,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              brand.nombre,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: brand.activa
                                  ? AppColors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              brand.activa ? 'ACTIVA' : 'INACTIVA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color:
                                    brand.activa ? AppColors.green : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (brand.slug.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          brand.slug,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      if (brand.descripcion != null &&
                          brand.descripcion!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          brand.descripcion!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('EDITAR',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('ELIMINAR',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
