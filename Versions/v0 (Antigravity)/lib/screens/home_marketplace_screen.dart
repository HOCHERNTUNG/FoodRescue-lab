import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/food_item.dart';
import '../providers/providers.dart';

/// Screen 1: Home Marketplace Screen.
/// Design defense context:
/// - Subscribes to [foodItemsStreamProvider] for real-time surplus food listings.
/// - Features a category filtering row ("All", "Meals", "Bakery", "Groceries", "Produce").
/// - Launches a detailed bottom sheet to reserve items, initiating the CRUD lifecycle.
class HomeMarketplaceScreen extends ConsumerStatefulWidget {
  const HomeMarketplaceScreen({super.key});

  @override
  ConsumerState<HomeMarketplaceScreen> createState() => _HomeMarketplaceScreenState();
}

class _HomeMarketplaceScreenState extends ConsumerState<HomeMarketplaceScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final foodItemsAsync = ref.watch(foodItemsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodRescue Marketplace'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: _buildCategoryFilters(),
        ),
      ),
      body: foodItemsAsync.when(
        data: (items) {
          // Filter items based on selected category.
          final filteredItems = _selectedCategory == 'All'
              ? items
              : items.where((item) => item.category == _selectedCategory).toList();

          if (filteredItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_food_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No listings available in this category.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              return _buildFoodItemCard(filteredItems[index]);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text('Error loading marketplace: $err', style: const TextStyle(color: AppColors.accent)),
        ),
      ),
    );
  }

  /// Builds horizontal scrollable category selection chips.
  Widget _buildCategoryFilters() {
    final categories = ['All', 'Meals', 'Bakery', 'Groceries', 'Produce'];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  /// Builds a food item card.
  Widget _buildFoodItemCard(FoodItem item) {
    final bool outOfStock = item.quantity <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image with discounts & category tags.
          Stack(
            children: [
              Image.network(
                item.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: AppColors.surface,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined, size: 48, color: AppColors.textSecondary),
                ),
              ),
              // Category tag.
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Text(
                    item.category,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              ),
              // Discount percentage tag.
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.discountPercentage}% OFF',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              // Out of Stock Overlay.
              if (outOfStock)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        border: Border.all(color: AppColors.accent, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'RESCUED / OUT OF STOCK',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Food details description.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Price tag.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${item.discountedPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
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
                  ],
                ),
                Text(
                  item.businessName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.secondary),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 12),
                // Footer metadata & action.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              item.pickupWindow,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              outOfStock ? 'None remaining' : '${item.quantity} portions left',
                              style: TextStyle(
                                fontSize: 12,
                                color: outOfStock ? AppColors.accent : AppColors.textSecondary,
                                fontWeight: outOfStock ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: outOfStock ? null : () => _showReservationSheet(context, item),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text('Reserve'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the reservation quantity and booking selection bottom sheet.
  void _showReservationSheet(BuildContext context, FoodItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _ReservationSheetContent(item: item);
      },
    );
  }
}

/// Dynamic content within the reservation modal to isolate local quantity state.
class _ReservationSheetContent extends ConsumerStatefulWidget {
  final FoodItem item;

  const _ReservationSheetContent({required this.item});

  @override
  ConsumerState<_ReservationSheetContent> createState() => _ReservationSheetContentState();
}

class _ReservationSheetContentState extends ConsumerState<_ReservationSheetContent> {
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
          const Divider(color: AppColors.border),
          const SizedBox(height: 20),
          // Quantity selector widget.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Quantity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 28),
                    color: _quantity > 1 ? AppColors.primary : AppColors.textSecondary,
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 28),
                    color: _quantity < widget.item.quantity ? AppColors.primary : AppColors.textSecondary,
                    onPressed: _quantity < widget.item.quantity
                        ? () => setState(() => _quantity++)
                        : null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Order summary.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              Text(
                '\$${(widget.item.discountedPrice * _quantity).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Action Button.
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
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('Successfully reserved $_quantity portion(s)!'),
                            ],
                          ),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else if (context.mounted) {
                      // Handle failure.
                      final error = ref.read(reservationsControllerProvider).error;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reservation failed: ${error ?? "Unknown error"}'),
                          backgroundColor: AppColors.accent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Confirm Reservation'),
          ),
        ],
      ),
    );
  }
}
