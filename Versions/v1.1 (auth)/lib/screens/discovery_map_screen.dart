import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/food_item.dart';
import '../providers/providers.dart';
import 'reservations_tracker_screen.dart';

class DiscoveryMapScreen extends ConsumerStatefulWidget {
  const DiscoveryMapScreen({super.key});

  @override
  ConsumerState<DiscoveryMapScreen> createState() => _DiscoveryMapScreenState();
}

class _DiscoveryMapScreenState extends ConsumerState<DiscoveryMapScreen> {
  final MapController _mapController = MapController();
  late final PageController _pageController;
  final TextEditingController _searchController = TextEditingController();
  final LatLng _defaultCenter = const LatLng(1.3521, 103.8198);

  String _searchQuery = '';
  String _activeCategory = 'All';
  int _selectedCardIndex = 0;

  static const List<String> _categoryOptions = [
    'All',
    'Bakery',
    'Produce',
    'Cafe',
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

  List<FoodItem> _filteredFoods(List<FoodItem> items) {
    final query = _searchQuery.toLowerCase();
    return items.where((item) {
      final matchesCategory =
          _activeCategory == 'All' || item.category == _activeCategory;
      final matchesSearch =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.businessName.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _activeCategory = category;
      _selectedCardIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _selectStore(int index, List<FoodItem> activeItems) {
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

  Future<void> _animateMapToLocation(FoodItem item) async {
    final target = LatLng(item.latitude, item.longitude);
    final start = _defaultCenter;
    const int steps = 12;
    for (int step = 1; step <= steps; step++) {
      if (!mounted) return;
      final progress = step / steps;
      final lat =
          start.latitude + (target.latitude - start.latitude) * progress;
      final lng =
          start.longitude + (target.longitude - start.longitude) * progress;
      _mapController.move(LatLng(lat, lng), 14.5);
      await Future.delayed(const Duration(milliseconds: 18));
    }
  }

  String _formatDistance(FoodItem item) {
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
    final outlineColor = colorScheme.outline.withOpacity(0.24);
    final reservationsState = ref.watch(reservationsControllerProvider);
    final isReserving = reservationsState is AsyncLoading;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          ref
              .watch(foodItemsStreamProvider)
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
                          initialZoom: 13.5,
                          minZoom: 11.0,
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
                                  0.9,
                                  0,
                                  0,
                                  0,
                                  15,
                                  0,
                                  0.9,
                                  0,
                                  0,
                                  15,
                                  0,
                                  0,
                                  0.95,
                                  0,
                                  15,
                                  0,
                                  0,
                                  0,
                                  1,
                                  0,
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
                                width: isSelected ? 64 : 52,
                                height: isSelected ? 84 : 74,
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
                                        padding: EdgeInsets.all(
                                          isSelected ? 12 : 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? primaryColor
                                              : Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.white
                                                : outlineColor,
                                            width: isSelected ? 3 : 1.5,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 9,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          _iconForCategory(item.category),
                                          color: isSelected
                                              ? Colors.white
                                              : primaryColor,
                                          size: isSelected ? 28 : 22,
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          margin: const EdgeInsets.only(top: 6),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: surfaceColor,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: outlineColor,
                                            ),
                                          ),
                                          child: Text(
                                            'Selected',
                                            style: TextStyle(
                                              color: onSurfaceColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
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
                                                  const ReservationsTrackerScreen(),
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
                                              color: Colors.black.withOpacity(
                                                0.06,
                                              ),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.search,
                                              color: onSurfaceColor.withOpacity(
                                                0.6,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextField(
                                                controller: _searchController,
                                                style: TextStyle(
                                                  color: onSurfaceColor,
                                                ),
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText:
                                                      'Search areas or food types...',
                                                  hintStyle: TextStyle(
                                                    color: onSurfaceColor
                                                        .withOpacity(0.55),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Material(
                                      color: surfaceColor,
                                      shape: const CircleBorder(),
                                      elevation: 2,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.person,
                                          size: 20,
                                        ),
                                        color: onSurfaceColor,
                                        onPressed: () {},
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
                                        color: onSurfaceColor.withOpacity(0.16),
                                        borderColor: Colors.transparent,
                                        icon: Icons.tune,
                                        textColor: onSurfaceColor,
                                      ),
                                      const SizedBox(width: 10),
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
                                  color: onSurfaceColor.withOpacity(0.75),
                                  fontSize: 14,
                                ),
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
                                final reserveDisabled =
                                    item.quantity <= 0 || isReserving;

                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: index == 0 ? 16 : 8,
                                    right: index == filteredItems.length - 1
                                        ? 16
                                        : 8,
                                  ),
                                  child: Card(
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
                                                  item.businessName,
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
                                                      .withOpacity(0.08),
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
                                                    .withOpacity(0.82),
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
                                                  'Pickup ${item.pickupWindow} · ${item.quantity} left',
                                                  style: TextStyle(
                                                    color: onSurfaceColor
                                                        .withOpacity(0.7),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: reserveDisabled
                                                    ? null
                                                    : () async {
                                                        final success = await ref
                                                            .read(
                                                              reservationsControllerProvider
                                                                  .notifier,
                                                            )
                                                            .reserveItem(
                                                              item,
                                                              1,
                                                            );
                                                        if (!mounted) return;
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              success
                                                                  ? 'Reserved 1 item from ${item.businessName}.'
                                                                  : 'Reservation failed. Please try again.',
                                                            ),
                                                            backgroundColor:
                                                                success
                                                                ? primaryColor
                                                                : colorScheme
                                                                      .error,
                                                          ),
                                                        );
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      reserveDisabled
                                                      ? colorScheme
                                                            .surfaceVariant
                                                      : const Color(0xFFFFC107),
                                                  foregroundColor:
                                                      reserveDisabled
                                                      ? onSurfaceColor
                                                            .withOpacity(0.5)
                                                      : Colors.black,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          14,
                                                        ),
                                                  ),
                                                  elevation: 0,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 18,
                                                        vertical: 12,
                                                      ),
                                                ),
                                                child: isReserving
                                                    ? const SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                      )
                                                    : Text(
                                                        item.quantity <= 0
                                                            ? 'Sold Out'
                                                            : 'Reserve',
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
                        initialZoom: 13.5,
                        minZoom: 11.0,
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
