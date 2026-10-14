import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/network/weather_api_client.dart';
import 'core/repositories/weather_repository.dart';
import 'core/storage/preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/weather/controllers/weather_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService.initialize();
  await NotificationService.requestPermission();

  // Set immersive edge-to-edge system overlays
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize persistent preferences
  final prefsService = await PreferencesService.create();

  // Initialize network client and repository
  final apiClient = WeatherApiClient();
  final repository = WeatherRepositoryImpl(
    apiClient: apiClient,
    prefs: prefsService,
  );

  // Initialize core state controller
  final weatherController = WeatherController(
    repository: repository,
    prefs: prefsService,
  );

  runApp(SolunairApp(controller: weatherController));
}

class SolunairApp extends StatelessWidget {
  final WeatherController controller;

  const SolunairApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        ThemeMode themeMode;
        switch (controller.themeMode) {
          case 'light':
            themeMode = ThemeMode.light;
            break;
          case 'dark':
            themeMode = ThemeMode.dark;
            break;
          case 'system':
            themeMode = ThemeMode.system;
            break;
          case 'adaptive':
          default:
            themeMode = controller.isDayEffective ? ThemeMode.light : ThemeMode.dark;
            break;
        }

        return MaterialApp(
          title: 'Solunair Weather',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.buildThemeData(isDark: false),
          darkTheme: AppTheme.buildThemeData(isDark: true),
          themeMode: themeMode,
          home: SplashScreen(controller: controller),
        );
      },
    );
  }
}
