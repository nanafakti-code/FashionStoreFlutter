import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../../config/theme/app_colors.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  String? _currentError;
  String? _newError;
  String? _confirmError;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _validateLocal() {
    setState(() {
      _currentError = _currentPasswordController.text.isEmpty
          ? 'Introduce tu contraseña actual'
          : null;

      if (_newPasswordController.text.isEmpty) {
        _newError = 'Introduce la nueva contraseña';
      } else if (_newPasswordController.text.length < 6) {
        _newError = 'Debe tener al menos 6 caracteres';
      } else {
        _newError = null;
      }

      _confirmError = _confirmController.text != _newPasswordController.text
          ? 'Las contraseñas no coinciden'
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);
    final notifier = ref.read(authNotifierProvider.notifier);

    // Si hay un error de "contraseña actual incorrecta" desde el provider, lo mostramos en el campo actual
    final currentPassErrorMessage =
        state.error != null && state.error!.contains('actual es incorrecta')
            ? state.error
            : _currentError;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cambiar Contraseña',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asegura tu cuenta',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Introduce tu contraseña actual y la nueva que deseas utilizar.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildPasswordField(
              controller: _currentPasswordController,
              label: 'Contraseña Actual',
              hint: 'Tu contraseña actual',
              show: _showCurrent,
              errorText: currentPassErrorMessage,
              onToggle: () => setState(() => _showCurrent = !_showCurrent),
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'Nueva Contraseña',
              hint: 'Mínimo 6 caracteres',
              show: _showNew,
              errorText: _newError,
              onToggle: () => setState(() => _showNew = !_showNew),
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: _confirmController,
              label: 'Confirmar Nueva Contraseña',
              hint: 'Repite la nueva contraseña',
              show: _showConfirm,
              errorText: _confirmError,
              onToggle: () => setState(() => _showConfirm = !_showConfirm),
            ),
            if (state.error != null &&
                !state.error!.contains('actual es incorrecta')) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.error!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        _validateLocal();

                        if (_currentError != null ||
                            _newError != null ||
                            _confirmError != null) {
                          return;
                        }

                        final current = _currentPasswordController.text;
                        final newPass = _newPasswordController.text;

                        final success =
                            await notifier.changePassword(current, newPass);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Contraseña actualizada con éxito'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          context.pop();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: state.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Actualizar Contraseña',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool show,
    required String? errorText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !show, // Aquí se controla si se muestra o no
          onChanged: (_) {
            if (errorText != null) {
              setState(() {
                _currentError = null;
                _newError = null;
                _confirmError = null;
              });
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            errorText: errorText, // Los errores aparecen debajo del campo
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                show
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
                size: 22,
              ),
              onPressed: onToggle, // Dispara el setState para cambiar _showX
            ),
          ),
        ),
      ],
    );
  }
}
