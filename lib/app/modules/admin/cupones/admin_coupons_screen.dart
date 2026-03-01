import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../providers/admin_provider.dart';
import '../../../data/models/coupon_model.dart';
import 'widgets/coupon_card.dart';
import 'widgets/create_coupon_form.dart';

class AdminCouponsScreen extends ConsumerStatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  ConsumerState<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends ConsumerState<AdminCouponsScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _isCreating = false;
  CouponModel? _editingCoupon;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(adminNotifierProvider.notifier);
      notifier.loadCoupons();
      if (ref.read(adminNotifierProvider).users.isEmpty) {
        notifier.loadUsers();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onToggleStatus(CouponModel coupon) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Cupón'),
        content: Text(
            '¿Estás seguro de que deseas eliminar el cupón "${coupon.code}"? Esta acción no se puede deshacer.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(adminNotifierProvider.notifier)
                  .deleteCoupon(coupon.id.toString());
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cupón eliminado')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _onEdit(CouponModel coupon) {
    setState(() {
      _editingCoupon = coupon;
      _isCreating = true;
    });
  }

  Widget _buildHeader(int count, bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.confirmation_number_rounded,
                  color: AppColors.navy),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gestión de Cupones',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy)),
                  Text('$count cupones',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isCreating = true;
                  _editingCoupon = null;
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nuevo Cupón',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Buscar por código de cupón...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(adminNotifierProvider);
    var coupons = state.coupons;

    final filtered = coupons.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.code.toLowerCase().contains(q) ||
          (c.description?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: _isCreating
          ? CreateCouponForm(
              initialCoupon: _editingCoupon,
              onCancel: () => setState(() {
                _isCreating = false;
                _editingCoupon = null;
              }),
              onSuccess: () => setState(() {
                _isCreating = false;
                _editingCoupon = null;
              }),
            )
          : Column(
              children: [
                _buildHeader(filtered.length, state.isLoading),
                _buildActions(),
                Expanded(
                  child: state.isLoading && coupons.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.confirmation_number_outlined,
                                      size: 64, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text('No hay cupones registrados',
                                      style:
                                          TextStyle(color: Colors.grey[500])),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (_, i) {
                                final coupon = filtered[i];
                                String? assignedUserEmail;
                                if (coupon.assignedUserId != null) {
                                  try {
                                    final user = state.users.firstWhere(
                                      (u) => u['id'] == coupon.assignedUserId,
                                    );
                                    assignedUserEmail =
                                        user['email'] as String?;
                                  } catch (_) {
                                    // User not found in state
                                  }
                                }

                                return CouponCard(
                                  coupon: coupon,
                                  assignedUserEmail: assignedUserEmail,
                                  onToggleStatus: () => _onToggleStatus(coupon),
                                  onEdit: () => _onEdit(coupon),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}
