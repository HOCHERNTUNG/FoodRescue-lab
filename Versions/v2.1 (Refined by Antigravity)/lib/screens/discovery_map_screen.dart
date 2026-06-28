import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_colors.dart';
import '../models/listing_model.dart';
import '../providers/database_providers.dart';
import 'reservations_screen.dart';
import 'item_details_screen.dart';

class DiscoveryMapScreen extends ConsumerStatefulWidget {
  const DiscoveryMapScreen({super.key});

  @override
  ConsumerState<DiscoveryMapScreen> createState() => _DiscoveryMapScreenState();
}

class _DiscoveryMapScreenState extends ConsumerState<DiscoveryMapScreen> {
  final MapController _mapController = MapController();
  late final PageController _pageController;
  final TextEditingController _searchController = TextEditingController();
  final LatLng _defaultCenter = const LatLng(1.29027, 103.85195); // Singapore center

  String _searchQuery = '';
  String _activeCategory = 'All';
  int _selectedCardIndex = 0;
  bool _showFilters = true; // Toggle category filter pills

  static const List<String> _categoryOptions = [
    'All',
    'Bakery',
    'Produce',
    'Meals',
    'Groceries',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: _selectedCardIndex,
    );
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
      _selectedCardIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  List<ListingModel> _filteredFoods(List<ListingModel> items) {
    final query = _searchQuery.toLowerCase();
    return items.where((item) {
      final matchesCategory =
          _activeCategory == 'All' || item.category.toLowerCase() == _activeCategory.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _onCategorySelected(String category) {
    setState(() {
      if (_activeCategory == category) {
        _activeCategory = 'All'; // Deselect category
      } else {
        _activeCategory = category;
      }
      _selectedCardIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _selectStore(int index, List<ListingModel> activeItems) {
    if (index < 0 || index >= activeItems.length) return;
    setState(() {
      _selectedCardIndex = index;
    });
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    }
    _animateMapToLocation(activeItems[index]);
  }

  Future<void> _animateMapToLocation(ListingModel item) async {
    final target = LatLng(item.latitude, item.longitude);
    final start = _mapController.camera.center;
    const int steps = 15;
    for (int step = 1; step <= steps; step++) {
      if (!mounted) return;
      final progress = step / steps;
      final easedProgress = Curves.easeInOut.transform(progress);
      final lat = start.latitude + (target.latitude - start.latitude) * easedProgress;
      final lng = start.longitude + (target.longitude - start.longitude) * easedProgress;
      _mapController.move(LatLng(lat, lng), 14.5);
      await Future.delayed(const Duration(milliseconds: 16));
    }
  }

  String _formatDistance(ListingModel item) {
    final distance = const Distance().as(
      LengthUnit.Kilometer,
      _defaultCenter,
      LatLng(item.latitude, item.longitude),
    );
    return '${distance.toStringAsFixed(1)} km';
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'bakery':
        return Icons.bakery_dining;
      case 'produce':
        return Icons.eco;
      case 'cafe':
      case 'coffee':
        return Icons.local_cafe;
      case 'groceries':
        return Icons.local_grocery_store;
      default:
        return Icons.restaurant_menu;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceColor = colorScheme.surface;
    final primaryColor = colorScheme.primary;
    final onSurfaceColor = colorScheme.onSurface;
    final outlineColor = colorScheme.outline.withAlpha(61);

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          ref
              .watch(listingsStreamProvider)
              .when(
                data: (items) {
                  final filteredItems = _filteredFoods(items);
                  if (filteredItems.isNotEmpty &&
                      _selectedCardIndex >= filteredItems.length) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      setState(() {
                        _selectedCardIndex = 0;
                      });
                      if (_pageController.hasClients) {
                        _pageController.jumpToPage(0);
                      }
                    });
                  }

                  return Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _defaultCenter,
                          initialZoom: 13.0,
                          minZoom: 10.0,
                          maxZoom: 18.0,
                          interactiveFlags: InteractiveFlag.all,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                            subdomains: const ['a', 'b', 'c', 'd'],
                            userAgentPackageName: 'com.foodrescue.labgh',
                            tileBuilder: (context, tileWidget, tile) {
                              return ColorFiltered(
                                colorFilter: const ColorFilter.matrix([
                                  0.9, 0, 0, 0, 0,
                                  0, 0.9, 0, 0, 0,
                                  0, 0, 0.95, 0, 0,
                                  0, 0, 0, 1, 0,
                                ]),
                                child: tileWidget,
                              );
                            },
                          ),
                          MarkerLayer(
                            markers: filteredItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final isSelected = index == _selectedCardIndex;
                              return Marker(
                                point: LatLng(item.latitude, item.longitude),
                                width: isSelected ? 65 : 55,
                                height: isSelected ? 75 : 65,
                                child: GestureDetector(
                                  onTap: () =>
                                      _selectStore(index, filteredItems),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 220,
                                        ),
                                        width: isSelected ? 48 : 38,
                                        height: isSelected ? 48 : 38,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : Colors.white,
                                            width: isSelected ? 3 : 1.5,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 6,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child: Image.network(
                                            item.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              _iconForCategory(item.category),
                                              color: isSelected
                                                  ? Colors.white
                                                  : primaryColor,
                                              size: isSelected ? 22 : 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(0, -3),
                                        child: Transform.rotate(
                                          angle: 0.785398,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            color: isSelected
                                                ? AppColors.primary
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withAlpha(191),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Material(
                                      color: surfaceColor,
                                      shape: const CircleBorder(),
                                      elevation: 2,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                        ),
                                        color: onSurfaceColor,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const ReservationsScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        height: 50,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: surfaceColor,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: outlineColor,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(15),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.search,
                                              color: onSurfaceColor.withAlpha(153),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextField(
                                                controller: _searchController,
                                                style: TextStyle(
                                                  color: onSurfaceColor,
                                                ),
                                                decoration: InputDecoration(
                                                  filled: false,
                                                  border: InputBorder.none,
                                                  enabledBorder: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                  disabledBorder: InputBorder.none,
                                                  contentPadding: EdgeInsets.zero,
                                                  hintText:
                                                      'Search areas or food types...',
                                                  hintStyle: TextStyle(
                                                    color: onSurfaceColor
                                                        .withAlpha(140),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: [
                                      _buildFilterPill(
                                        label: 'Filters',
                                        color: onSurfaceColor.withAlpha(41),
                                        borderColor: Colors.transparent,
                                        icon: Icons.tune,
                                        textColor: onSurfaceColor,
                                        onTap: () {
                                          setState(() {
                                            _showFilters = !_showFilters;
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                      if (_showFilters)
                                        ..._categoryOptions
                                            .where(
                                              (category) => category != 'All',
                                            )
                                            .map(
                                              (category) => Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 10,
                                                ),
                                                child: _buildFilterPill(
                                                  label: category,
                                                  selected:
                                                      _activeCategory == category,
                                                  icon: _iconForCategory(category),
                                                  onTap: () =>
                                                      _onCategorySelected(
                                                        category,
                                                      ),
                                                  color:
                                                      _activeCategory == category
                                                      ? primaryColor
                                                      : surfaceColor,
                                                  textColor:
                                                      _activeCategory == category
                                                      ? Colors.white
                                                      : onSurfaceColor,
                                                  borderColor: outlineColor,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (filteredItems.isEmpty)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 20,
                          child: Container(
                            height: 190,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: outlineColor),
                            ),
                            child: Center(
                              child: Text(
                                'No listings match your search or selected filter.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: onSurfaceColor.withAlpha(191),
                                  fontSize: 14,
                                ),
                                key: const Key('empty_state_text'),
                              ),
                            ),
                          ),
                        )
                      else
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 20,
                          child: SizedBox(
                            height: 190,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: filteredItems.length,
                              onPageChanged: (index) {
                                _selectStore(index, filteredItems);
                              },
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final isSelected = index == _selectedCardIndex;
                                final distanceLabel = _formatDistance(item);

                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: index == 0 ? 16 : 8,
                                    right: index == filteredItems.length - 1
                                        ? 16
                                        : 8,
                                  ),
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    elevation: isSelected ? 6 : 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    color: surfaceColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.name,
                                                  style: TextStyle(
                                                    color: onSurfaceColor,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: onSurfaceColor
                                                      .withAlpha(20),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                                child: Text(
                                                  distanceLabel,
                                                  style: TextStyle(
                                                    color: onSurfaceColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Expanded(
                                            child: Text(
                                              item.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: onSurfaceColor
                                                    .withAlpha(209),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Pickup ${item.pickupWindow} · ${item.itemsRemaining} left',
                                                  style: TextStyle(
                                                    color: onSurfaceColor
                                                        .withAlpha(179),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: item.itemsRemaining <= 0
                                                    ? null
                                                    : () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) => ItemDetailsScreen(item: item),
                                                          ),
                                                        );
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: item.itemsRemaining <= 0
                                                      ? colorScheme.surfaceVariant
                                                      : const Color(0xFFFFD300),
                                                  foregroundColor: item.itemsRemaining <= 0
                                                      ? onSurfaceColor.withAlpha(128)
                                                      : Colors.black,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(14),
                                                  ),
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                                ),
                                                child: Text(
                                                  item.itemsRemaining <= 0 ? 'Sold Out' : 'Rescue',
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _defaultCenter,
                        initialZoom: 13.0,
                        minZoom: 10.0,
                        maxZoom: 18.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.foodrescue.labgh',
                        ),
                      ],
                    ),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Map error: $error',
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    bool selected = false,
    required Color color,
    required Color textColor,
    required Color borderColor,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
