import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/reservation_model.dart';
import '../providers/database_providers.dart';
import 'reservation_details_screen.dart';

class ReservationsScreen extends ConsumerWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeReservationsStreamProvider);
    final pastAsync = ref.watch(pastReservationsStreamProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'My Rescues',
            style: TextStyle(
              fontFamily: 'Epilogue',
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.outline,
            labelStyle: TextStyle(fontFamily: 'Work Sans', fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: TextStyle(fontFamily: 'Work Sans', fontSize: 13),
            tabs: [
              Tab(text: 'Active Claims', icon: Icon(Icons.bookmark_added_outlined)),
              Tab(text: 'History Log', icon: Icon(Icons.history_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            activeAsync.when(
              data: (list) => _buildReservationList(context, ref, list, isActiveTab: true),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
            ),
            pastAsync.when(
              data: (list) => _buildReservationList(context, ref, list, isActiveTab: false),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationList(
    BuildContext context,
    WidgetRef ref,
    List<ReservationModel> list, {
    required bool isActiveTab,
  }) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActiveTab ? Icons.shopping_bag_outlined : Icons.history_toggle_off_outlined,
              size: 64,
              color: AppColors.outline.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              isActiveTab
                  ? 'No active claims at the moment.\nRescue some food!'
                  : 'Your rescue history is empty.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Work Sans',
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildReservationCard(context, ref, list[index]);
      },
    );
  }

  Widget _buildReservationCard(
    BuildContext context,
    WidgetRef ref,
    ReservationModel reservation,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReservationDetailsScreen(reservation: reservation),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food item image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  reservation.storeImageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.outlineVariant,
                    child: const Icon(Icons.broken_image, color: AppColors.outline),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            reservation.storeName,
                            style: const TextStyle(
                              fontFamily: 'Work Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.outline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(reservation.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reservation Box',
                      style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Qty: ${reservation.quantity} portion(s)',
                      style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total Paid: \$${reservation.totalPaid.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'active':
        bg = AppColors.primary.withAlpha(38);
        fg = AppColors.textPrimary;
        label = 'ACTIVE';
        break;
      case 'past':
        bg = AppColors.impactGreen.withAlpha(38);
        fg = AppColors.impactGreen;
        label = 'PAST';
        break;
      default:
        bg = AppColors.accent.withAlpha(38);
        fg = AppColors.accent;
        label = status.toUpperCase();
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Work Sans',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
