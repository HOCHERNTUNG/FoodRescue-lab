import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/food_item.dart';
import '../providers/providers.dart';

/// Home Marketplace screen refactored to match the Stitch home design.
/// This uses semantic Flutter layout instead of hardcoded positioning.
class HomeMarketplaceScreen extends ConsumerStatefulWidget {
  const HomeMarketplaceScreen({super.key});

  @override
  ConsumerState<HomeMarketplaceScreen> createState() => _HomeMarketplaceScreenState();
}

class _HomeMarketplaceScreenState extends ConsumerState<HomeMarketplaceScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Bakery',
    'Produce',
    'Gourmet',
  ];

  @override
  Widget build(BuildContext context) {
    final foodItemsAsync = ref.watch(foodItemsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'FoodRescue',
          style: TextStyle(
            fontFamily: 'Epilogue',
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surface,
            child: const Icon(Icons.calendar_today, color: AppColors.textPrimary, size: 18),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.surface,
              child: const Icon(Icons.person, color: AppColors.textPrimary, size: 18),
            ),
          ),
        ],
      ),
      body: foodItemsAsync.when(
        data: (items) {
          final filteredItems = _filterItems(items);
          final featuredItem = _getFeaturedItem(filteredItems);
          final forYouItems = _getSectionItems(filteredItems, start: 0, limit: 3);
          final recentlyAddedItems = _getSectionItems(filteredItems, start: 3, limit: 3);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildCategoryChips(),
              const SizedBox(height: 24),
              _buildSectionHeader('For You'),
              const SizedBox(height: 12),
              _buildHorizontalFoodRow(forYouItems),
              const SizedBox(height: 32),
              if (featuredItem != null) ...[
                _buildFeaturedDeal(featuredItem),
                const SizedBox(height: 32),
              ],
              _buildSectionHeader('Recently Added'),
              const SizedBox(height: 12),
              _buildHorizontalFoodRow(recentlyAddedItems),
              const SizedBox(height: 32),
              _buildImpactSection(),
              const SizedBox(height: 24),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stack) => Center(
          child: Text(
            'Error loading marketplace: $error',
            style: const TextStyle(color: AppColors.accent),
          ),
        ),
      ),
    );
  }

  List<FoodItem> _filterItems(List<FoodItem> items) {
    final query = _searchQuery.toLowerCase();
    final categoryMatch = _selectedCategory == 'All';

    return items.where((item) {
      final searchMatch = item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.businessName.toLowerCase().contains(query);
      final categoryFilter = categoryMatch || item.category == _selectedCategory;
      return searchMatch && categoryFilter;
    }).toList();
  }

  FoodItem? _getFeaturedItem(List<FoodItem> items) {
    return items.isNotEmpty ? items.first : null;
  }

  List<FoodItem> _getSectionItems(List<FoodItem> items, {required int start, required int limit}) {
    if (items.length <= start) return [];
    return items.sublist(start, (start + limit).clamp(0, items.length));
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: TextField(
        style: const TextStyle(fontFamily: 'Work Sans', fontSize: 14, color: AppColors.textPrimary),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          hintText: 'Search for surplus meals, bakeries..',
          hintStyle: TextStyle(color: AppColors.outline, fontFamily: 'Work Sans', fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              label: Text(
                category,
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = category);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Epilogue',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildHorizontalFoodRow(List<FoodItem> items) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: const Text(
          'No matching listings yet.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      );
    }

    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 260,
            child: _buildFoodCard(items[index]),
          );
        },
      ),
    );
  }

  Widget _buildFoodCard(FoodItem item) {
    final bool outOfStock = item.quantity <= 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: InkWell(
        onTap: outOfStock ? null : () => _showReservationSheet(context, item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surface,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary, size: 48),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${item.quantity} Left',
                      style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.businessName,
                      style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.outline,
                        letterSpacing: 0.05,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${item.discountedPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: 'Work Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '\$${item.originalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: 'Work Sans',
                                fontSize: 11,
                                color: AppColors.outline,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextButton(
                            onPressed: outOfStock ? null : () => _showReservationSheet(context, item),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              foregroundColor: AppColors.primary,
                              disabledForegroundColor: AppColors.textSecondary,
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  'Reserve',
                                  style: TextStyle(
                                    fontFamily: 'Work Sans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.chevron_right, size: 16),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedDeal(FoodItem item) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.35),
            colorBlendMode: BlendMode.darken,
            errorBuilder: (context, error, stackTrace) => Container(color: AppColors.surface),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.65), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.bakery_dining, color: AppColors.onPrimary, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Artisan Bakery Box',
                        style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${item.discountedPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Epilogue',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.surface,
                          ),
                        ),
                        Text(
                          '\$${item.originalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Work Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.surface,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      ),
                      onPressed: item.quantity > 0 ? () => _showReservationSheet(context, item) : null,
                      child: const Text(
                        'Reserve Now',
                        style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.eco,
              size: 120,
              color: AppColors.onPrimary.withOpacity(0.18),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Community Impact:',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '9,819 kg',
                style: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'of food saved this month, Together.',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReservationSheet(BuildContext context, FoodItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _ReservationSheetContent(item: item);
      },
    );
  }
}

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
                      style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.businessName,
                      style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 14,
                        color: AppColors.secondary,
                      ),
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
          const Divider(color: AppColors.outlineVariant),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Quantity',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 28),
                    color: _quantity > 1 ? AppColors.primary : AppColors.textSecondary,
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 28),
                    color: _quantity < widget.item.quantity ? AppColors.primary : AppColors.textSecondary,
                    onPressed: _quantity < widget.item.quantity ? () => setState(() => _quantity++) : null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '\$${(widget.item.discountedPrice * _quantity).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    final success = await ref.read(reservationsControllerProvider.notifier).reserveItem(widget.item, _quantity);
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
                      final error = ref.read(reservationsControllerProvider).error;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reservation failed: ${error ?? 'Unknown error'}'),
                          backgroundColor: AppColors.accent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Confirm Reservation',
                    style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
