import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/reservation_model.dart';
import '../providers/database_providers.dart';

class ReservationDetailsScreen extends ConsumerStatefulWidget {
  final ReservationModel reservation;

  const ReservationDetailsScreen({super.key, required this.reservation});

  @override
  ConsumerState<ReservationDetailsScreen> createState() => _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends ConsumerState<ReservationDetailsScreen> {
  late ReservationModel _currentReservation;

  @override
  void initState() {
    super.initState();
    _currentReservation = widget.reservation;
  }

  void _showFullUpdateModal() {
    int modalQuantity = _currentReservation.quantity;
    String modalTime = _currentReservation.pickupTime;
    bool modalByo = _currentReservation.byoContainer;
    String modalNotes = _currentReservation.userNotes;
    double modalTip = _currentReservation.tipAmount;
    
    // Time options for scrolling wheel
    List<String> timeSlots = ['4:00 PM', '4:30 PM', '5:00 PM', '5:30 PM', '6:00 PM', '6:30 PM', '7:00 PM', '7:30 PM', '8:00 PM'];
    int initialItemIndex = timeSlots.indexOf(modalTime);
    if (initialItemIndex == -1) initialItemIndex = 0;
    
    final FixedExtentScrollController wheelController = FixedExtentScrollController(initialItem: initialItemIndex);
    final TextEditingController notesController = TextEditingController(text: modalNotes);

    bool modalIsCustomTip = modalTip > 0.0 && ![1.0, 2.0, 5.0, 10.0].contains(modalTip);
    final TextEditingController customTipController = TextEditingController(
      text: modalIsCustomTip ? modalTip.toStringAsFixed(2) : '',
    );
    int selectedWheelIndex = initialItemIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double pricePerItem = _currentReservation.quantity > 0 
                ? (_currentReservation.totalPaid - _currentReservation.tipAmount) / _currentReservation.quantity 
                : 4.99;
            double totalPaid = (pricePerItem * modalQuantity) + modalTip;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Update Reservation',
                          style: TextStyle(
                            fontFamily: 'Epilogue',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.outline),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 12),

                    // Store details & Quantity Adjuster
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentReservation.storeName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Price per box: \$${pricePerItem.toStringAsFixed(2)}',
                                style: const TextStyle(color: AppColors.outline, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 28),
                              color: modalQuantity > 1 ? AppColors.primary : AppColors.outline,
                              onPressed: modalQuantity > 1 ? () => setModalState(() => modalQuantity--) : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                '$modalQuantity',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 28),
                              color: AppColors.primary,
                              onPressed: () => setModalState(() => modalQuantity++),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Time scroller wheel
                    const Text(
                      'Update Pickup Time (Scroll Wheel)',
                      style: TextStyle(fontFamily: 'Work Sans', fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: ListWheelScrollView.useDelegate(
                        controller: wheelController,
                        itemExtent: 36,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setModalState(() {
                            selectedWheelIndex = index;
                            modalTime = timeSlots[index];
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: timeSlots.length,
                          builder: (context, index) {
                            final isSelected = index == selectedWheelIndex;
                            return Center(
                              child: Text(
                                timeSlots[index],
                                style: TextStyle(
                                  fontSize: isSelected ? 16 : 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // BYO Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bring Your Own Container',
                              style: TextStyle(fontFamily: 'Work Sans', fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                            ),
                            Text(
                              'Help reduce packaging waste',
                              style: TextStyle(fontSize: 11, color: AppColors.outline),
                            ),
                          ],
                        ),
                        Switch(
                          value: modalByo,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setModalState(() => modalByo = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Special instructions text area
                    const Text(
                      'Special Instructions',
                      style: TextStyle(fontFamily: 'Work Sans', fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Any dietary notes or requests?',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tip adjustments buttons ($1, $2, $5, $10, Custom)
                    const Text(
                      'Adjust Tip',
                      style: TextStyle(fontFamily: 'Work Sans', fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          ...[1.0, 2.0, 5.0, 10.0].map((tip) {
                            final isSelected = modalTip == tip && !modalIsCustomTip;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text('\$${tip.toInt()}'),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.surface,
                                labelStyle: TextStyle(
                                  fontFamily: 'Work Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setModalState(() {
                                      modalTip = tip;
                                      modalIsCustomTip = false;
                                      customTipController.clear();
                                    });
                                  }
                                },
                              ),
                            );
                          }).toList(),
                          ChoiceChip(
                            label: const Text('Custom'),
                            selected: modalIsCustomTip,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            labelStyle: TextStyle(
                              fontFamily: 'Work Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: modalIsCustomTip ? AppColors.onPrimary : AppColors.textSecondary,
                            ),
                            onSelected: (selected) {
                              setModalState(() {
                                modalIsCustomTip = selected;
                                if (selected) {
                                  modalTip = 0.00;
                                } else {
                                  modalTip = 0.00;
                                  customTipController.clear();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (modalIsCustomTip) ...[
                      const SizedBox(height: 12),
                      Container(
                        height: 44,
                        child: TextField(
                          controller: customTipController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Enter custom tip amount in \$',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: (val) {
                            final custom = double.tryParse(val) ?? 0.00;
                            setModalState(() {
                              modalTip = custom;
                            });
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),

                    // Save Changes Button
                    ElevatedButton(
                      onPressed: () async {
                        final newReservation = _currentReservation.copyWith(
                          quantity: modalQuantity,
                          pickupTime: modalTime,
                          byoContainer: modalByo,
                          userNotes: notesController.text,
                          tipAmount: modalTip,
                          totalPaid: totalPaid,
                        );

                        await ref
                            .read(firestoreReservationsControllerProvider.notifier)
                            .updateReservation(_currentReservation, newReservation);

                        setState(() {
                          _currentReservation = newReservation;
                        });

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reservation updated successfully!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      wheelController.dispose();
      notesController.dispose();
      customTipController.dispose();
    });
  }

  void _confirmCancellation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Cancel Reservation?'),
        content: const Text(
          'Are you sure you want to cancel this booking? Stock will be refunded, and this order will be permanently deleted from Firestore.',
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
                  .read(firestoreReservationsControllerProvider.notifier)
                  .cancelReservation(_currentReservation);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reservation cancelled & deleted successfully.'),
                    backgroundColor: AppColors.accent,
                  ),
                );
                Navigator.pop(context); // Go back since record is deleted
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Yes, Cancel & Delete'),
          ),
        ],
      ),
    );
  }

  void _markAsCompleted() async {
    await ref
        .read(firestoreReservationsControllerProvider.notifier)
        .completeReservation(_currentReservation);

    setState(() {
      _currentReservation = _currentReservation.copyWith(status: 'Past');
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation marked as completed and impact updated!'),
          backgroundColor: AppColors.impactGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = _currentReservation.status.toLowerCase() == 'active';

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
            // Status Banner (Tertiary / Alert styling)
            if (isPending)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.textPrimary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ready for Pickup',
                        style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.impactGreen.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.impactGreen, width: 1.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppColors.impactGreen, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Completed / Claimed',
                        style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.bold,
                          color: AppColors.impactGreen,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
                        _currentReservation.storeImageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 70, 
                          height: 70, 
                          color: AppColors.outlineVariant,
                          child: const Icon(Icons.storefront, color: AppColors.outline),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentReservation.storeName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quantity: ${_currentReservation.quantity} portion(s)',
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
                    color: Colors.black.withAlpha(5),
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
                    child: _currentReservation.status.toLowerCase() == 'active'
                        ? const Icon(Icons.qr_code_2_rounded, size: 190, color: AppColors.textPrimary)
                        : const Column(
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

            // Order specifications with 2-column Grid & pricing
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
                    const SizedBox(height: 16),
                    
                    // 2-Column Grid for Timing and Order ID
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PICKUP TIME',
                                style: TextStyle(
                                  fontFamily: 'Work Sans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.outline,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentReservation.pickupTime.isNotEmpty 
                                    ? _currentReservation.pickupTime 
                                    : 'TBD',
                                style: const TextStyle(
                                  fontFamily: 'Work Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ORDER ID',
                                style: TextStyle(
                                  fontFamily: 'Work Sans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.outline,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '#${_currentReservation.id.substring(0, 8).toUpperCase()}',
                                style: const TextStyle(
                                  fontFamily: 'Work Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.outlineVariant, height: 1),
                    const SizedBox(height: 12),

                    _buildSpecRow('BYO Container Incentive', _currentReservation.byoContainer ? 'Yes (+10 Points)' : 'No'),
                    _buildSpecRow('Pickup Notes', _currentReservation.userNotes.isNotEmpty ? _currentReservation.userNotes : 'None'),
                    _buildSpecRow('Merchant Tip', '\$${_currentReservation.tipAmount.toStringAsFixed(2)}'),
                    const Divider(color: AppColors.border),
                    _buildSpecRow(
                      'Total Amount Paid', 
                      '\$${_currentReservation.totalPaid.toStringAsFixed(2)}',
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
                onPressed: _showFullUpdateModal,
                icon: const Icon(Icons.edit, color: Colors.black),
                label: const Text('Update Reservation Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _markAsCompleted,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Simulate Counter Claim & Pay'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.impactGreen,
                  side: const BorderSide(color: AppColors.impactGreen, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _confirmCancellation,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel & Delete Claim'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ] else ...[
              const Center(
                child: Text(
                  'This rescue is fully completed and registered.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.outline),
                ),
              )
            ],
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.textPrimary, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('VIEW ALL RESERVATIONS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
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
