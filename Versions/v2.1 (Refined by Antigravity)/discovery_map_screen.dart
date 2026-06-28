import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiscoveryMapScreen extends ConsumerStatefulWidget {
  const DiscoveryMapScreen({super.key});

  @override
  ConsumerState<DiscoveryMapScreen> createState() => _DiscoveryMapScreenState();
}

class _DiscoveryMapScreenState extends ConsumerState<DiscoveryMapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  int _selectedPinIndex = 0;
  int _currentNavIndex = 0;

  final List<_StoreCardData> _carouselItems = const [
    _StoreCardData(
      name: 'Sunrise Artisan Bakery',
      distance: '0.2 km',
      pickupWindow: '5PM - 6PM',
      availability: '12 items left',
      category: 'Bakery',
    ),
    _StoreCardData(
      name: 'Green Market Produce',
      distance: '0.4 km',
      pickupWindow: '6PM - 7PM',
      availability: '8 items left',
      category: 'Produce',
    ),
    _StoreCardData(
      name: 'Brewed Goodness Cafe',
      distance: '0.7 km',
      pickupWindow: '4PM - 5PM',
      availability: '5 items left',
      category: 'Cafe',
    ),
  ];

  final List<_PinData> _pinData = const [
    _PinData(left: 0.18, top: 0.28, label: 'Bakery', icon: Icons.bakery_dining),
    _PinData(left: 0.55, top: 0.42, label: 'Coffee', icon: Icons.coffee),
    _PinData(left: 0.74, top: 0.18, label: 'Produce', icon: Icons.eco),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceLowest = _surfaceContainerLowestColor(colorScheme);
    final outlineColor = colorScheme.outline.withOpacity(0.32);

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          _buildMapLayer(colorScheme),
          _buildPinsLayer(colorScheme),
          _buildTopOverlay(colorScheme, outlineColor),
          _buildBottomCarousel(colorScheme, surfaceLowest, outlineColor),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.7),
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore, color: colorScheme.primary),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map, color: colorScheme.primary),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: colorScheme.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildMapLayer(ColorScheme colorScheme) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: const LatLng(37.7749, -122.4194),
        zoom: 13,
        minZoom: 3,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.foodrescue.lab',
        ),
      ],
    );
  }

  Widget _buildPinsLayer(ColorScheme colorScheme) {
    return Stack(
      children: _pinData.asMap().entries.map((entry) {
        final index = entry.key;
        final pin = entry.value;
        final isSelected = index == _selectedPinIndex;

        return Positioned(
          left: MediaQuery.of(context).size.width * pin.left,
          top: MediaQuery.of(context).size.height * pin.top,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedPinIndex = index;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(18),
                    border: isSelected ? Border.all(color: colorScheme.primary, width: 3) : null,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.onSurface.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    pin.icon,
                    size: 28,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
                    ),
                    child: Text(
                      'Selected',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopOverlay(ColorScheme colorScheme, Color outlineColor) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Material(
                    color: colorScheme.surface,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: IconButton(
                      icon: Icon(Icons.person, color: colorScheme.onSurface),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: outlineColor),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.onSurface.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.7)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: colorScheme.onSurface),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search areas or food types...',
                                hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.55)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill(colorScheme, 'Filters', isPrimary: true),
                    const SizedBox(width: 8),
                    _buildFilterPill(colorScheme, 'Bakery'),
                    const SizedBox(width: 8),
                    _buildFilterPill(colorScheme, 'Produce'),
                    const SizedBox(width: 8),
                    _buildFilterPill(colorScheme, 'Cafe'),
                    const SizedBox(width: 8),
                    _buildFilterPill(colorScheme, 'Groceries'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(ColorScheme colorScheme, String label, {bool isPrimary = false}) {
    if (isPrimary) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withOpacity(0.92),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: colorScheme.surface,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primaryContainer),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomCarousel(ColorScheme colorScheme, Color surfaceLowest, Color outlineColor) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 100,
      child: SizedBox(
        height: 310,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: _carouselItems.length,
          itemBuilder: (context, index) {
            final item = _carouselItems[index];
            return Container(
              width: 280,
              margin: EdgeInsets.only(right: index == _carouselItems.length - 1 ? 16 : 12),
              decoration: BoxDecoration(
                color: surfaceLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: outlineColor),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.08),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: const Center(
                          child: Icon(Icons.storefront_outlined, size: 56, color: Colors.white70),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${item.pickupWindow} Pickup',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.distance,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
                                ),
                                child: Text(
                                  item.availability,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Reserve'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _surfaceContainerLowestColor(ColorScheme scheme) {
    final dynamic maybe = scheme;
    try {
      final color = maybe.surfaceContainerLowest;
      if (color is Color) {
        return color;
      }
    } catch (_) {}
    return scheme.surface;
  }
}

class _StoreCardData {
  final String name;
  final String distance;
  final String pickupWindow;
  final String availability;
  final String category;

  const _StoreCardData({
    required this.name,
    required this.distance,
    required this.pickupWindow,
    required this.availability,
    required this.category,
  });
}

class _PinData {
  final double left;
  final double top;
  final String label;
  final IconData icon;

  const _PinData({
    required this.left,
    required this.top,
    required this.label,
    required this.icon,
  });
}
