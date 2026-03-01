import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../config/theme/app_colors.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../data/models/coupon_model.dart';

class CreateCouponForm extends ConsumerStatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSuccess;
  final CouponModel? initialCoupon;

  const CreateCouponForm({
    super.key,
    required this.onCancel,
    required this.onSuccess,
    this.initialCoupon,
  });

  @override
  ConsumerState<CreateCouponForm> createState() => _CreateCouponFormState();
}

class _CreateCouponFormState extends ConsumerState<CreateCouponForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _minOrderCtrl = TextEditingController();
  final _maxUsesGlobalCtrl = TextEditingController();
  final _maxUsesUserCtrl = TextEditingController(text: '1');
  final _descCtrl = TextEditingController();

  String _discountType = 'PERCENTAGE';
  DateTime? _expirationDate;
  String _assignType = 'all'; // 'all' or 'specific'
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    if (widget.initialCoupon != null) {
      final coupon = widget.initialCoupon!;
      _codeCtrl.text = coupon.code;
      _descCtrl.text = coupon.description ?? '';
      _discountType = coupon.discountType;
      // Remueve decimales si es 0 (ej 10.0 -> 10)
      _valueCtrl.text = coupon.value == coupon.value.toInt()
          ? coupon.value.toInt().toString()
          : coupon.value.toString();
      if (coupon.minOrderValue != null) {
        _minOrderCtrl.text =
            coupon.minOrderValue == coupon.minOrderValue!.toInt()
                ? coupon.minOrderValue!.toInt().toString()
                : coupon.minOrderValue.toString();
      }
      _maxUsesGlobalCtrl.text = coupon.maxUsesGlobal?.toString() ?? '';
      _maxUsesUserCtrl.text = coupon.maxUsesPerUser.toString();
      _expirationDate = coupon.expirationDate;

      if (coupon.assignedUserId != null &&
          coupon.assignedUserId!.trim().isNotEmpty) {
        _assignType = 'specific';
        _selectedUserId = coupon.assignedUserId;
      } else {
        _assignType = 'all';
      }
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _valueCtrl.dispose();
    _minOrderCtrl.dispose();
    _maxUsesGlobalCtrl.dispose();
    _maxUsesUserCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _expirationDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.green,
              onPrimary: Colors.white,
              onSurface: AppColors.navy,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expirationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, selecciona una fecha de expiración')),
      );
      return;
    }
    if (_assignType == 'specific' && _selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un usuario')),
      );
      return;
    }

    final data = {
      'code': _codeCtrl.text.trim().toUpperCase(),
      'description':
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      'discount_type': _discountType,
      'value': double.tryParse(_valueCtrl.text) ?? 0.0,
      'min_order_value': double.tryParse(_minOrderCtrl.text),
      'max_uses_global': int.tryParse(_maxUsesGlobalCtrl.text),
      'max_uses_per_user': int.tryParse(_maxUsesUserCtrl.text) ?? 1,
      'expiration_date': _expirationDate!.toIso8601String(),
      'is_active': widget.initialCoupon?.isActive ?? true,
      'assigned_user_id': _assignType == 'specific' ? _selectedUserId : null,
    };

    bool success;
    if (widget.initialCoupon != null) {
      success = await ref
          .read(adminNotifierProvider.notifier)
          .updateCoupon(widget.initialCoupon!.id.toString(), data);
    } else {
      success =
          await ref.read(adminNotifierProvider.notifier).createCoupon(data);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.initialCoupon != null
                ? 'Cupón actualizado correctamente'
                : 'Cupón creado correctamente')),
      );
      widget.onSuccess();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(ref.read(adminNotifierProvider).error ??
                'Error al ${widget.initialCoupon != null ? 'actualizar' : 'crear'} cupón')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminNotifierProvider);
    final users = state.users;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.confirmation_number_rounded,
                    color: AppColors.navy),
                const SizedBox(width: 10),
                Text(
                    widget.initialCoupon != null
                        ? 'Editar Cupón'
                        : 'Gestión de Cupones',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy)),
                const Spacer(),
                if (state.isLoading)
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
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Cancelar',
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
            const SizedBox(height: 24),

            // Form Fields
            _buildLabel('CÓDIGO DEL CUPÓN *'),
            TextFormField(
              controller: _codeCtrl,
              decoration: _inputDecoration('Ej: SUMMER2025'),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return TextEditingValue(
                    text: newValue.text.toUpperCase(),
                    selection: newValue.selection,
                  );
                }),
              ],
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('TIPO'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _discountType,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                  value: 'PERCENTAGE',
                                  child: Text('Porcentaje (%)')),
                              DropdownMenuItem(
                                  value: 'FIXED', child: Text('Fijo (€)')),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _discountType = v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('VALOR *'),
                      TextFormField(
                        controller: _valueCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: _inputDecoration('Ej: 10'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('MIN. COMPRA (€)'),
                      _buildSubLabel('Opcional'),
                      TextFormField(
                        controller: _minOrderCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: _inputDecoration('0.00'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('LÍMITE USOS TOTALES'),
                      _buildSubLabel('Vacío = ilimitado'),
                      TextFormField(
                        controller: _maxUsesGlobalCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('∞ ilimitado'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('USOS / USUARIO *'),
                      _buildSubLabel('Por cada usuario'),
                      TextFormField(
                        controller: _maxUsesUserCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('1'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('EXPIRACIÓN *'),
                      const SizedBox(
                          height: 14), // To align with the field on the left
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _expirationDate == null
                                    ? 'dd/mm/aaaa'
                                    : DateFormat('dd/MM/yyyy')
                                        .format(_expirationDate!),
                                style: TextStyle(
                                  color: _expirationDate == null
                                      ? Colors.grey.shade500
                                      : Colors.black87,
                                ),
                              ),
                              const Icon(Icons.calendar_today,
                                  size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildLabel('DESCRIPCIÓN'),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: _inputDecoration('Descripción opcional del cupón'),
            ),
            const SizedBox(height: 24),

            _buildLabel('ASIGNAR A'),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Todos los usuarios',
                        style: TextStyle(fontSize: 12)),
                    value: 'all',
                    groupValue: _assignType,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.green,
                    onChanged: (v) => setState(() {
                      _assignType = v!;
                      _selectedUserId = null;
                    }),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Usuario específico',
                        style: TextStyle(fontSize: 12)),
                    value: 'specific',
                    groupValue: _assignType,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.green,
                    onChanged: (v) => setState(() => _assignType = v!),
                  ),
                ),
              ],
            ),

            if (_assignType == 'specific') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedUserId,
                    hint: const Text('Seleccionar usuario...'),
                    isExpanded: true,
                    items: users.map((u) {
                      final email = u['email'] as String? ?? 'Sin correo';
                      return DropdownMenuItem(
                        value: u['id'] as String,
                        child: Text(email, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedUserId = v),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: widget.onCancel,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancelar',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            widget.initialCoupon != null
                                ? 'Guardar Cambios'
                                : 'Crear Cupón',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSubLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green, width: 2),
      ),
    );
  }
}
