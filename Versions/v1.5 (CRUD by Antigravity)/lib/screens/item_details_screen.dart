import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/food_item.dart';
import '../providers/providers.dart';
import 'reservation_confirmation_screen.dart';

class ItemDetailsScreen extends ConsumerStatefulWidget {
  final FoodItem item;

  const ItemDetailsScreen({super.key, required this.item});

  @override
  ConsumerState<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends ConsumerState<ItemDetailsScreen> {
  void _openBookingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _BookingModalContent(item: widget.item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Detailed content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header with gradient overlay
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AppColors.outlineVariant),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ],
                ),
                
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag & Stock Quantity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.category.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Work Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '${item.quantity} Portions Left',
                            style: const TextStyle(
                              fontFamily: 'Work Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Food Item Title
                      Text(
                        item.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // Merchant Name
                      Text(
                        'by ${item.businessName}',
                        style: const TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.outline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Price & Discount Information
                      Row(
                        children: [
                          Text(
                            '\$${item.discountedPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'Work Sans',
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '\$${item.originalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'Work Sans',
                              fontSize: 16,
                              color: AppColors.outline,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.impactGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${item.discountPercentage}% OFF',
                              style: const TextStyle(
                                fontFamily: 'Work Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.impactGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // About this item Description
                      const Text(
                        'About this item',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Static Non-interactive Map Preview
                      const Text(
                        'Pickup Location',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 160,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(item.latitude, item.longitude),
                              initialZoom: 14.5,
                              interactiveFlags: InteractiveFlag.none,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                                subdomains: const ['a', 'b', 'c', 'd'],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(item.latitude, item.longitude),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: AppColors.primary,
                                      size: 35,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Store coordinates: (${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Sticky Bottom Reserve Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(top: BorderSide(color: AppColors.outlineVariant, width: 1)),
              ),
              child: ElevatedButton(
                onPressed: item.quantity > 0 ? _openBookingModal : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  item.quantity > 0 ? 'RESERVE NOW' : 'OUT OF STOCK',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingModalContent extends ConsumerStatefulWidget {
  final FoodItem item;

  const _BookingModalContent({required this.item});

  @override
  ConsumerState<_BookingModalContent> createState() => _BookingModalContentState();
}

class _BookingModalContentState extends ConsumerState<_BookingModalContent> {
  int _quantity = 1;
  String _selectedTimeSlot = '';
  bool _bringOwnContainer = false;
  double _tipAmount = 0.00;
  
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customTipController = TextEditingController();
  
  List<String> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    // Parse time slots from pickup window
    final window = widget.item.pickupWindow;
    if (window.contains('-')) {
      final parts = window.split('-');
      _timeSlots = [parts[0].trim(), 'In Between', parts[1].trim()];
    } else {
      _timeSlots = ['6:00 PM', '6:30 PM', '7:00 PM', '7:30 PM'];
    }
    _selectedTimeSlot = _timeSlots.first;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customTipController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    return (widget.item.discountedPrice * _quantity) + _tipAmount;
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(reservationsControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reserve Food Box',
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

            // Quantity selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Quantity',
                  style: TextStyle(fontFamily: 'Work Sans', fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 28),
                      color: _quantity > 1 ? AppColors.primary : AppColors.outline,
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 28),
                      color: _quantity < widget.item.quantity ? AppColors.primary : AppColors.outline,
                      onPressed: _quantity < widget.item.quantity ? () => setState(() => _quantity++) : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time selector
            const Text(
              'Select Pickup Time',
              style: TextStyle(fontFamily: 'Work Sans', fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _timeSlots.map((slot) {
                final isSelected = _selectedTimeSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.background,
                  labelStyle: TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedTimeSlot = slot);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Bring Own Container Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bring Your Own Container',
                      style: TextStyle(fontFamily: 'Work Sans', fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Earn +10 Eco Points',
                      style: TextStyle(fontSize: 11, color: AppColors.impactGreen, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Switch(
                  value: _bringOwnContainer,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _bringOwnContainer = val),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tips selector
            const Text(
              'Add Merchant Tip (Optional)',
              style: TextStyle(fontFamily: 'Work Sans', fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTipChip(0.00, 'No Tip'),
                const SizedBox(width: 8),
                _buildTipChip(1.00, '\$1.00'),
                const SizedBox(width: 8),
                _buildTipChip(2.00, '\$2.00'),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 38,
                    child: TextField(
                      controller: _customTipController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: 'Custom \$',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onChanged: (val) {
                        final custom = double.tryParse(val) ?? 0.00;
                        setState(() {
                          _tipAmount = custom;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes text field
            const Text(
              'Pickup Notes / Allergy Alerts',
              style: TextStyle(fontFamily: 'Work Sans', fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'E.g., "Arriving near closing time", "Allergic to dairy"',
              ),
            ),
            const SizedBox(height: 24),

            // Total breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grand Total',
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
                Text(
                  '\$${_totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Confirm Booking Button
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final reservation = await ref.read(reservationsControllerProvider.notifier).reserveItem(
                            widget.item,
                            _quantity,
                            scheduledTime: _selectedTimeSlot,
                            bringOwnContainer: _bringOwnContainer,
                            pickupNotes: _notesController.text,
                            tipAmount: _tipAmount,
                          );

                      if (reservation != null && context.mounted) {
                        Navigator.pop(context); // Close bottom sheet
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReservationConfirmationScreen(reservation: reservation),
                          ),
                        );
                      } else if (context.mounted) {
                        final error = ref.read(reservationsControllerProvider).error;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reservation failed: ${error ?? "Unknown error"}'),
                            backgroundColor: AppColors.accent,
                          ),
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                    )
                  : const Text('CONFIRM BOOKING', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipChip(double amount, String label) {
    final isSelected = _tipAmount == amount;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      labelStyle: TextStyle(
        fontFamily: 'Work Sans',
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _tipAmount = amount;
            _customTipController.clear();
          });
        }
      },
    );
  }
}
