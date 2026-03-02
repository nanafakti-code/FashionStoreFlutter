import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../providers/admin_provider.dart';
import 'widgets/create_campaign_form.dart';

class AdminMarketingScreen extends ConsumerStatefulWidget {
  const AdminMarketingScreen({super.key});

  @override
  ConsumerState<AdminMarketingScreen> createState() =>
      _AdminMarketingScreenState();
}

class _AdminMarketingScreenState extends ConsumerState<AdminMarketingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminNotifierProvider);

    return Column(
      children: [
        _buildHeader(),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.grey500,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Campañas'),
            Tab(text: 'Suscriptores'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCampaignsTab(state),
              _buildSubscribersTab(state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
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
          const Icon(Icons.campaign_rounded, color: AppColors.navy),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gestión de Campañas',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy)),
              const Text('Crea y envía newsletters a tus suscriptores',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignsTab(AdminState state) {
    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    final campaigns = state.campaigns;
    final activeSubscribers = state.subscribers.where((s) => s.activo).length;
    final totalCampaigns = campaigns.length;
    final sentCampaigns = campaigns.where((c) => c.estado == 'Enviada').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const CreateCampaignForm(),
              );
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Nueva campaña',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildStatCard('SUSCRIPTORES ACTIVOS', activeSubscribers.toString(),
              Icons.person_outline),
          const SizedBox(height: AppSpacing.md),
          _buildStatCard('TOTAL CAMPAÑAS', totalCampaigns.toString(),
              Icons.list_alt_rounded),
          const SizedBox(height: AppSpacing.md),
          _buildStatCard(
              'ENVIADAS', sentCampaigns.toString(), Icons.check_rounded,
              iconColor: AppColors.primary),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Campañas creadas',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.navy),
          ),
          const SizedBox(height: AppSpacing.md),
          if (campaigns.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No hay campañas creadas.',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: campaigns.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final c = campaigns[index];
                final isSent = c.estado == 'Enviada';
                final dateStr = c.creadaEn != null
                    ? DateFormat('dd MMM yyyy', 'es_ES').format(c.creadaEn!)
                    : 'Borrador';

                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              c.nombre,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSent
                                  ? AppColors.discountBg
                                  : AppColors.grey200,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                            child: Text(
                              isSent ? 'Enviada' : 'Borrador',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSent
                                    ? AppColors.discountText
                                    : AppColors.grey700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ASUNTO',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textHint,
                                      fontWeight: FontWeight.bold)),
                              Text(c.asunto,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ESTADO ENVÍO',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textHint,
                                      fontWeight: FontWeight.bold)),
                              Text('${c.totalEnviados}/${activeSubscribers}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('FECHA',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textHint,
                                      fontWeight: FontWeight.bold)),
                              Text(dateStr,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: () => ref
                                .read(adminNotifierProvider.notifier)
                                .duplicateCampaign(c.id),
                            icon: const Icon(Icons.copy,
                                size: 16, color: AppColors.purple),
                            label: const Text('Copia',
                                style: TextStyle(color: AppColors.purple)),
                          ),
                          if (!isSent) // Changed from if (isSent) to if (!isSent)
                            TextButton.icon(
                              onPressed: () async {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Enviando campaña...')),
                                );
                                final success = await ref
                                    .read(adminNotifierProvider.notifier)
                                    .sendCampaign(c.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success
                                          ? 'Campaña enviada exitosamente 🎉'
                                          : 'Error al enviar la campaña'),
                                      backgroundColor: success
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.send_rounded,
                                  size: 16, color: AppColors.orange),
                              label: const Text(
                                  'Enviar', // Changed from Reenviar to Enviar
                                  style: TextStyle(color: AppColors.orange)),
                            ),
                          TextButton.icon(
                            onPressed: () => ref
                                .read(adminNotifierProvider.notifier)
                                .deleteCampaign(c.id),
                            icon: const Icon(Icons.delete_outline,
                                size: 16, color: AppColors.error),
                            label: const Text('Borrar',
                                style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSubscribersTab(AdminState state) {
    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    final subscribers = state.subscribers;
    final activeCount = subscribers.where((s) => s.activo).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_outline,
                    color: AppColors.textSecondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                const Text('Suscriptores de Newsletter',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.discountBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    activeCount.toString(),
                    style: const TextStyle(
                        color: AppColors.discountText,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (subscribers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No hay suscriptores aún.',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subscribers.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final sub = subscribers[index];
                final dateStr = sub.createdAt != null
                    ? DateFormat('dd MMM yyyy, HH:mm', 'es_ES')
                        .format(sub.createdAt!)
                    : 'Fecha desconocida';

                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Text('#${index + 1}',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('EMAIL',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textHint,
                                    fontWeight: FontWeight.bold)),
                            Text(sub.email,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 14, color: AppColors.textHint),
                                const SizedBox(width: 4),
                                Text(dateStr,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textHint)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!sub.activo)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.grey200,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: const Text('Baja',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.grey700)),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon,
      {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy)),
            ],
          ),
          Icon(icon, color: iconColor ?? AppColors.grey300, size: 28),
        ],
      ),
    );
  }
}
