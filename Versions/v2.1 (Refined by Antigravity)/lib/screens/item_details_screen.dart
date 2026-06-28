import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/listing_model.dart';
import '../providers/database_providers.dart';
import 'reservation_confirmation_screen.dart';

class ItemDetailsScreen extends ConsumerStatefulWidget {
  final ListingModel item;

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
                // Image Header with back button
                // 1:1 Layout Hero Section Stack with chevron controls & overlapping Freshness Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: 350,
                      width: double.infinity,
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AppColors.outlineVariant),
                      ),
                    ),
                    // Back button with transparent blur background
                    Positioned(
                      top: 40,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withAlpha(204),
                        radius: 22,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    // Left swipe button
                    Positioned(
                      left: 16,
                      top: 175 - 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withAlpha(51),
                        radius: 20,
                        child: const Icon(Icons.chevron_left, color: Colors.white),
                      ),
                    ),
                    // Right swipe button
                    Positioned(
                      right: 16,
                      top: 175 - 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withAlpha(51),
                        radius: 20,
                        child: const Icon(Icons.chevron_right, color: Colors.white),
                      ),
                    ),
                    // Freshness Badge (Overlapping at bottom right)
                    Positioned(
                      bottom: -20,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule, size: 16, color: AppColors.onPrimary),
                            const SizedBox(width: 6),
                            Text(
                              'Pickup: ${item.pickupWindow}',
                              style: const TextStyle(
                                fontFamily: 'Work Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 36.0, 24.0, 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restructured Header to match HTML 1:1
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    fontFamily: 'Epilogue',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.outlineVariant.withAlpha(50),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.storefront, size: 12, color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            item.category,
                                            style: const TextStyle(
                                              fontFamily: 'Work Sans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.outlineVariant.withAlpha(50),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.eco, size: 12, color: AppColors.textSecondary),
                                          SizedBox(width: 4),
                                          Text(
                                            'Vegetarian',
                                            style: TextStyle(
                                              fontFamily: 'Work Sans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${item.discountedPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Epilogue',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                '\$${item.originalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Work Sans',
                                  fontSize: 14,
                                  color: AppColors.outline,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Only ${item.itemsRemaining} left!',
                                style: const TextStyle(
                                  fontFamily: 'Work Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sunrise Bakery · ${item.distance} away',
                        style: const TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 14,
                          color: AppColors.outline,
                        ),
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
                              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
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
                        'Store coordinates: (${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}) · ${item.distance} away',
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
                onPressed: item.itemsRemaining > 0 ? _openBookingModal : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  item.itemsRemaining > 0 ? 'RESERVE NOW' : 'OUT OF STOCK',
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
  final ListingModel item;

  const _BookingModalContent({required this.item});

  @override
  ConsumerState<_BookingModalContent> createState() => _BookingModalContentState();
}

class _BookingModalContentState extends ConsumerState<_BookingModalContent> {
  int _quantity = 1;
  String _selectedTimeSlot = '';
  bool _bringOwnContainer = false;
  double _tipAmount = 0.00;
  int _selectedWheelIndex = 0;
  bool _isCustomTipSelected = false;
  
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customTipController = TextEditingController();
  late final FixedExtentScrollController _wheelController;
  
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
      _timeSlots = ['6:00 PM', '6:30 PM', '7:00 PM', '7:30 PM', '8:00 PM'];
    }
    _selectedTimeSlot = _timeSlots.first;
    _wheelController = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customTipController.dispose();
    _wheelController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    return (widget.item.discountedPrice * _quantity) + _tipAmount;
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(firestoreReservationsControllerProvider);
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
                  'Complete Your Reservation',
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
                      color: _quantity < widget.item.itemsRemaining ? AppColors.primary : AppColors.outline,
                      onPressed: _quantity < widget.item.itemsRemaining ? () => setState(() => _quantity++) : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Native time wheel selector
            const Text(
              'Select Pickup Time (Scroll Wheel)',
              style: TextStyle(fontFamily: 'Work Sans', fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: ListWheelScrollView.useDelegate(
                controller: _wheelController,
                itemExtent: 38,
                physics: const FixedExtentScrollPhysics(),
                perspective: 0.005,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedWheelIndex = index;
                    _selectedTimeSlot = _timeSlots[index];
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: _timeSlots.length,
                  builder: (context, index) {
                    final isSelected = index == _selectedWheelIndex;
                    return Center(
                      child: Text(
                        _timeSlots[index],
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
              'Add a Tip',
              style: TextStyle(fontFamily: 'Work Sans', fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildTipChip(1.00, '\$1'),
                  const SizedBox(width: 8),
                  _buildTipChip(2.00, '\$2'),
                  const SizedBox(width: 8),
                  _buildTipChip(5.00, '\$5'),
                  const SizedBox(width: 8),
                  _buildTipChip(10.00, '\$10'),
                  const SizedBox(width: 8),
                  _buildCustomTipChip(),
                ],
              ),
            ),
            if (_isCustomTipSelected) ...[
              const SizedBox(height: 12),
              Container(
                height: 44,
                child: TextField(
                  controller: _customTipController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Enter custom tip amount in \$',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) {
                    final custom = double.tryParse(val) ?? 0.00;
                    setState(() {
                      _tipAmount = custom;
                    });
                  },
                ),
              ),
            ],
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
              decoration: InputDecoration(
                hintText: 'E.g., "Arriving near closing time", "Allergic to dairy"',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                      final reservation = await ref
                          .read(firestoreReservationsControllerProvider.notifier)
                          .reserveItem(
                            widget.item,
                            _quantity,
                            pickupTime: _selectedTimeSlot,
                            byoContainer: _bringOwnContainer,
                            userNotes: _notesController.text,
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
                        final error = ref.read(firestoreReservationsControllerProvider).error;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reservation failed: ${error ?? "Unknown error"}'),
                            backgroundColor: AppColors.accent,
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
    final isSelected = _tipAmount == amount && !_isCustomTipSelected;
    return ChoiceChip(
      label: Text(label),
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
          setState(() {
            _tipAmount = amount;
            _isCustomTipSelected = false;
            _customTipController.clear();
          });
        }
      },
    );
  }

  Widget _buildCustomTipChip() {
    final isSelected = _isCustomTipSelected;
    return ChoiceChip(
      label: const Text('Custom'),
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
        setState(() {
          _isCustomTipSelected = selected;
          if (selected) {
            _tipAmount = 0.00;
          } else {
            _tipAmount = 0.00;
            _customTipController.clear();
          }
        });
      },
    );
  }
}
