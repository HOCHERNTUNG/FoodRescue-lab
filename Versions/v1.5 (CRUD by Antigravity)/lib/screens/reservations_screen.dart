import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/reservation.dart';
import '../providers/providers.dart';
import 'reservation_details_screen.dart';

class ReservationsScreen extends ConsumerWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(userReservationsStreamProvider);

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
        body: reservationsAsync.when(
          data: (reservations) {
            final active = reservations.where((r) => r.status == 'pending').toList();
            final history = reservations.where((r) => r.status != 'pending').toList();

            return TabBarView(
              children: [
                _buildReservationList(context, ref, active, isActiveTab: true),
                _buildReservationList(context, ref, history, isActiveTab: false),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Error loading reservations: $err',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReservationList(
    BuildContext context,
    WidgetRef ref,
    List<Reservation> list, {
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
              color: AppColors.outline.withOpacity(0.5),
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
    Reservation reservation,
  ) {
    final item = reservation.foodItem;
    if (item == null) return const SizedBox.shrink();

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
                  item.imageUrl,
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
                        Text(
                          item.businessName,
                          style: const TextStyle(
                            fontFamily: 'Work Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.outline,
                          ),
                        ),
                        _buildStatusBadge(reservation.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
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
                      'Qty: ${reservation.reservedQuantity} portion(s)',
                      style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total: \$${reservation.amountPaid.toStringAsFixed(2)}',
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
      case 'pending':
        bg = AppColors.primary.withOpacity(0.15);
        fg = AppColors.textPrimary;
        label = 'PENDING';
        break;
      case 'completed':
        bg = AppColors.impactGreen.withOpacity(0.15);
        fg = AppColors.impactGreen;
        label = 'COMPLETED';
        break;
      case 'cancelled':
      default:
        bg = AppColors.accent.withOpacity(0.15);
        fg = AppColors.accent;
        label = 'CANCELLED';
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
