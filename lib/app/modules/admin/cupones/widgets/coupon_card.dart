import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../config/theme/app_colors.dart';
import '../../../../data/models/coupon_model.dart';

class CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final String? assignedUserEmail;
  final VoidCallback onToggleStatus;
  final VoidCallback onEdit;

  const CouponCard({
    super.key,
    required this.coupon,
    this.assignedUserEmail,
    required this.onToggleStatus,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Code and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.code.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navy,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'CÓDIGO',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(coupon.isActive),
              ],
            ),
            const SizedBox(height: 24),

            // Discount & Expiration
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESCUENTO',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon.discountType == 'PERCENTAGE'
                            ? '${coupon.value.toInt()}%'
                            : '${coupon.value.toStringAsFixed(2)}€',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2B5C9C), // Blue from screenshot
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'VENCIMIENTO',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(coupon.expirationDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Usage Stats
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildStatRow(
                      'USOS TOTALES',
                      coupon.maxUsesGlobal != null
                          ? '${coupon.maxUsesGlobal}'
                          : '∞'),
                  const SizedBox(height: 16),
                  _buildStatRow('USOS/USUARIO', '${coupon.maxUsesPerUser}'),
                  if (coupon.assignedUserId != null) ...[
                    const SizedBox(height: 16),
                    _buildStatRow(
                      'ASIGNADO A',
                      assignedUserEmail ?? coupon.assignedUserId!,
                      valueColor: Colors.purple,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Editar',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2B5C9C),
                      side: BorderSide(color: Colors.blue.shade100),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        onToggleStatus, // Reused the callback prop, we'll change it later if needed or just use it as onDelete
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text(
                      'Eliminar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(
                        color: Colors.red.shade100,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.navy,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isActive ? AppColors.green.withOpacity(0.3) : Colors.red.shade200,
        ),
      ),
      child: Text(
        isActive ? 'ACTIVO' : 'INACTIVO',
        style: TextStyle(
          color: isActive ? AppColors.green : Colors.red.shade700,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
