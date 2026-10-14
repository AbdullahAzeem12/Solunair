# Solunair — 3D Atmospheric Intelligence & Weather Forecast

[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.2-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Feature--Driven%20Repository-success)]()
[![Task](https://img.shields.io/badge/Devixo%20Solutions-Task%2002%20Weather-orange)]()

A modern weather forecast application built for **Devixo Solutions Task 02**. Solunair features a 7-second dynamic 3D weather-reactive splash screen, real-time weather analytics across Pakistan cities and worldwide locations, claymorphic and glassmorphic aesthetics, offline caching via `SharedPreferences`, multi-day forecasts, and a resilient dual-engine REST API architecture (WeatherAPI.com + Open-Meteo fallback).

---

## 🔑 Where to Put Your API Key

You can configure your **WeatherAPI.com** key in any of the following 3 ways:

### Option 1: Direct File Configuration (Recommended)
Open [`lib/core/config/api_config.dart`](lib/core/config/api_config.dart) and paste your key into `defaultWeatherApiKey`:

```dart
class ApiConfig {
  /// Paste your WeatherAPI.com API key here:
  static const String defaultWeatherApiKey = 'PASTE_YOUR_API_KEY_HERE';
  ...
}
```

### Option 2: Live In-App Settings Screen
Launch the app, navigate to the **Settings** tab (the 4th icon on the bottom glass navigation bar), and paste your key into the **"WeatherAPI.com REST Key"** input field. Tap **"Test Connection"** to verify live communication with the server immediately!

### Option 3: Compile / Run-time Parameter
Pass your key when running from terminal:
```bash
flutter run --dart-define=WEATHER_API_KEY=your_weatherapi_key_here
```

> **Note**: Even if no key is entered, Solunair automatically falls back to **Open-Meteo REST API** (100% free, no key required), guaranteeing that the app **works out of the box with live weather for all Pakistani cities** without crashing.

---

## 🌟 Key Features & Requirements

### 1. 7-Second 3D Dynamic Weather-Reactive Splash Screen
- **Instant 0.00s Launch**: Restores cached atmospheric data and saved preferences without network blocking.
- **Real-Time Environment Adaptation**: Smoothly switches between Day (Sunlit Azure/Cyan) and Night (Obsidian/Celestial Indigo) and animates condition effects (Sun coronal rays, rain particles, thunder glow, clouds, stars).
- **Transitional Glowing Typography**: Dual-layer glow and shadows ensuring contrast in both day and night themes.
- **Guaranteed 7-Second Navigation**: Employs a cancellation-safe countdown timer with circular progress and instant "Explore Now" skip transition.

### 2. 3D Glassmorphic Weather Dashboard (Home Screen)
- **Interactive Weather Hero**: Large glossy claymorphic 3D weather illustrations, bold typography, feels-like temp, and a tap-to-switch unit toggle (°C / °F).
- **24-Hour Hourly Forecast Capsules**: Horizontal pill cards with "Now" luminous highlight, timestamps, rain chance percentages, and mini 3D condition icons.
- **Detailed 3D Metric Cards**: Responsive grid for Humidity, Wind Speed (with direction and gusts), UV Index, Air Pressure (hPa/inHg), Visibility (km/mi), Rain probability, and Air Quality (AQI PM2.5).
- **Curved Sun Arc Horizon**: Real-time daylight progression arc tracking current sun position with Sunrise and Sunset timestamps.
- **Smart Advisory & Living Index**: Context-aware recommendations (umbrella advisories, UV protection alerts, heat warnings).

### 3. Pakistan Cities Explorer & Search Engine
- **Whole Pakistan Coverage**: Curated catalogue across all provinces and administrative territories:
  - **Punjab** (Lahore, Faisalabad, Rawalpindi, Multan, Gujranwala, Sialkot, Bahawalpur, Murree...)
  - **Sindh** (Karachi, Hyderabad, Sukkur, Larkana, Nawabshah, Mirpur Khas...)
  - **Khyber Pakhtunkhwa** (Peshawar, Abbottabad, Mardan, Mingora Swat, Chitral...)
  - **Balochistan** (Quetta, Gwadar, Turbat, Khuzdar, Ziarat...)
  - **Islamabad Capital Territory** (Islamabad)
  - **Gilgit-Baltistan** (Gilgit, Skardu, Hunza...)
  - **Azad Jammu & Kashmir** (Muzaffarabad, Mirpur, Rawalakot...)
- **Search-as-you-type with Debouncing**: Instant fuzzy matching against Pakistani database and global geocoding REST endpoints.
- **Persistent Recent Searches (Bonus Requirement)**: Stored in `SharedPreferences` with one-tap quick selection and clear history action.
- **Favorite Locations**: Pin/unpin favorite cities with persistent storage.

### 4. Multi-Day Forecast (3-Day to 7-Day)
- Tomorrow highlight card with weather condition artwork, rain probability, and high/low spans.
- Extended forecast overview cards with temperature range bars.

### 5. Settings & Customization
- **Theme Modes**: Weather Adaptive (follows city condition and day/night), Forced Light, Forced Dark, System.
- **Unit Conversions**: Temperature (°C / °F), Wind Speed (km/h, mph, m/s), Pressure (hPa, inHg).
- **Cache Management**: Offline cache purging and search history reset.
- **Attribution & Diagnostics**: Devixo Solutions Task 02 credits, active provider status, and connection diagnostics.

---

## 🏛 Project Architecture

```
lib/
├── main.dart                                    # Application entrypoint & dependency injection
├── core/
│   ├── config/
│   │   └── api_config.dart                      # WeatherAPI.com & Open-Meteo endpoint config & key
│   ├── models/
│   │   └── weather_models.dart                  # WeatherSnapshot, HourlyForecast, DailyForecast
│   ├── utils/
│   │   ├── unit_converter.dart                  # Unit conversion math (°C/°F, km/h to mph/ms)
│   │   └── weather_condition_mapper.dart        # Condition codes to 3D themes, gradients & glows
│   ├── theme/
│   │   └── app_theme.dart                       # 3D tokens, specular gradients, glow shadows
│   ├── data/
│   │   └── pakistan_cities.dart                 # Database of 50+ Pakistani cities by province
│   ├── storage/
│   │   └── preferences_service.dart             # SharedPreferences implementation (bonus)
│   ├── network/
│   │   ├── api_exceptions.dart                  # Custom domain exception hierarchy
│   │   └── weather_api_client.dart              # REST client using http package
│   └── repositories/
│       └── weather_repository.dart              # Cache validation, request deduplication
└── features/
    ├── shared/widgets/
    │   ├── glass_card.dart                      # Frosted glass card with 3D touch tilt
    │   ├── weather_3d_art.dart                  # Vector 3D claymorphic weather artwork
    │   └── weather_particles.dart               # Rain, star, and solar dust particle canvas
    ├── splash/presentation/
    │   └── splash_screen.dart                   # 7-second dynamic weather splash
    ├── weather/
    │   ├── controllers/
    │   │   └── weather_controller.dart          # Central reactive state controller
    │   └── presentation/
    │       ├── home_screen.dart                 # Main weather dashboard
    │       ├── forecast_screen.dart             # Multi-day forecast screen
    │       └── widgets/                         # Hero, hourly pills, metrics, sun tracker
    ├── cities/presentation/
    │   └── city_explorer_screen.dart            # Pakistan explorer, search & recent searches
    ├── settings/presentation/
    │   └── settings_screen.dart                 # Configuration & API Key manager
    └── navigation/
        └── main_navigation_shell.dart           # Floating 3D glass bottom nav bar
```

---

## 🧪 Testing & Verification

Run the automated test suite:
```bash
# Run all unit and widget tests
flutter test

# Run live REST API integration test (verifies live weather data fetching)
flutter test test/live_api_test.dart

# Run static code analysis (0 warnings, 0 errors)
flutter analyze
```

---

## 🚀 Running the Application

```bash
# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```
