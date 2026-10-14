import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/data/pakistan_cities.dart';
import '../../../core/models/weather_models.dart';
import '../../shared/widgets/glass_card.dart';
import '../../weather/controllers/weather_controller.dart';

/// Comprehensive Pakistan Cities Explorer & Search Screen
class CityExplorerScreen extends StatefulWidget {
  final WeatherController controller;
  final VoidCallback onCitySelected;

  const CityExplorerScreen({
    super.key,
    required this.controller,
    required this.onCitySelected,
  });

  @override
  State<CityExplorerScreen> createState() => _CityExplorerScreenState();
}

class _CityExplorerScreenState extends State<CityExplorerScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _selectedRegion = 'All Pakistan';
  List<LocationSuggestion> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    final clean = query.trim();
    if (clean.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final results = await widget.controller.searchCities(clean);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  void _selectCity(String cityName) {
    widget.controller.changeCity(cityName);
    widget.onCitySelected();
  }

  @override
  Widget build(BuildContext context) {
    final isDay = widget.controller.isDayEffective;
    final glowColor = widget.controller.ambientGlow;
    final recentSearches = widget.controller.recentSearches;
    final favorites = widget.controller.favorites;

    final filteredCities = PakistanCitiesDatabase.getByRegion(_selectedRegion);

    // Adaptive text colors for visibility in all modes
    final primaryTextColor = Colors.white;
    final secondaryTextColor = Colors.white.withOpacity(0.80);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              children: [
                Icon(Icons.explore_rounded, color: primaryTextColor, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pakistan Cities Explorer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Search live weather across all provinces, territories & worldwide',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 18),

            // Search Bar with 3D Glass aesthetic
            GlassCard(
              isDay: isDay,
              borderRadius: 22,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.8), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: TextStyle(color: primaryTextColor, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Search city (e.g. Lahore, Swat, Gwadar)...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_isSearching) ...[
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ] else if (_searchController.text.isNotEmpty) ...[
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.8), size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // GPS Auto-Location Quick Action Card
            GlassCard(
              isDay: isDay,
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              glowColor: widget.controller.isGpsActive ? const Color(0xFF00E676).withOpacity(0.3) : null,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await widget.controller.useGpsLocation();
                  if (widget.controller.isGpsActive) {
                    widget.onCitySelected();
                  }
                },
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: widget.controller.isGpsActive
                              ? [const Color(0xFF00E676), const Color(0xFF00C853)]
                              : [const Color(0xFF00B4D8), const Color(0xFF0077B6)],
                        ),
                      ),
                      child: widget.controller.isDetectingLocation
                          ? const Padding(
                              padding: EdgeInsets.all(9),
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(
                              widget.controller.isGpsActive ? Icons.gps_fixed_rounded : Icons.my_location_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.controller.isGpsActive
                                    ? 'Current Location (GPS Active)'
                                    : 'Use My Current Location',
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (widget.controller.isGpsActive) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00E676),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.controller.isGpsActive
                                ? '${widget.controller.selectedCity} (Live coordinates)'
                                : 'Auto-detect device GPS & fetch live weather',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.8), size: 14),
                  ],
                ),
              ),
            ),

            // Search Results Dropdown
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 12),
              GlassCard(
                isDay: isDay,
                borderRadius: 20,
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: _searchResults.map((item) {
                    return ListTile(
                      dense: true,
                      leading: Icon(Icons.location_city_rounded, color: primaryTextColor, size: 20),
                      title: Text(
                        item.name,
                        style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${item.region.isNotEmpty ? "${item.region}, " : ""}${item.country}',
                        style: TextStyle(color: secondaryTextColor, fontSize: 12),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.8), size: 14),
                      onTap: () => _selectCity(item.name),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Recent Searches Section
            if (recentSearches.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.history_rounded, color: primaryTextColor, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Recent Searches',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: widget.controller.clearRecentSearches,
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recentSearches.map((city) {
                  return _GlassPillChip(
                    label: city,
                    isDay: isDay,
                    icon: Icon(Icons.history_rounded, color: isDay ? Colors.white : const Color(0xFF64DFDF), size: 16),
                    onTap: () => _selectCity(city),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Favorite Cities Section
            if (favorites.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Favorite Cities',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: favorites.map((city) {
                  return _GlassPillChip(
                    label: city,
                    isDay: isDay,
                    borderColor: const Color(0x99FFD166),
                    icon: const Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 16),
                    onTap: () => _selectCity(city),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Province / Region Filter Chips
            Row(
              children: [
                Icon(Icons.map_rounded, color: primaryTextColor, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Browse by Region / Province',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: PakistanCitiesDatabase.regions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final reg = PakistanCitiesDatabase.regions[index];
                  final isSelected = reg == _selectedRegion;
                  return _GlassPillChip(
                    label: reg,
                    isDay: isDay,
                    isSelected: isSelected,
                    glowColor: glowColor,
                    onTap: () => setState(() => _selectedRegion = reg),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Filtered Pakistan Cities Cards Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredCities.length,
              itemBuilder: (context, index) {
                final city = filteredCities[index];
                final isCurrent = widget.controller.selectedCity.toLowerCase() == city.name.toLowerCase();

                return GlassCard(
                  isDay: isDay,
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  glowColor: isCurrent ? glowColor : null,
                  onTap: () => _selectCity(city.name),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                city.name,
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  shadows: isCurrent
                                      ? [Shadow(color: glowColor, blurRadius: 8)]
                                      : [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.check_circle_rounded, color: glowColor, size: 16),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            city.province,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassPillChip extends StatelessWidget {
  final Widget? icon;
  final String label;
  final VoidCallback onTap;
  final bool isDay;
  final Color? borderColor;
  final Color? glowColor;
  final bool isSelected;

  const _GlassPillChip({
    this.icon,
    required this.label,
    required this.onTap,
    required this.isDay,
    this.borderColor,
    this.glowColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlow = glowColor ?? const Color(0xFF00B4D8);
    final bg = isSelected
        ? effectiveGlow.withOpacity(0.45)
        : (isDay ? Colors.white.withOpacity(0.24) : Colors.white.withOpacity(0.12));
    final border = isSelected
        ? Border.all(color: Colors.white.withOpacity(0.9), width: 1.5)
        : Border.all(
            color: borderColor ?? (isDay ? Colors.white.withOpacity(0.45) : Colors.white.withOpacity(0.28)),
            width: 1.0,
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: border,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: effectiveGlow.withOpacity(0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
