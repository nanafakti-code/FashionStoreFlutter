import 'package:flutter/material.dart';
import '../../../../../config/theme/app_colors.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;

  const UserCard({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nombre = user['nombre'] as String?;
    final apellidos = user['apellidos'] as String?;
    final email = user['email'] as String? ?? 'Sin email';
    final rol = user['rol'] as String? ?? 'user';

    final nombreCompleto = (nombre == null && apellidos == null)
        ? email
        : '${nombre ?? ''} ${apellidos ?? ''}'.trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.navy.withOpacity(0.1),
                radius: 20,
                child: Text(
                  nombreCompleto.isNotEmpty
                      ? nombreCompleto[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                      color: AppColors.navy, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreCompleto,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildRoleBadge(rol),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String rol) {
    Color bg;
    Color text;
    if (rol == 'admin') {
      bg = Colors.purple.shade50;
      text = Colors.purple.shade700;
    } else {
      bg = Colors.blue.shade50;
      text = Colors.blue.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: text.withOpacity(0.3)),
      ),
      child: Text(
        rol.toUpperCase(),
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
