import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/widgets/glass_card.dart';
import '../../weather/controllers/weather_controller.dart';

/// Professional Executive Settings & System Preferences Screen
class SettingsScreen extends StatefulWidget {
  final WeatherController controller;

  const SettingsScreen({super.key, required this.controller});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _triggerHaptic({bool isMedium = false}) {
    if (widget.controller.hapticFeedbackEnabled) {
      if (isMedium) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }
  }

  void _showFeedbackToast(String message, {IconData icon = Icons.check_circle_rounded, Color color = const Color(0xFF0077B6)}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF0D1B2A).withOpacity(0.92),
        elevation: 8,
        duration: const Duration(milliseconds: 2200),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final isDay = widget.controller.isDayEffective;
        final glowColor = widget.controller.ambientGlow;
        final themeMode = widget.controller.themeMode;
        final tempUnit = widget.controller.tempUnit;
        final windUnit = widget.controller.windUnit;
        final pressureUnit = widget.controller.pressureUnit;
        final animMode = widget.controller.animationMode;
        final autoRefresh = widget.controller.autoRefreshInterval;
        final activeLocality = widget.controller.selectedCity;
        final activeProviderName = widget.controller.snapshot?.providerName ?? 'Solunair Cloud Core';

        return SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [glowColor.withOpacity(0.6), glowColor.withOpacity(0.2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: glowColor.withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/icons/solunair_logo.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Settings & Preferences',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Customization, precision GPS & atmospheric sync',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // =============================================================
                    // 1. LIVE METEOROLOGICAL NETWORK STATUS
                    // =============================================================
                    GlassCard(
                      isDay: isDay,
                      borderRadius: 22,
                      padding: const EdgeInsets.all(16),
                      glowColor: const Color(0xFF00E676).withOpacity(0.35),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00E676),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF00E676),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Meteorological Core Online',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676).withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF00E676).withOpacity(0.4)),
                                ),
                                child: const Text(
                                  'Live Sync',
                                  style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // 2x2 Metric Grid with responsive expanded tiles
                          Row(
                            children: [
                              Expanded(
                                child: _buildNetworkMetric(
                                  icon: Icons.radar_rounded,
                                  label: 'Radar Stream',
                                  value: 'Active • 60 FPS',
                                  color: const Color(0xFF64DFDF),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildNetworkMetric(
                                  icon: Icons.gps_fixed_rounded,
                                  label: 'GPS Geocoding',
                                  value: 'Hyper-Local',
                                  color: const Color(0xFFFFD166),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildNetworkMetric(
                                  icon: Icons.place_rounded,
                                  label: 'Active Locality',
                                  value: activeLocality,
                                  color: const Color(0xFF48CAE4),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildNetworkMetric(
                                  icon: Icons.verified_rounded,
                                  label: 'Data Fidelity',
                                  value: activeProviderName,
                                  color: const Color(0xFF57CC99),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =============================================================
                    // 2. DEVICE GPS AUTO-LOCATION & PRECISION
                    // =============================================================
                    _buildSectionHeader('Device GPS & Location Tracking', Icons.my_location_rounded, const Color(0xFF00E676)),
                    const SizedBox(height: 10),
                    GlassCard(
                      isDay: isDay,
                      borderRadius: 22,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSwitchRow(
                            title: 'GPS Live Tracking',
                            subtitle: widget.controller.isGpsActive
                                ? 'Pinpointing local society coordinates'
                                : 'Disabled — using manual city search',
                            value: widget.controller.isGpsActive,
                            activeColor: const Color(0xFF00E676),
                            icon: Icons.location_searching_rounded,
                            onChanged: (val) {
                              _triggerHaptic();
                              if (val) {
                                widget.controller.useGpsLocation();
                                _showFeedbackToast('Locating your device via GPS...', icon: Icons.gps_fixed_rounded, color: const Color(0xFF00E676));
                              } else {
                                widget.controller.disableGpsLocation();
                                _showFeedbackToast('GPS tracking disabled. Manual city mode active.', icon: Icons.location_off_rounded, color: const Color(0xFFFFD166));
                              }
                            },
                          ),

                          if (widget.controller.isGpsActive) ...[
                            const SizedBox(height: 12),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF00E676).withOpacity(0.4), width: 1.2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          activeLocality,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 26),
                                    child: Text(
                                      'Coordinates: ${widget.controller.gpsLatitude?.toStringAsFixed(4) ?? widget.controller.snapshot?.latitude.toStringAsFixed(4) ?? "31.4772"}° N, ${widget.controller.gpsLongitude?.toStringAsFixed(4) ?? widget.controller.snapshot?.longitude.toStringAsFixed(4) ?? "74.2467"}° E',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (widget.controller.gpsError != null && !widget.controller.isGpsActive) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B6B).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: Color(0xFFFF6B6B), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.controller.gpsError!,
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 14),

                          // Locate Device Now Button with Animated States
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: widget.controller.isDetectingLocation
                                  ? null
                                  : () async {
                                      _triggerHaptic(isMedium: true);
                                      await widget.controller.useGpsLocation();
                                      if (mounted) {
                                        if (widget.controller.gpsError != null) {
                                          _showFeedbackToast(
                                            widget.controller.gpsError!,
                                            icon: Icons.error_outline_rounded,
                                            color: const Color(0xFFFF6B6B),
                                          );
                                        } else {
                                          _showFeedbackToast(
                                            'Precise location locked: ${widget.controller.selectedCity}',
                                            icon: Icons.my_location_rounded,
                                            color: const Color(0xFF00E676),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0077B6),
                                foregroundColor: Colors.white,
                                elevation: 3,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  widget.controller.isDetectingLocation
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Icon(Icons.gps_fixed_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.controller.isDetectingLocation
                                        ? 'Pinpointing Precision GPS Location...'
                                        : 'Locate Device Now (GPS)',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =============================================================
                    // 3. SMART FORECAST & AUTO-SYNC CADENCE (NO OVERFLOW)
                    // =============================================================
                    _buildSectionHeader('Smart Forecast & Auto-Sync', Icons.schedule_rounded, const Color(0xFFFFD166)),
                    const SizedBox(height: 10),
                    GlassCard(
                      isDay: isDay,
                      borderRadius: 22,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Background Refresh Cadence',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Frequency of automatic weather updates in background',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                          ),
                          const SizedBox(height: 12),

                          // Custom 4-pill selector that never overflows
                          _buildSegmentedPills<String>(
                            options: const [
                              _PillOption(value: '15m', label: '15 min', icon: Icons.timer_outlined),
                              _PillOption(value: '30m', label: '30 min', icon: Icons.timelapse_rounded),
                              _PillOption(value: '1h', label: '1 Hour', icon: Icons.schedule_rounded),
                              _PillOption(value: 'manual', label: 'Manual', icon: Icons.touch_app_rounded),
                            ],
                            selectedValue: autoRefresh,
                            activeColor: glowColor,
                            onChanged: (val) {
                              _triggerHaptic();
                              widget.controller.setAutoRefreshInterval(val);
                              _showFeedbackToast('Auto-refresh cadence set to $val', icon: Icons.schedule_rounded, color: const Color(0xFFFFD166));
                            },
                          ),

                          const SizedBox(height: 16),
                          _buildDivider(),
                          const SizedBox(height: 14),

                          // Morning Briefing
                          _buildSwitchRow(
                            title: 'Daily Morning Briefing (07:00 AM)',
                            subtitle: 'Temperature summary & rain probability before start of day',
                            value: widget.controller.morningBriefingEnabled,
                            activeColor: const Color(0xFFFFD166),
                            icon: Icons.wb_twilight_rounded,
                            onChanged: (val) {
                              _triggerHaptic();
                              widget.controller.setMorningBriefingEnabled(val);
                              _showFeedbackToast(
                                val ? 'Morning Briefing enabled for 07:00 AM' : 'Morning Briefing disabled',
                                icon: Icons.wb_twilight_rounded,
                                color: const Color(0xFFFFD166),
                              );
                            },
                          ),

                          const SizedBox(height: 14),
                          _buildDivider(),
                          const SizedBox(height: 14),

                          // Evening Outlook
                          _buildSwitchRow(
                            title: 'Evening Tomorrow Outlook (08:00 PM)',
                            subtitle: 'Previews tomorrow’s weather trends to help you plan outdoor events',
                            value: widget.controller.eveningOutlookEnabled,
                            activeColor: const Color(0xFF64DFDF),
                            icon: Icons.nights_stay_rounded,
                            onChanged: (val) {
                              _triggerHaptic();
                              widget.controller.setEveningOutlookEnabled(val);
                              _showFeedbackToast(
                                val ? 'Evening Outlook enabled for 08:00 PM' : 'Evening Outlook disabled',
                                icon: Icons.nights_stay_rounded,
                                color: const Color(0xFF64DFDF),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =============================================================
                    // 4. ENVIRONMENTAL HEALTH & AIR QUALITY (AQI) ADVISORY
                    // =============================================================
                    _buildSectionHeader('Environmental Health & UV Advisory', Icons.health_and_safety_rounded, const Color(0xFF48CAE4)),
                    const SizedBox(height: 10),
                    GlassCard(
                      isDay: isDay,
                      borderRadius: 22,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSwitchRow(
                            title: 'Smog & Air Quality (AQI) Alert',
                            subtitle: 'Immediate alerts when PM2.5 or particulate matter reaches Unhealthy levels',
                            value: widget.controller.aqiAlertsEnabled,
                            activeColor: const Color(0xFFFF6B6B),
                            icon: Icons.air_rounded,
                            onChanged: (val) {
                              _triggerHaptic();
                              widget.controller.setAqiAlertsEnabled(val);
                              _showFeedbackToast(
                                val ? 'AQI Smog Alerts activated' : 'AQI Smog Alerts muted',
                                icon: Icons.air_rounded,
                                color: const Color(0xFFFF6B6B),
                              );
                            },
                          ),

                          const SizedBox(height: 14),
                          _buildDivider(),
                          const SizedBox(height: 14),

                          _buildSwitchRow(
                            title: 'Solar UV Radiation Guard',
                            subtitle: 'Reminds you to wear sunscreen & sunglasses when UV Index > 6',
                            value: widget.controller.uvAlertsEnabled,
                            activeColor: const Color(0xFFFFD166),
                            icon: Icons.wb_sunny_rounded,
                            onChanged: (val) {
                              _triggerHaptic();
                              widget.controller.setUvAlertsEnabled(val);
                              _showFeedbackToast(
                                val ? 'Solar UV Guard active' : 'Solar UV Guard muted',
                                icon: Icons.wb_sunny_rounded,
                                color: const Color(0xFFFFD166),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =============================================================
                    // 5. GRAPHICS & VISUAL ENGINE (NO OVERFLOW)
                    // =============================================================
                    _buildSectionHeader('Graphics & Animation Engine', Icons.auto_awesome_rounded, const Color(0xFF64DFDF)),
                    const SizedBox(height: 10),
                    GlassCard(
                      isDay: isDay,
                      borderRadius: 22,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Atmosphere VFX Engine',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            animMode == 'high'
                                ? 'Photorealistic volumetric clouds, dynamic rain streaks & radiant solar corona enabled.'
                                : 'Static low-power rendering active to extend battery life.',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                          ),
                          const SizedBox(height: 12),

                          // 2-card selector that spans full width without squishing
                          Row(
                            children: [
                              Expanded(
                                child: _buildSelectableCard(
                                  title: 'Realistic VFX',
                                  subtitle: 'Atmospheric 3D',
                                  icon: Icons.auto_awesome_rounded,
                                  isSelected: animMode == 'high',
                                  activeColor: const Color(0xFF64DFDF),
                                  onTap: () {
                                    _triggerHaptic(isMedium: true);
                                    widget.controller.setAnimationMode('high');
                                    _showFeedbackToast('Realistic 3D Atmosphere VFX active', icon: Icons.auto_awesome_rounded, color: const Color(0xFF64DFDF));
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildSelectableCard(
                                  title: 'Battery Saver',
                                  subtitle: 'Static Render',
                                  icon: Icons.eco_rounded,
                                  isSelected: animMode == 'reduced',
                                  activeColor: const Color(0xFF57CC99),
                                  onTap: () {
                                    _triggerHaptic(isMedium: true);
                                    widget.controller.setAnimationMode('reduced');
                                    _showFeedbackToast('Battery Saver Mode enabled', icon: Icons.eco_rounded, color: const Color(0xFF57CC99));
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          _buildDivider(),
                          const SizedBox(height: 14),

                          // Haptic Tactile Feedback Switch
                          _buildSwitchRow(
                            title: 'Haptic Tactile Feedback',
                            subtitle: 'Subtle vibration response when scrubbing hourly forecast cards',
                            value: widget.controller.hapticFeedbackEnabled,
                            activeColor: const Color(0xFF64DFDF),
                            icon: Icons.vibration_rounded,
                            onChanged: (val) {
                              widget.controller.setHapticFeedbackEnabled(val);
                              if (val) HapticFeedback.mediumImpact();
                              _showFeedbackToast(
                                val ? 'Haptic feedback enabled' : 'Haptic feedback muted',
                                icon: Icons.vibration_rounded,
                                color: const Color(0xFF64DFDF),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =============================================================
                    // 6. APPEARANCE & THEME
                    // =============================================================
                    _buildSectionHeader('Appearance & Theme', Icons.palette_rounded, const Color(0xFFFFD166)),
                    const SizedBox(height: 10),
                    GlassCard(
                      isDay: isDay,
                      borderRadius: 22,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _buildThemeOption(
                            'Weather Adaptive (Recommended)',
                            'Follows real-time city condition and day/night',
                            'adaptive',
                            themeMode,
                            Icons.auto_awesome_rounded,
                          ),
                          _buildDivider(),
                          _buildThemeOption(
                            'Radiant Day Theme',
                            'Vibrant cyan & sunlit sky aesthetics',
                            'light',
                            themeMode,
                            Icons.wb_sunny_rounded,
                          ),
                          _buildDivider(),
                          _buildThemeOption(
                            'Celestial Night Theme',
                            'Midnight obsidian & purple glow',
                            'dark',
                            themeMode,
                            Icons.nightlight_round,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =============================================================
                    // 7. MEASUREMENT UNITS (NO OVERFLOW)
                    // =============================================================
                    _buildSectionHeader('Measurement Units', Icons.straighten_rounded, const Color(0xFF57CC99)),
                    const SizedBox(height: 10),
                    GlassCard(
                      isDay: isDay,
                      borderRadius: 22,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Temperature Unit
                          const Text(
                            'Temperature Unit',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Unit used across hero temperatures and hourly timeline',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          _buildSegmentedPills<String>(
                            options: const [
                              _PillOption(value: 'C', label: '°C (Celsius)', icon: Icons.thermostat_rounded),
                              _PillOption(value: 'F', label: '°F (Fahrenheit)', icon: Icons.device_thermostat_rounded),
                            ],
                            selectedValue: tempUnit,
                            activeColor: glowColor,
                            onChanged: (set) {
                              _triggerHaptic();
                              widget.controller.setTemperatureUnit(set);
                              _showFeedbackToast('Temperature unit set to °$set', icon: Icons.thermostat_rounded);
                            },
                          ),

                          const SizedBox(height: 16),
                          _buildDivider(),
                          const SizedBox(height: 14),

                          // Wind Speed Unit
                          const Text(
                            'Wind Speed Unit',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Velocity unit for wind speed and gust metrics',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          _buildSegmentedPills<String>(
                            options: const [
                              _PillOption(value: 'kph', label: 'km/h', sublabel: 'Kilometers/hr'),
                              _PillOption(value: 'mph', label: 'mph', sublabel: 'Miles/hr'),
                              _PillOption(value: 'ms', label: 'm/s', sublabel: 'Meters/sec'),
                            ],
                            selectedValue: windUnit,
                            activeColor: glowColor,
                            onChanged: (set) {
                              _triggerHaptic();
                              widget.controller.setWindSpeedUnit(set);
                              _showFeedbackToast('Wind speed unit set to $set', icon: Icons.air_rounded);
                            },
                          ),

                          const SizedBox(height: 16),
                          _buildDivider(),
                          const SizedBox(height: 14),

                          // Pressure Unit
                          const Text(
                            'Atmospheric Pressure Unit',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Barometric reading format',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          _buildSegmentedPills<String>(
                            options: const [
                              _PillOption(value: 'hpa', label: 'hPa (Hectopascal)'),
                              _PillOption(value: 'inhg', label: 'inHg (Inches Hg)'),
                            ],
                            selectedValue: pressureUnit,
                            activeColor: glowColor,
                            onChanged: (set) {
                              _triggerHaptic();
                              widget.controller.setPressureUnit(set);
                              _showFeedbackToast('Pressure unit set to $set', icon: Icons.speed_rounded);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =============================================================
                    // 8. SEVERE WEATHER PUSH NOTIFICATIONS
                    // =============================================================
                    _buildSectionHeader('Severe Weather Push Notifications', Icons.notifications_active_rounded, const Color(0xFFFF6B6B)),
                    const SizedBox(height: 10),
                    GlassCard(
                      isDay: isDay,
                      borderRadius: 22,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSwitchRow(
                            title: 'Real-Time Weather Alerts',
                            subtitle: widget.controller.notificationsEnabled
                                ? 'Active — instant high-priority alerts'
                                : 'Disabled — no background notifications',
                            value: widget.controller.notificationsEnabled,
                            activeColor: const Color(0xFFFFD166),
                            icon: Icons.notifications_active_rounded,
                            onChanged: (val) {
                              _triggerHaptic();
                              widget.controller.setNotificationsEnabled(val);
                              _showFeedbackToast(
                                val ? 'Severe weather alerts active' : 'Severe weather alerts paused',
                                icon: Icons.notifications_active_rounded,
                                color: const Color(0xFFFFD166),
                              );
                            },
                          ),

                          const SizedBox(height: 14),
                          _buildDivider(),
                          const SizedBox(height: 12),
                          Text(
                            'Monitored Severe Meteorological Thresholds:',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildAlertChip('🔥 Extreme Heat (>40°C)', const Color(0xFFFF6B6B)),
                              _buildAlertChip('❄️ Freezing Frost (<0°C)', const Color(0xFF00B4D8)),
                              _buildAlertChip('⛈️ Thunderstorms & Lightning', const Color(0xFFFFD166)),
                              _buildAlertChip('🌧️ Torrential Downpour (>90%)', const Color(0xFF48BFE3)),
                              _buildAlertChip('💨 Gale Winds (>50 km/h)', const Color(0xFF90E0EF)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    _triggerHaptic();
                                    final granted = await widget.controller.requestNotificationPermission();
                                    _showFeedbackToast(
                                      granted ? 'Notification permissions granted!' : 'Permission status updated.',
                                      icon: Icons.security_rounded,
                                      color: const Color(0xFF0077B6),
                                    );
                                  },
                                  icon: const Icon(Icons.security_rounded, size: 16),
                                  label: const Text('Permission'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(color: Colors.white.withOpacity(0.35)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    _triggerHaptic(isMedium: true);
                                    await widget.controller.sendTestNotification();
                                    _showFeedbackToast('Test alert sent! Check your notification shade.', icon: Icons.send_rounded, color: const Color(0xFF00E676));
                                  },
                                  icon: const Icon(Icons.send_rounded, size: 16),
                                  label: const Text('Test Alert'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFD166),
                                    foregroundColor: const Color(0xFF0D1B2A),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =============================================================
                    // 9. STORAGE & CACHE
                    // =============================================================
                    _buildSectionHeader('Storage & Offline Cache', Icons.storage_rounded, const Color(0xFF90E0EF)),
                    const SizedBox(height: 10),
                    GlassCard(
                      isDay: isDay,
                      borderRadius: 22,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.history_toggle_off_rounded, color: Colors.white, size: 20),
                            ),
                            title: const Text('Clear Recent Searches', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                            subtitle: const Text('Removes persisted city search history', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            trailing: TextButton(
                              onPressed: () async {
                                _triggerHaptic();
                                await widget.controller.clearRecentSearches();
                                _showFeedbackToast('Recent search history cleared.', icon: Icons.delete_sweep_rounded);
                              },
                              child: const Text('Clear', style: TextStyle(color: Color(0xFFFFD166), fontWeight: FontWeight.w700)),
                            ),
                          ),
                          _buildDivider(),
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.cached_rounded, color: Colors.white, size: 20),
                            ),
                            title: const Text('Purge Offline Cache', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                            subtitle: const Text('Forces clean atmospheric reload on next launch', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            trailing: TextButton(
                              onPressed: () async {
                                _triggerHaptic();
                                await widget.controller.clearCache();
                                _showFeedbackToast('Offline weather cache purged.', icon: Icons.refresh_rounded);
                              },
                              child: const Text('Purge', style: TextStyle(color: Color(0xFFFFD166), fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =============================================================
                    // 10. ATTRIBUTION & ASSIGNMENT CREDITS
                    // =============================================================
                    GlassCard(
                      isDay: isDay,
                      borderRadius: 22,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  'assets/icons/solunair_logo.png',
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Solunair 3D Atmospheric Intelligence',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Devixo Solutions • Task 02',
                                      style: TextStyle(
                                        color: glowColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Solunair Weather Forecast Mobile Application built with Flutter, Dart & Reactive Architecture.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Version 1.0.0 (Production Release)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Zero-Latency Architecture',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: glowColor, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // REUSABLE OVERFLOW-PROOF UI HELPERS
  // ===========================================================================

  /// Full-width segmented pill tabs that divide space equally and never overflow
  Widget _buildSegmentedPills<T>({
    required List<_PillOption<T>> options,
    required T selectedValue,
    required ValueChanged<T> onChanged,
    Color activeColor = const Color(0xFF00B4D8),
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = opt.value == selectedValue;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor.withOpacity(0.35) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? activeColor.withOpacity(0.7) : Colors.transparent,
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: activeColor.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (opt.icon != null) ...[
                      Icon(
                        opt.icon,
                        size: 15,
                        color: isSelected ? Colors.white : Colors.white60,
                      ),
                      const SizedBox(height: 3),
                    ],
                    Text(
                      opt.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    if (opt.sublabel != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        opt.sublabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.white38,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Interactive selectable card with smooth animated border and glowing feedback
  Widget _buildSelectableCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.2) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor.withOpacity(0.8) : Colors.white.withOpacity(0.15),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? activeColor : Colors.white70, size: 22),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Consistent Setting Row with switch and leading icon
  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: activeColor.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: activeColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: value,
          activeColor: activeColor,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildNetworkMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color accentColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: accentColor, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    String title,
    String subtitle,
    String value,
    String current,
    IconData icon,
  ) {
    final isSelected = value == current;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        _triggerHaptic();
        widget.controller.setThemeMode(value);
        _showFeedbackToast('Theme updated: $title', icon: icon, color: const Color(0xFFFFD166));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFD166).withOpacity(0.2) : Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? const Color(0xFFFFD166) : Colors.white70, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFFFFD166), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withOpacity(0.12), height: 1);
  }
}

class _PillOption<T> {
  final T value;
  final String label;
  final String? sublabel;
  final IconData? icon;

  const _PillOption({
    required this.value,
    required this.label,
    this.sublabel,
    this.icon,
  });
}
