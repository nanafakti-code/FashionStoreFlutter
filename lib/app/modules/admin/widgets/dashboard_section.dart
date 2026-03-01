import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

class DashboardSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final List<Widget>? actions;

  const DashboardSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[50]!,
                  Colors.grey[100]!,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: const Border(
                bottom: BorderSide(color: AppColors.grey200),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.grey600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(0),
            child: child,
          ),
        ],
      ),
    );
  }
}
