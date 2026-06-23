import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/reservation.dart';
import '../providers/providers.dart';

class ReservationDetailsScreen extends ConsumerStatefulWidget {
  final Reservation reservation;

  const ReservationDetailsScreen({super.key, required this.reservation});

  @override
  ConsumerState<ReservationDetailsScreen> createState() => _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends ConsumerState<ReservationDetailsScreen> {
  late Reservation _currentReservation;

  @override
  void initState() {
    super.initState();
    _currentReservation = widget.reservation;
  }

  // Generate mock time slots based on pickup window or default
  List<String> _getTimeSlots() {
    final window = _currentReservation.foodItem?.pickupWindow ?? '6:00 PM - 8:00 PM';
    // Generate simple slots
    if (window.contains('-')) {
      final parts = window.split('-');
      final start = parts[0].trim();
      final end = parts[1].trim();
      return [start, 'In Between', end];
    }
    return ['6:00 PM', '6:30 PM', '7:00 PM', '7:30 PM', '8:00 PM'];
  }

  void _showUpdateTimingModal() {
    final slots = _getTimeSlots();
    String selectedSlot = _currentReservation.scheduledTime.isNotEmpty 
        ? _currentReservation.scheduledTime 
        : slots.first;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Select New Pickup Timing',
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pickup Window: ${_currentReservation.foodItem?.pickupWindow ?? ""}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: slots.map((slot) {
                      final isSelected = selectedSlot == slot;
                      return ChoiceChip(
                        label: Text(
                          slot,
                          style: TextStyle(
                            fontFamily: 'Work Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => selectedSlot = slot);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await ref
                          .read(reservationsControllerProvider.notifier)
                          .updatePickupTime(_currentReservation.id, selectedSlot);
                      
                      setState(() {
                        _currentReservation = _currentReservation.copyWith(scheduledTime: selectedSlot);
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pickup timing updated to $selectedSlot!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    },
                    child: const Text('Update Timing'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmCancellation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Cancel Reservation?'),
        content: const Text(
          'Are you sure you want to cancel this booking? Stock will be refunded, and this order will be set to Cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Booking', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(reservationsControllerProvider.notifier)
                  .cancelClaim(_currentReservation.id);

              setState(() {
                _currentReservation = _currentReservation.copyWith(status: 'cancelled');
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reservation cancelled successfully.'),
                    backgroundColor: AppColors.accent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _currentReservation.foodItem;
    if (item == null) return const Scaffold(body: Center(child: Text('Error: Listing not found.')));

    final isPending = _currentReservation.status == 'pending';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Rescue Ticket Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Merchant & Item Info
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: AppColors.outlineVariant),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.businessName,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.outline),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quantity: ${_currentReservation.reservedQuantity} portion(s)',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // NETS QR Code grading section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineVariant, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade900,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NETS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Scan QR at Store to Pay/Redeem',
                        style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Visual QR representation
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: _currentReservation.status == 'pending'
                        ? const Icon(Icons.qr_code_2_rounded, size: 190, color: AppColors.textPrimary)
                        : _currentReservation.status == 'completed'
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, size: 80, color: AppColors.impactGreen),
                                  SizedBox(height: 12),
                                  Text(
                                    'CLAIMED & PAID',
                                    style: TextStyle(
                                      fontFamily: 'Work Sans',
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.impactGreen,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cancel, size: 80, color: AppColors.accent),
                                  SizedBox(height: 12),
                                  Text(
                                    'CANCELLED',
                                    style: TextStyle(
                                      fontFamily: 'Work Sans',
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'RESERVATION ID: ${_currentReservation.id.toUpperCase()}',
                    style: const TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pickup Pin: ${_currentReservation.pickupCode}',
                    style: const TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order specifications
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rescuer Specifications',
                      style: TextStyle(fontFamily: 'Epilogue', fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    _buildSpecRow(
                      'Scheduled Pickup',
                      _currentReservation.scheduledTime.isNotEmpty 
                          ? _currentReservation.scheduledTime 
                          : 'Not Selected',
                    ),
                    _buildSpecRow('BYO Container Incentive', _currentReservation.bringOwnContainer ? 'Yes (+10 Points)' : 'No'),
                    _buildSpecRow('Pickup Notes', _currentReservation.pickupNotes.isNotEmpty ? _currentReservation.pickupNotes : 'None'),
                    _buildSpecRow('Merchant Tip', '\$${_currentReservation.tipAmount.toStringAsFixed(2)}'),
                    const Divider(color: AppColors.border),
                    _buildSpecRow(
                      'Total Amount Paid', 
                      '\$${_currentReservation.amountPaid.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (isPending) ...[
              ElevatedButton.icon(
                onPressed: _showUpdateTimingModal,
                icon: const Icon(Icons.edit_calendar),
                label: const Text('Update Pickup Timing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _confirmCancellation,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Reservation'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ] else ...[
              Center(
                child: Text(
                  _currentReservation.status == 'completed' 
                      ? 'This rescue was completed on ${_currentReservation.completedAt != null ? _currentReservation.completedAt!.toLocal().toString().substring(0, 16) : "Date N/A"}.'
                      : 'This rescue has been cancelled.',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.outline),
                ),
              )
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: isBold ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
