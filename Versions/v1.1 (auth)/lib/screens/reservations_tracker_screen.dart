import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/reservation.dart';
import '../providers/providers.dart';

/// Screen 3: Reservations Tracker Screen.
/// Design defense context:
/// - Designated CRUD Domain for academic rubric requirements.
/// - READ: Subscribes to [userReservationsStreamProvider] for real-time status.
/// - UPDATE: Modifies quantity via a dialog, completes status, or cancels reservation (refunding stock).
/// - DELETE: Deletes logs entirely from the local records.
/// - Uses a TabController to separate Active (Pending) and Archive (Completed/Cancelled) sections.
class ReservationsTrackerScreen extends ConsumerWidget {
  const ReservationsTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(userReservationsStreamProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reservations Tracker'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Active Claims', icon: Icon(Icons.bookmark_added)),
              Tab(text: 'History Log', icon: Icon(Icons.history)),
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
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (err, stack) => Center(
            child: Text('Error loading reservations: $err', style: const TextStyle(color: AppColors.accent)),
          ),
        ),
      ),
    );
  }

  /// Builds the scrollable list of reservations.
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
              isActiveTab ? Icons.no_sim_outlined : Icons.history_toggle_off,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isActiveTab ? 'No active claims at this moment.' : 'Your history is currently empty.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildReservationCard(context, ref, list[index], isActiveTab);
      },
    );
  }

  /// Builds individual reservation item card.
  Widget _buildReservationCard(
    BuildContext context,
    WidgetRef ref,
    Reservation reservation,
    bool isActive,
  ) {
    final item = reservation.foodItem;
    if (item == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Business Name & Status Badge.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.businessName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondary),
                ),
                _buildStatusBadge(reservation.status),
              ],
            ),
            const SizedBox(height: 12),
            // Item Info.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: AppColors.background,
                      child: const Icon(Icons.broken_image, color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantity: ${reservation.reservedQuantity} portion(s)',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total Paid: \$${(item.discountedPrice * reservation.reservedQuantity).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            // Footer Info: Pickup Code & Expiration.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PICKUP PIN', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text(
                      reservation.pickupCode,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 1.0),
                    ),
                  ],
                ),
                Text(
                  'Pickup window:\n${item.pickupWindow}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  textAlign: Alignment.centerRight as TextAlign?,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Actions Row.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isActive) ...[
                  // CRUD operations for active items.
                  OutlinedButton.icon(
                    onPressed: () => _showEditQuantityDialog(context, ref, reservation),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit Qty'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _confirmAction(
                      context,
                      title: 'Cancel Reservation?',
                      content: 'Are you sure you want to cancel this booking? Stock will be returned to the store.',
                      onConfirm: () => ref.read(reservationsControllerProvider.notifier).cancelClaim(reservation.id),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _confirmAction(
                      context,
                      title: 'Complete Pickup?',
                      content: 'Confirm you have picked up the food from the retailer.',
                      onConfirm: () => ref.read(reservationsControllerProvider.notifier).completeClaim(reservation.id),
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Pick Up'),
                  ),
                ] else ...[
                  // CRUD deletion for historical logs.
                  TextButton.icon(
                    onPressed: () => _confirmAction(
                      context,
                      title: 'Delete History Record?',
                      content: 'Remove this reservation log from your device history permanently?',
                      onConfirm: () => ref.read(reservationsControllerProvider.notifier).deleteRecord(reservation.id),
                    ),
                    icon: const Icon(Icons.delete_forever, size: 16),
                    label: const Text('Delete Log'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget to render status labels cleanly.
  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'pending':
        bg = AppColors.secondary.withOpacity(0.15);
        fg = AppColors.secondary;
        label = 'PENDING';
        break;
      case 'completed':
        bg = AppColors.primary.withOpacity(0.15);
        fg = AppColors.primary;
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
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  /// Opens dialog to change quantity. Demonstrates UPDATE CRUD.
  void _showEditQuantityDialog(BuildContext context, WidgetRef ref, Reservation reservation) {
    int localQty = reservation.reservedQuantity;
    final maxAvailable = (reservation.foodItem?.quantity ?? 0) + reservation.reservedQuantity;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Update Reserved Quantity'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Change portion count for ${reservation.foodItem?.name ?? ""}.',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 32),
                        onPressed: localQty > 1 ? () => setState(() => localQty--) : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('$localQty', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 32),
                        onPressed: localQty < maxAvailable
                            ? () => setState(() => localQty++)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Max portions available: $maxAvailable',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await ref
                        .read(reservationsControllerProvider.notifier)
                        .updateQuantity(reservation.id, localQty);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Opens a quick verification dialog before executing writing state changes.
  void _confirmAction(
    BuildContext context, {
    required String title,
    required String content,
    required Future<void> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await onConfirm();
            },
            child: const Text('Yes, Confirm'),
          ),
        ],
      ),
    );
  }
}
