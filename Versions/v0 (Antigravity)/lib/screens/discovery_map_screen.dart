import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/food_item.dart';
import '../providers/providers.dart';

/// Screen 2: Discovery Map Screen.
/// Design defense context:
/// - Uses the open-source [flutter_map] library instead of google_maps_flutter.
/// - Obtains food listing locations in real-time from [foodItemsStreamProvider].
/// - Displays map pins styled as custom icons indicating business type.
/// - Selecting a pin opens an elegant details overlay at the bottom with a quick reserve button.
class DiscoveryMapScreen extends ConsumerStatefulWidget {
  const DiscoveryMapScreen({super.key});

  @override
  ConsumerState<DiscoveryMapScreen> createState() => _DiscoveryMapScreenState();
}

class _DiscoveryMapScreenState extends ConsumerState<DiscoveryMapScreen> {
  final MapController _mapController = MapController();
  FoodItem? _selectedItem;

  // Set default center point in San Francisco, aligning with mock repository coordinates.
  final LatLng _sfCenter = const LatLng(37.7749, -122.4194);

  @override
  Widget build(BuildContext context) {
    final foodItemsAsync = ref.watch(foodItemsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rescue Map Discovery'),
      ),
      body: foodItemsAsync.when(
        data: (items) {
          final markers = items.map((item) => _buildMarker(item)).toList();

          return Stack(
            children: [
              // Open-source Flutter Map.
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _sfCenter,
                  initialZoom: 13.0,
                  onTap: (_, __) {
                    setState(() {
                      _selectedItem = null;
                    });
                  },
                ),
                children: [
                  // Open-source OpenStreetMap tiles.
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.foodrescue.lab',
                    // Adding dark tint to OpenStreetMap tiles to match our dark theme.
                    tileBuilder: (context, tileWidget, tile) {
                      return ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          -0.2126, -0.7152, -0.0722,  0, 255, // Red
                          -0.2126, -0.7152, -0.0722,  0, 255, // Green
                          -0.2126, -0.7152, -0.0722,  0, 255, // Blue
                            0,       0,       0,      1,   0, // Alpha
                        ]),
                        child: tileWidget,
                      );
                    },
                  ),
                  // Render interactive marker pins.
                  MarkerLayer(markers: markers),
                ],
              ),

              // Selected Listing Bottom Card Overlay.
              if (_selectedItem != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: _buildDetailsCard(_selectedItem!),
                ),

              // Recenter map button.
              Positioned(
                right: 16,
                top: 16,
                child: FloatingActionButton.small(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primary,
                  onPressed: () {
                    _mapController.move(_sfCenter, 13.0);
                    setState(() {
                      _selectedItem = null;
                    });
                  },
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text('Map Error: $err', style: const TextStyle(color: AppColors.accent)),
        ),
      ),
    );
  }

  /// Builds a customized marker representing a rescue location.
  Marker _buildMarker(FoodItem item) {
    final bool isSelected = _selectedItem?.id == item.id;
    final bool outOfStock = item.quantity <= 0;

    return Marker(
      point: LatLng(item.latitude, item.longitude),
      width: isSelected ? 55.0 : 45.0,
      height: isSelected ? 55.0 : 45.0,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedItem = item;
          });
          _mapController.move(LatLng(item.latitude, item.longitude), 14.0);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: outOfStock
                ? AppColors.textSecondary.withOpacity(0.9)
                : (isSelected ? AppColors.primary : AppColors.secondary),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            _getCategoryIcon(item.category),
            color: Colors.white,
            size: isSelected ? 26.0 : 20.0,
          ),
        ),
      ),
    );
  }

  /// Map categories to appropriate icons.
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Meals':
        return Icons.restaurant_menu;
      case 'Bakery':
        return Icons.bakery_dining;
      case 'Groceries':
        return Icons.local_grocery_store;
      case 'Produce':
        return Icons.agriculture;
      default:
        return Icons.fastfood;
    }
  }

  /// Builds the detail popup card for selected items.
  Widget _buildDetailsCard(FoodItem item) {
    final bool outOfStock = item.quantity <= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.businessName,
                        style: const TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                  onPressed: () => setState(() => _selectedItem = null),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '\$${item.discountedPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${item.originalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                Text(
                  outOfStock ? 'Rescue complete' : '${item.quantity} portions left',
                  style: TextStyle(
                    fontSize: 13,
                    color: outOfStock ? AppColors.accent : AppColors.textSecondary,
                    fontWeight: outOfStock ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Pickup: ${item.pickupWindow}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: outOfStock ? null : () => _showQuickReserveSheet(item),
                child: const Text('Quick Reserve'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the reservation sheet from the map view.
  void _showQuickReserveSheet(FoodItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _QuickReserveSheetContent(item: item);
      },
    );
  }
}

/// Helper container inside bottom sheet to manage local count.
class _QuickReserveSheetContent extends ConsumerStatefulWidget {
  final FoodItem item;
  const _QuickReserveSheetContent({required this.item});

  @override
  ConsumerState<_QuickReserveSheetContent> createState() => _QuickReserveSheetContentState();
}

class _QuickReserveSheetContentState extends ConsumerState<_QuickReserveSheetContent> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(reservationsControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.businessName,
                      style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  ),
                  Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _quantity < widget.item.quantity ? () => setState(() => _quantity++) : null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Price', style: TextStyle(color: AppColors.textSecondary)),
              Text(
                '\$${(widget.item.discountedPrice * _quantity).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    final success = await ref
                        .read(reservationsControllerProvider.notifier)
                        .reserveItem(widget.item, _quantity);
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Successfully reserved $_quantity portion(s)!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Confirm Reservation'),
          ),
        ],
      ),
    );
  }
}
