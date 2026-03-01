import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../../config/theme/app_colors.dart';

class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authNotifierProvider).user?.id;
      if (userId != null) {
        ref.read(profileNotifierProvider.notifier).loadAddresses(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileNotifierProvider);
    final notifier = ref.read(profileNotifierProvider.notifier);
    final userId = ref.watch(authNotifierProvider).user?.id;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mis Direcciones',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Builder(builder: (context) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          return Center(child: Text('Error: ${state.error}'));
        }
        if (state.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off_outlined,
                    size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No tienes direcciones guardadas',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      _showAddressDialog(context, notifier, userId),
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir mi primera dirección'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.addresses.length,
          itemBuilder: (context, index) {
            final address = state.addresses[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: address.esPredeterminada
                    ? Border.all(color: AppColors.primary, width: 2)
                    : Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          address.esPredeterminada
                              ? Icons.home_rounded
                              : Icons.location_on_rounded,
                          color: address.esPredeterminada
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            address.nombreDestinatario,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        if (address.esPredeterminada)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PREDETERMINADA',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      address.direccionCompleta,
                      style: TextStyle(color: Colors.grey[800], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${address.ciudad}, ${address.provincia} (${address.pais})',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const Divider(height: 32),
                    Row(
                      children: [
                        if (!address.esPredeterminada)
                          TextButton.icon(
                            onPressed: userId != null
                                ? () => notifier.setAddressAsDefault(
                                    userId, address.id)
                                : null,
                            icon: const Icon(Icons.check_circle_outline,
                                size: 18),
                            label: const Text('Hacer predeterminada'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: userId != null
                              ? () => _confirmDelete(context, notifier, userId,
                                  address.id, address.esPredeterminada)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddressDialog(context, notifier, userId),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProfileNotifier notifier,
      String userId, String addressId, bool isDefault) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar dirección'),
        content: Text(isDefault
            ? 'Estás a punto de eliminar tu dirección predeterminada. ¿Continuar?'
            : '¿Seguro que quieres eliminar esta dirección?'),
        actions: [
          TextButton(
              onPressed: () => context.pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              notifier.deleteAddress(userId, addressId);
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showAddressDialog(
      BuildContext context, ProfileNotifier notifier, String? userId) {
    if (userId == null) return;

    final nombreController = TextEditingController();
    final calleController = TextEditingController();
    final numeroController = TextEditingController();
    final pisoController = TextEditingController();
    final cpController = TextEditingController();
    final ciudadController = TextEditingController();
    final provinciaController = TextEditingController();
    String tipo = 'Ambas';
    bool esPredeterminada = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Añadir Dirección',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildField(nombreController, 'Nombre del destinatario',
                    Icons.person_outline),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: tipo,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Dirección',
                    prefixIcon: const Icon(Icons.label_outline, size: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['Envío', 'Facturación', 'Ambas']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setModalState(() => tipo = val!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: _buildField(
                            calleController, 'Calle', Icons.map_outlined)),
                    const SizedBox(width: 12),
                    Expanded(
                        flex: 1,
                        child: _buildField(numeroController, 'Nº', null)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildField(pisoController, 'Piso/Puerta (Opcional)',
                    Icons.door_front_door_outlined),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildField(
                            cpController, 'Código Postal', Icons.numbers)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildField(
                            ciudadController, 'Ciudad', Icons.location_city)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildField(provinciaController, 'Provincia', Icons.map),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Establecer como predeterminada'),
                  value: esPredeterminada,
                  onChanged: (val) =>
                      setModalState(() => esPredeterminada = val),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nombreController.text.isNotEmpty &&
                          calleController.text.isNotEmpty &&
                          numeroController.text.isNotEmpty &&
                          cpController.text.isNotEmpty &&
                          ciudadController.text.isNotEmpty &&
                          provinciaController.text.isNotEmpty) {
                        final success = await notifier.addAddress(userId, {
                          'nombre_destinatario': nombreController.text,
                          'tipo': tipo,
                          'calle': calleController.text,
                          'numero': numeroController.text,
                          'piso': pisoController.text.isEmpty
                              ? null
                              : pisoController.text,
                          'codigo_postal': cpController.text,
                          'ciudad': ciudadController.text,
                          'provincia': provinciaController.text,
                          'pais': 'España',
                          'es_predeterminada': esPredeterminada,
                        });
                        if (success && context.mounted) {
                          context.pop();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Por favor, rellena los campos obligatorios')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Guardar Dirección',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller, String label, IconData? icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
