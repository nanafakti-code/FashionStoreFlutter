import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../providers/admin_provider.dart';
import 'widgets/user_card.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminNotifierProvider.notifier).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showUserDetails(Map<String, dynamic> user) {
    final nombre = user['nombre'] as String?;
    final apellidos = user['apellidos'] as String?;
    final email = user['email'] as String? ?? 'Sin email';
    final telefono = user['telefono'] as String? ?? 'No especificado';
    final rol = user['rol'] as String? ?? 'user';

    final nombreCompleto = (nombre == null && apellidos == null)
        ? email
        : '${nombre ?? ''} ${apellidos ?? ''}'.trim();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detalles del Usuario',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: CircleAvatar(
                    backgroundColor: AppColors.navy.withOpacity(0.1),
                    radius: 40,
                    child: Text(
                      nombreCompleto.isNotEmpty
                          ? nombreCompleto[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Nombre:', nombreCompleto),
                const Divider(),
                _buildDetailRow('Email:', email),
                const Divider(),
                _buildDetailRow('Teléfono:', telefono),
                const Divider(),
                _buildDetailRow('ID:', user['id'] as String? ?? 'Desconocido'),
                const Divider(),
                _buildDetailRow('Rol:', rol.toUpperCase(),
                    valueColor:
                        rol == 'admin' ? Colors.purple : AppColors.navy),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('CERRAR',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.grey.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
      child: Row(
        children: [
          const Icon(Icons.people_alt_rounded, color: AppColors.navy),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gestión de Usuarios',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy)),
              Text('$count usuarios',
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
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o email...',
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
    var users = state.users;

    final filtered = users.where((u) {
      final q = _searchQuery.toLowerCase();
      final n = (u['nombre'] ?? '').toString().toLowerCase();
      final a = (u['apellidos'] ?? '').toString().toLowerCase();
      final e = (u['email'] ?? '').toString().toLowerCase();
      return n.contains(q) || a.contains(q) || e.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          _buildHeader(filtered.length, state.isLoading),
          _buildActions(),
          Expanded(
            child: state.isLoading && users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('No se encontraron usuarios',
                                style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final user = filtered[i];
                          return UserCard(
                            user: user,
                            onTap: () => _showUserDetails(user),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
