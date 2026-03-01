import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../routes/app_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomFashionAppBar(
        title: 'Mi Perfil',
        showBackButton: true,
      ),
      body: Builder(builder: (context) {
        if (user == null) return _buildNotLoggedIn(context);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              _buildAvatar(user.nombre ?? '', user.email),
              const SizedBox(height: 40),

              // SECTION: MI CUENTA
              _sectionTitle('MI CUENTA'),
              const SizedBox(height: 12),
              _menuTile(context, Icons.person_outline, 'INFORMACIÓN PERSONAL',
                  () => context.push(AppRoutes.personalInfo)),
              _menuTile(context, Icons.shopping_bag_outlined, 'MIS PEDIDOS',
                  () => context.push(AppRoutes.orders)),
              _menuTile(context, Icons.assignment_return_outlined,
                  'MIS DEVOLUCIONES', () => context.push(AppRoutes.returns)),
              _menuTile(context, Icons.location_on_outlined, 'MIS DIRECCIONES',
                  () => context.push(AppRoutes.addresses)),
              _menuTile(context, Icons.star_outline, 'MIS RESEÑAS',
                  () => context.push(AppRoutes.reviews)),
              _menuTile(context, Icons.discount_outlined, 'MIS CUPONES',
                  () => context.push(AppRoutes.coupons)),

              const SizedBox(height: 32),

              // SECTION: SEGURIDAD
              _sectionTitle('SEGURIDAD'),
              const SizedBox(height: 12),
              _menuTile(context, Icons.lock_outline, 'CAMBIAR CONTRASEÑA',
                  () => context.push(AppRoutes.changePassword)),

              const SizedBox(height: 40),

              if (user.rol == 'admin') ...[
                _sectionTitle('ADMINISTRACIÓN'),
                const SizedBox(height: 12),
                _menuTile(
                    context,
                    Icons.admin_panel_settings_outlined,
                    'Panel de Administración',
                    () => context.push(AppRoutes.adminDashboard),
                    color: AppColors.navy),
                const SizedBox(height: 16),
              ],

              _buildLogoutButton(context, ref),
              const SizedBox(height: 40),

              Center(
                child: GestureDetector(
                  onLongPress: () => context.push(AppRoutes.adminLogin),
                  child: Text(
                    'v1.1.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _menuTile(
      BuildContext context, IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.greyLight.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.charcoal),
        title: Text(title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.charcoal)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await ref.read(authNotifierProvider.notifier).logout();
          if (context.mounted) context.go(AppRoutes.home);
        },
        icon: const Icon(Icons.logout, color: Colors.white, size: 20),
        label: const Text('CERRAR SESIÓN',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade400,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline,
              size: 80, color: AppColors.greyLight),
          const SizedBox(height: 16),
          const Text('Inicia sesión para ver tu perfil'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push(AppRoutes.login),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Iniciar Sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String nombre, String email) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.navy,
            child: Text(
              (nombre.isNotEmpty ? nombre[0] : 'U').toUpperCase(),
              style: const TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(nombre,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(email, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
