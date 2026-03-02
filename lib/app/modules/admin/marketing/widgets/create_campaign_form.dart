import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/app_spacing.dart';
import '../../../../providers/admin_provider.dart';

class CreateCampaignForm extends ConsumerStatefulWidget {
  const CreateCampaignForm({super.key});

  @override
  ConsumerState<CreateCampaignForm> createState() => _CreateCampaignFormState();
}

class _CreateCampaignFormState extends ConsumerState<CreateCampaignForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _asuntoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _htmlController = TextEditingController();

  String _selectedTemplate = 'en blanco';
  bool _isSubmitting = false;

  final Map<String, String> _templates = {
    'Promoción /\nDescuento':
        '<h1>¡Gran Promoción!</h1>\n<p>Aprovecha nuestro descuento del 10% en electrónica usando el código exclusivo de este correo.</p>',
    'Nuevos productos':
        '<h1>Nuevas llegadas</h1>\n<p>Descubre los últimos dispositivos iPhone y accesorios reacondicionados en nuestra tienda.</p>',
    'Newsletter\ninformativa':
        '<h1>Novedades de la semana</h1>\n<p>Aquí tienes las últimas noticias sobre tecnología y economía circular que no te puedes perder.</p>',
    'en blanco': '',
  };

  @override
  void dispose() {
    _nombreController.dispose();
    _asuntoController.dispose();
    _descripcionController.dispose();
    _htmlController.dispose();
    super.dispose();
  }

  void _applyTemplate(String templateName) {
    setState(() {
      _selectedTemplate = templateName;
      _htmlController.text = _templates[templateName] ?? '';
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_htmlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El contenido HTML no puede estar vacío.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final data = {
      'id': const Uuid().v4(),
      'nombre': _nombreController.text.trim(),
      'asunto': _asuntoController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'contenido_html': _htmlController.text.trim(),
      'estado': 'Borrador',
      'tipo_segmento': 'Todos',
      'creada_en': DateTime.now().toIso8601String(),
    };

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final success =
        await ref.read(adminNotifierProvider.notifier).createCampaign(data);

    setState(() => _isSubmitting = false);

    if (success) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Campaña creada. Está guardada como Borrador.'),
          backgroundColor: AppColors.success,
        ),
      );
      navigator.pop();
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Error al crear la campaña.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nueva campaña',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.grey500),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Body
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  const Text('Plantillas',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.md),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: _templates.keys.map((key) {
                      final isSelected = _selectedTemplate == key;
                      return OutlinedButton(
                        onPressed: () => _applyTemplate(key),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              isSelected ? AppColors.white : AppColors.navy,
                          backgroundColor: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          key,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildLabel('Nombre *'),
                  TextFormField(
                    controller: _nombreController,
                    decoration: _inputDecoration('Ej. Ofertas de Verano'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildLabel('Asunto del email *'),
                  TextFormField(
                    controller: _asuntoController,
                    decoration:
                        _inputDecoration('Ej. Ofertas exclusivas para ti'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildLabel('Descripción interna'),
                  TextFormField(
                    controller: _descripcionController,
                    decoration:
                        _inputDecoration('Para organizar (no se envía)'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildLabel('Contenido HTML *'),
                  TextFormField(
                    controller: _htmlController,
                    maxLines: 8,
                    decoration:
                        _inputDecoration('<hx> Escribe tu HTML aquí...</hx>'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : const Text(
                        'Guardar Campaña',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.transparent,
    );
  }
}
