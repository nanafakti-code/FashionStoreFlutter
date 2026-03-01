import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../../config/theme/app_colors.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  String? _genero;
  DateTime? _fechaNacimiento;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillData();
    });
  }

  void _prefillData() {
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      _nombreController.text = user.nombre ?? '';
      _apellidosController.text = user.apellidos ?? '';
      _telefonoController.text = user.telefono ?? '';
      _genero = user.genero;
      _fechaNacimiento = user.fechaNacimiento;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileNotifierProvider);
    final notifier = ref.read(profileNotifierProvider.notifier);
    final user = ref.watch(authNotifierProvider).user;

    if (user == null) {
      return const Scaffold(
          body: Center(child: Text('Usuario no identificado')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Información Personal',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos de tu Perfil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mantén tus datos actualizados para una mejor experiencia de compra.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Nombre
            _buildField(
              _nombreController,
              'Nombre',
              'Ej: Rafael',
              Icons.person_outline,
            ),
            const SizedBox(height: 20),

            // Apellidos
            _buildField(
              _apellidosController,
              'Apellidos',
              'Ej: Blanco',
              Icons.person_outline,
            ),
            const SizedBox(height: 20),

            // Email (Inmutable)
            _buildField(
              null,
              'Email',
              user.email,
              Icons.email_outlined,
              enabled: false,
            ),
            const SizedBox(height: 4),
            const Text(
              'El email no puede ser cambiado',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Teléfono
            _buildField(
              _telefonoController,
              'Teléfono',
              'Ej: 658823543',
              Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Género y Fecha
            Row(
              children: [
                Expanded(child: _genderDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _datePickerField()),
              ],
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        final userId = user.id;
                        final messenger = ScaffoldMessenger.of(context);

                        final success = await notifier.updateProfile(
                          userId: userId,
                          nombre: _nombreController.text,
                          apellidos: _apellidosController.text,
                          telefono: _telefonoController.text,
                          genero: _genero,
                          fechaNacimiento: _fechaNacimiento,
                        );

                        if (mounted) {
                          if (success) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Perfil actualizado con éxito'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            context.pop();
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content:
                                    Text(state.error ?? 'Error al actualizar'),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
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
                        'Guardar Cambios',
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

  Widget _buildField(
    TextEditingController? controller,
    String label,
    String hint,
    IconData icon, {
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
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
          enabled: enabled,
          keyboardType: keyboardType,
          style: TextStyle(color: enabled ? Colors.black87 : Colors.grey),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: Colors.grey),
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _genderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Género',
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _genero,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              hint: const Text('Seleccionar', style: TextStyle(fontSize: 14)),
              items: const [
                DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                DropdownMenuItem(value: 'Otro', child: Text('Otro')),
              ],
              onChanged: (val) {
                setState(() => _genero = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _datePickerField() {
    final dateStr = _fechaNacimiento != null
        ? '${_fechaNacimiento!.day.toString().padLeft(2, '0')}/${_fechaNacimiento!.month.toString().padLeft(2, '0')}/${_fechaNacimiento!.year}'
        : 'Seleccionar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nacimiento',
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _fechaNacimiento ?? DateTime(2005, 3, 24),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => _fechaNacimiento = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr, style: const TextStyle(fontSize: 14)),
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
