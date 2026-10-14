/// Normalized snapshot of weather data for any location.
class WeatherSnapshot {
  final String cityName;
  final String region;
  final String country;
  final double latitude;
  final double longitude;
  final String localTime;
  final DateTime lastUpdated;

  final double temperatureC;
  final double feelsLikeC;
  final double tempMinC;
  final double tempMaxC;

  final String conditionText;
  final int conditionCode;
  final String iconUrl;
  final bool isDay;

  final int humidity;
  final double windKph;
  final String windDirection;
  final int windDegree;
  final double windGustKph;

  final double pressureHpa;
  final double visibilityKm;
  final double uvIndex;
  final int cloudPercent;

  final double precipMm;
  final int chanceOfRain;

  final String sunrise;
  final String sunset;

  final String airQualityCategory;
  final double? pm2_5;
  final double? pm10;

  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  final bool isCached;
  final String providerName;

  const WeatherSnapshot({
    required this.cityName,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.localTime,
    required this.lastUpdated,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.tempMinC,
    required this.tempMaxC,
    required this.conditionText,
    required this.conditionCode,
    required this.iconUrl,
    required this.isDay,
    required this.humidity,
    required this.windKph,
    required this.windDirection,
    required this.windDegree,
    this.windGustKph = 0.0,
    required this.pressureHpa,
    required this.visibilityKm,
    required this.uvIndex,
    required this.cloudPercent,
    required this.precipMm,
    required this.chanceOfRain,
    required this.sunrise,
    required this.sunset,
    this.airQualityCategory = 'Moderate',
    this.pm2_5,
    this.pm10,
    required this.hourlyForecast,
    required this.dailyForecast,
    this.isCached = false,
    this.providerName = 'WeatherAPI.com',
  });

  /// Factory to parse standard WeatherAPI.com forecast response
  factory WeatherSnapshot.fromWeatherApiJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final condition = current['condition'] as Map<String, dynamic>? ?? {};
    final forecastObj = json['forecast'] as Map<String, dynamic>? ?? {};
    final forecastDays = (forecastObj['forecastday'] as List<dynamic>?) ?? [];

    // Extract Day Min/Max from the first forecast day
    double minC = (current['temp_c'] as num?)?.toDouble() ?? 20.0;
    double maxC = (current['temp_c'] as num?)?.toDouble() ?? 25.0;
    String sunriseStr = '06:00 AM';
    String sunsetStr = '06:30 PM';
    int rainChance = 0;

    if (forecastDays.isNotEmpty) {
      final firstDay = forecastDays[0] as Map<String, dynamic>;
      final dayData = firstDay['day'] as Map<String, dynamic>? ?? {};
      minC = (dayData['mintemp_c'] as num?)?.toDouble() ?? minC;
      maxC = (dayData['maxtemp_c'] as num?)?.toDouble() ?? maxC;
      rainChance = (dayData['daily_chance_of_rain'] as num?)?.toInt() ?? 0;

      final astro = firstDay['astro'] as Map<String, dynamic>? ?? {};
      sunriseStr = astro['sunrise']?.toString() ?? sunriseStr;
      sunsetStr = astro['sunset']?.toString() ?? sunsetStr;
    }

    // Parse Air Quality if available
    String aqiCategory = 'Good';
    double? pm25Val;
    double? pm10Val;
    final airQuality = current['air_quality'] as Map<String, dynamic>?;
    if (airQuality != null) {
      final usEpa = (airQuality['us-epa-index'] as num?)?.toInt() ?? 1;
      pm25Val = (airQuality['pm2_5'] as num?)?.toDouble();
      pm10Val = (airQuality['pm10'] as num?)?.toDouble();
      switch (usEpa) {
        case 1:
          aqiCategory = 'Good';
          break;
        case 2:
          aqiCategory = 'Moderate';
          break;
        case 3:
          aqiCategory = 'Unhealthy for Sensitive Groups';
          break;
        case 4:
          aqiCategory = 'Unhealthy';
          break;
        case 5:
          aqiCategory = 'Very Unhealthy';
          break;
        case 6:
          aqiCategory = 'Hazardous';
          break;
        default:
          aqiCategory = 'Moderate';
      }
    }

    // Hourly forecast extraction
    final List<HourlyForecast> hourly = [];
    if (forecastDays.isNotEmpty) {
      for (final day in forecastDays) {
        final hours = (day['hour'] as List<dynamic>?) ?? [];
        for (final h in hours) {
          hourly.add(HourlyForecast.fromWeatherApiJson(h as Map<String, dynamic>));
        }
      }
    }

    // Daily forecast extraction
    final List<DailyForecast> daily = [];
    for (final day in forecastDays) {
      daily.add(DailyForecast.fromWeatherApiJson(day as Map<String, dynamic>));
    }

    return WeatherSnapshot(
      cityName: location['name']?.toString() ?? 'Unknown',
      region: location['region']?.toString() ?? '',
      country: location['country']?.toString() ?? 'Pakistan',
      latitude: (location['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (location['lon'] as num?)?.toDouble() ?? 0.0,
      localTime: location['localtime']?.toString() ?? '',
      lastUpdated: DateTime.now(),
      temperatureC: (current['temp_c'] as num?)?.toDouble() ?? 0.0,
      feelsLikeC: (current['feelslike_c'] as num?)?.toDouble() ??
          (current['temp_c'] as num?)?.toDouble() ?? 0.0,
      tempMinC: minC,
      tempMaxC: maxC,
      conditionText: condition['text']?.toString() ?? 'Clear',
      conditionCode: (condition['code'] as num?)?.toInt() ?? 1000,
      iconUrl: condition['icon']?.toString() ?? '',
      isDay: ((current['is_day'] as num?)?.toInt() ?? 1) == 1,
      humidity: (current['humidity'] as num?)?.toInt() ?? 50,
      windKph: (current['wind_kph'] as num?)?.toDouble() ?? 0.0,
      windDirection: current['wind_dir']?.toString() ?? 'N',
      windDegree: (current['wind_degree'] as num?)?.toInt() ?? 0,
      windGustKph: (current['gust_kph'] as num?)?.toDouble() ?? 0.0,
      pressureHpa: (current['pressure_mb'] as num?)?.toDouble() ?? 1013.0,
      visibilityKm: (current['vis_km'] as num?)?.toDouble() ?? 10.0,
      uvIndex: (current['uv'] as num?)?.toDouble() ?? 0.0,
      cloudPercent: (current['cloud'] as num?)?.toInt() ?? 0,
      precipMm: (current['precip_mm'] as num?)?.toDouble() ?? 0.0,
      chanceOfRain: rainChance,
      sunrise: sunriseStr,
      sunset: sunsetStr,
      airQualityCategory: aqiCategory,
      pm2_5: pm25Val,
      pm10: pm10Val,
      hourlyForecast: hourly,
      dailyForecast: daily,
      isCached: false,
      providerName: 'WeatherAPI.com',
    );
  }

  /// Factory to parse Open-Meteo REST response (fallback provider)
  factory WeatherSnapshot.fromOpenMeteoJson({
    required Map<String, dynamic> json,
    required String cityName,
    required String region,
    required String country,
  }) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final dailyMap = json['daily'] as Map<String, dynamic>? ?? {};
    final hourlyMap = json['hourly'] as Map<String, dynamic>? ?? {};

    final isDay = ((current['is_day'] as num?)?.toInt() ?? 1) == 1;
    final wmoCode = (current['weather_code'] as num?)?.toInt() ?? 0;
    final conditionDesc = _mapWmoCodeToCondition(wmoCode);

    final dailyMinList = (dailyMap['temperature_2m_min'] as List<dynamic>?) ?? [];
    final dailyMaxList = (dailyMap['temperature_2m_max'] as List<dynamic>?) ?? [];
    final dailyTimes = (dailyMap['time'] as List<dynamic>?) ?? [];
    final dailyCodes = (dailyMap['weather_code'] as List<dynamic>?) ?? [];
    final dailyRainProb = (dailyMap['precipitation_probability_max'] as List<dynamic>?) ?? [];
    final dailySunrise = (dailyMap['sunrise'] as List<dynamic>?) ?? [];
    final dailySunset = (dailyMap['sunset'] as List<dynamic>?) ?? [];

    double minC = dailyMinList.isNotEmpty ? (dailyMinList[0] as num).toDouble() : (current['temperature_2m'] as num?)?.toDouble() ?? 20.0;
    double maxC = dailyMaxList.isNotEmpty ? (dailyMaxList[0] as num).toDouble() : (current['temperature_2m'] as num?)?.toDouble() ?? 25.0;

    String sunriseStr = '06:00 AM';
    String sunsetStr = '06:30 PM';
    if (dailySunrise.isNotEmpty) {
      final s = dailySunrise[0].toString();
      sunriseStr = s.contains('T') ? s.split('T').last : s;
    }
    if (dailySunset.isNotEmpty) {
      final s = dailySunset[0].toString();
      sunsetStr = s.contains('T') ? s.split('T').last : s;
    }

    final int rainChance = dailyRainProb.isNotEmpty ? (dailyRainProb[0] as num).toInt() : 0;

    // Daily forecast list
    final List<DailyForecast> dailyList = [];
    for (int i = 0; i < dailyTimes.length && i < 7; i++) {
      final dateStr = dailyTimes[i].toString();
      final dt = DateTime.tryParse(dateStr) ?? DateTime.now().add(Duration(days: i));
      final code = i < dailyCodes.length ? (dailyCodes[i] as num).toInt() : 0;
      final cDesc = _mapWmoCodeToCondition(code);

      dailyList.add(DailyForecast(
        date: dateStr,
        dayOfWeek: _dayName(dt.weekday),
        tempMinC: i < dailyMinList.length ? (dailyMinList[i] as num).toDouble() : minC,
        tempMaxC: i < dailyMaxList.length ? (dailyMaxList[i] as num).toDouble() : maxC,
        conditionText: cDesc,
        conditionCode: code,
        iconUrl: '',
        chanceOfRain: i < dailyRainProb.length ? (dailyRainProb[i] as num).toInt() : 0,
        uvIndex: 4.0,
      ));
    }

    // Hourly forecast list
    final List<HourlyForecast> hourlyList = [];
    final hourlyTimes = (hourlyMap['time'] as List<dynamic>?) ?? [];
    final hourlyTemps = (hourlyMap['temperature_2m'] as List<dynamic>?) ?? [];
    final hourlyCodes = (hourlyMap['weather_code'] as List<dynamic>?) ?? [];
    final hourlyIsDay = (hourlyMap['is_day'] as List<dynamic>?) ?? [];
    final hourlyPrecipProb = (hourlyMap['precipitation_probability'] as List<dynamic>?) ?? [];

    final now = DateTime.now();
    for (int i = 0; i < hourlyTimes.length; i++) {
      final tStr = hourlyTimes[i].toString();
      final dt = DateTime.tryParse(tStr);
      if (dt != null && (dt.isAfter(now.subtract(const Duration(hours: 1))) || i >= hourlyTimes.length - 24)) {
        if (hourlyList.length < 24) {
          final hCode = i < hourlyCodes.length ? (hourlyCodes[i] as num).toInt() : 0;
          hourlyList.add(HourlyForecast(
            time: tStr,
            tempC: i < hourlyTemps.length ? (hourlyTemps[i] as num).toDouble() : 20.0,
            conditionText: _mapWmoCodeToCondition(hCode),
            conditionCode: hCode,
            iconUrl: '',
            chanceOfRain: i < hourlyPrecipProb.length ? (hourlyPrecipProb[i] as num).toInt() : 0,
            isDay: i < hourlyIsDay.length ? ((hourlyIsDay[i] as num).toInt() == 1) : true,
          ));
        }
      }
    }

    return WeatherSnapshot(
      cityName: cityName,
      region: region,
      country: country,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      localTime: DateTime.now().toIso8601String(),
      lastUpdated: DateTime.now(),
      temperatureC: (current['temperature_2m'] as num?)?.toDouble() ?? 24.0,
      feelsLikeC: (current['apparent_temperature'] as num?)?.toDouble() ??
          (current['temperature_2m'] as num?)?.toDouble() ?? 24.0,
      tempMinC: minC,
      tempMaxC: maxC,
      conditionText: conditionDesc,
      conditionCode: wmoCode,
      iconUrl: '',
      isDay: isDay,
      humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 50,
      windKph: (current['wind_speed_10m'] as num?)?.toDouble() ?? 10.0,
      windDirection: _mapDegreeToDirection((current['wind_direction_10m'] as num?)?.toInt() ?? 0),
      windDegree: (current['wind_direction_10m'] as num?)?.toInt() ?? 0,
      pressureHpa: (current['surface_pressure'] as num?)?.toDouble() ?? 1013.0,
      visibilityKm: 10.0,
      uvIndex: 5.0,
      cloudPercent: 20,
      precipMm: (current['precipitation'] as num?)?.toDouble() ?? 0.0,
      chanceOfRain: rainChance,
      sunrise: sunriseStr,
      sunset: sunsetStr,
      airQualityCategory: 'Good',
      hourlyForecast: hourlyList,
      dailyForecast: dailyList,
      isCached: false,
      providerName: 'Open-Meteo',
    );
  }

  /// Factory to parse OpenWeatherMap current and 5-day forecast responses
  factory WeatherSnapshot.fromOpenWeatherJson({
    required Map<String, dynamic> currentJson,
    required Map<String, dynamic> forecastJson,
    String? region,
    String? cityNameOverride,
  }) {
    final weatherList = (currentJson['weather'] as List<dynamic>?) ?? [];
    final firstWeather = weatherList.isNotEmpty ? (weatherList[0] as Map<String, dynamic>) : <String, dynamic>{};
    final main = currentJson['main'] as Map<String, dynamic>? ?? {};
    final wind = currentJson['wind'] as Map<String, dynamic>? ?? {};
    final clouds = currentJson['clouds'] as Map<String, dynamic>? ?? {};
    final sys = currentJson['sys'] as Map<String, dynamic>? ?? {};
    final coord = currentJson['coord'] as Map<String, dynamic>? ?? {};

    final conditionId = (firstWeather['id'] as num?)?.toInt() ?? 800;
    final conditionMain = firstWeather['main']?.toString() ?? 'Clear';
    final conditionDesc = firstWeather['description']?.toString() ?? conditionMain;
    final iconCode = firstWeather['icon']?.toString() ?? '01d';
    final isDay = iconCode.endsWith('d');

    // Temperatures
    final tempC = (main['temp'] as num?)?.toDouble() ?? 25.0;
    final feelsLikeC = (main['feels_like'] as num?)?.toDouble() ?? tempC;
    double minC = (main['temp_min'] as num?)?.toDouble() ?? (tempC - 3.0);
    double maxC = (main['temp_max'] as num?)?.toDouble() ?? (tempC + 3.0);

    // Wind: OpenWeather speed in m/s -> convert to km/h (* 3.6)
    final windSpeedMs = (wind['speed'] as num?)?.toDouble() ?? 0.0;
    final windKph = windSpeedMs * 3.6;
    final windDeg = (wind['deg'] as num?)?.toInt() ?? 0;
    final windGustMs = (wind['gust'] as num?)?.toDouble();
    final windGustKph = windGustMs != null ? windGustMs * 3.6 : 0.0;

    // Visibility: OpenWeather in meters -> convert to km (/ 1000)
    final visMeters = (currentJson['visibility'] as num?)?.toDouble() ?? 10000.0;
    final visKm = visMeters / 1000.0;

    final cityObj = forecastJson['city'] as Map<String, dynamic>? ?? {};
    final timezoneOffsetSec = (cityObj['timezone'] as num?)?.toInt() ??
        (currentJson['timezone'] as num?)?.toInt() ?? 0;

    // Sunrise & Sunset (Unix timestamps converted to local city time)
    final sunriseEpoch = (sys['sunrise'] as num?)?.toInt();
    final sunsetEpoch = (sys['sunset'] as num?)?.toInt();
    String sunriseStr = '06:00 AM';
    String sunsetStr = '06:00 PM';
    if (sunriseEpoch != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(sunriseEpoch * 1000, isUtc: true)
          .add(Duration(seconds: timezoneOffsetSec));
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minStr = dt.minute.toString().padLeft(2, '0');
      sunriseStr = '${hour.toString().padLeft(2, '0')}:$minStr $period';
    }
    if (sunsetEpoch != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(sunsetEpoch * 1000, isUtc: true)
          .add(Duration(seconds: timezoneOffsetSec));
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minStr = dt.minute.toString().padLeft(2, '0');
      sunsetStr = '${hour.toString().padLeft(2, '0')}:$minStr $period';
    }

    // Hourly Forecasts: Extract raw 3-hour nodes with local time and interpolate 1-hour steps
    final forecastList = (forecastJson['list'] as List<dynamic>?) ?? [];
    final List<HourlyForecast> hourlyList = [];
    final Map<String, List<Map<String, dynamic>>> dailyGroups = {};
    final List<_OpenWeatherRawNode> rawNodes = [];

    for (final item in forecastList) {
      final fMap = item as Map<String, dynamic>;
      final fDtEpoch = (fMap['dt'] as num?)?.toInt();
      DateTime localDt;
      if (fDtEpoch != null) {
        localDt = DateTime.fromMillisecondsSinceEpoch(fDtEpoch * 1000, isUtc: true)
            .add(Duration(seconds: timezoneOffsetSec));
      } else {
        final fDtTxt = fMap['dt_txt']?.toString() ?? '';
        localDt = DateTime.tryParse(fDtTxt.replaceFirst(' ', 'T')) ?? DateTime.now();
      }

      final fMain = fMap['main'] as Map<String, dynamic>? ?? {};
      final fWeatherList = (fMap['weather'] as List<dynamic>?) ?? [];
      final fWeather = fWeatherList.isNotEmpty ? (fWeatherList[0] as Map<String, dynamic>) : <String, dynamic>{};
      final fPop = (fMap['pop'] as num?)?.toDouble() ?? 0.0;
      final fRainChance = (fPop * 100).round();
      final fTemp = (fMain['temp'] as num?)?.toDouble() ?? 20.0;
      final fIcon = fWeather['icon']?.toString() ?? '01d';
      final fIsDay = fIcon.endsWith('d');
      final fCode = (fWeather['id'] as num?)?.toInt() ?? 800;
      final fCondition = fWeather['main']?.toString() ?? 'Clear';

      rawNodes.add(_OpenWeatherRawNode(
        localDt: localDt,
        tempC: fTemp,
        conditionText: fCondition,
        conditionCode: fCode,
        iconUrl: 'https://openweathermap.org/img/wn/$fIcon@2x.png',
        chanceOfRain: fRainChance,
        isDay: fIsDay,
      ));

      // Group into daily buckets by exact local date
      final localDateKey = "${localDt.year}-${localDt.month.toString().padLeft(2, '0')}-${localDt.day.toString().padLeft(2, '0')}";
      dailyGroups.putIfAbsent(localDateKey, () => []).add(fMap);
    }

    // Interpolate sequential 1-hour intervals between 3-hour forecast points
    for (int i = 0; i < rawNodes.length; i++) {
      final current = rawNodes[i];
      hourlyList.add(HourlyForecast(
        time: current.localDt.toIso8601String(),
        tempC: current.tempC,
        conditionText: current.conditionText,
        conditionCode: current.conditionCode,
        iconUrl: current.iconUrl,
        chanceOfRain: current.chanceOfRain,
        isDay: current.isDay,
      ));

      // Interpolate intermediate 1-hour steps
      if (i + 1 < rawNodes.length) {
        final next = rawNodes[i + 1];
        final diffHours = next.localDt.difference(current.localDt).inHours;
        if (diffHours >= 2 && diffHours <= 4) {
          for (int h = 1; h < diffHours; h++) {
            final fraction = h / diffHours;
            final interpTime = current.localDt.add(Duration(hours: h));
            final interpTemp = current.tempC + (next.tempC - current.tempC) * fraction;
            final interpRain = (current.chanceOfRain + (next.chanceOfRain - current.chanceOfRain) * fraction).round();
            final useNext = fraction >= 0.5;
            final interpCondition = useNext ? next.conditionText : current.conditionText;
            final interpCode = useNext ? next.conditionCode : current.conditionCode;
            final interpIsDay = interpTime.hour >= 6 && interpTime.hour < 19;
            final interpIcon = useNext ? next.iconUrl : current.iconUrl;

            hourlyList.add(HourlyForecast(
              time: interpTime.toIso8601String(),
              tempC: interpTemp,
              conditionText: interpCondition,
              conditionCode: interpCode,
              iconUrl: interpIcon,
              chanceOfRain: interpRain,
              isDay: interpIsDay,
            ));
          }
        }
      }
    }

    // Daily Forecast calculation
    final List<DailyForecast> dailyList = [];
    dailyGroups.forEach((dateKey, items) {
      if (dailyList.length < 7) {
        final dt = DateTime.tryParse(dateKey) ?? DateTime.now();
        double dMin = 999.0;
        double dMax = -999.0;
        int maxRain = 0;
        String dayCondition = 'Clear';
        int dayCode = 800;
        String dayIcon = '01d';

        for (final it in items) {
          final m = it['main'] as Map<String, dynamic>? ?? {};
          final itMin = (m['temp_min'] as num?)?.toDouble() ?? 20.0;
          final itMax = (m['temp_max'] as num?)?.toDouble() ?? 25.0;
          if (itMin < dMin) dMin = itMin;
          if (itMax > dMax) dMax = itMax;

          final itPop = (it['pop'] as num?)?.toDouble() ?? 0.0;
          final rain = (itPop * 100).round();
          if (rain > maxRain) maxRain = rain;

          final wList = (it['weather'] as List<dynamic>?) ?? [];
          if (wList.isNotEmpty) {
            final w = wList[0] as Map<String, dynamic>;
            dayCondition = w['main']?.toString() ?? dayCondition;
            dayCode = (w['id'] as num?)?.toInt() ?? dayCode;
            dayIcon = w['icon']?.toString() ?? dayIcon;
          }
        }

        if (dMin == 999.0) dMin = tempC - 2.0;
        if (dMax == -999.0) dMax = tempC + 3.0;

        dailyList.add(DailyForecast(
          date: dateKey,
          dayOfWeek: _dayName(dt.weekday),
          tempMinC: dMin,
          tempMaxC: dMax,
          conditionText: dayCondition,
          conditionCode: dayCode,
          iconUrl: 'https://openweathermap.org/img/wn/$dayIcon@2x.png',
          chanceOfRain: maxRain,
          uvIndex: 5.0,
        ));
      }
    });

    if (dailyList.isNotEmpty) {
      minC = dailyList[0].tempMinC;
      maxC = dailyList[0].tempMaxC;
    }

    final chanceOfRainToday = dailyList.isNotEmpty ? dailyList[0].chanceOfRain : 0;
    final rawCity = currentJson['name']?.toString() ?? 'Lahore';
    final cityName = (cityNameOverride != null && cityNameOverride.trim().isNotEmpty)
        ? cityNameOverride.trim()
        : rawCity;
    final country = sys['country']?.toString() ?? 'PK';

    return WeatherSnapshot(
      cityName: cityName,
      region: region ?? (country == 'PK' ? 'Punjab, Pakistan' : country),
      country: country == 'PK' ? 'Pakistan' : country,
      latitude: (coord['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (coord['lon'] as num?)?.toDouble() ?? 0.0,
      localTime: DateTime.now().toIso8601String(),
      lastUpdated: DateTime.now(),
      temperatureC: tempC,
      feelsLikeC: feelsLikeC,
      tempMinC: minC,
      tempMaxC: maxC,
      conditionText: _capitalize(conditionDesc),
      conditionCode: conditionId,
      iconUrl: 'https://openweathermap.org/img/wn/$iconCode@2x.png',
      isDay: isDay,
      humidity: (main['humidity'] as num?)?.toInt() ?? 50,
      windKph: windKph,
      windDirection: _mapDegreeToDirection(windDeg),
      windDegree: windDeg,
      windGustKph: windGustKph,
      pressureHpa: (main['pressure'] as num?)?.toDouble() ?? 1013.0,
      visibilityKm: visKm,
      uvIndex: 4.5,
      cloudPercent: (clouds['all'] as num?)?.toInt() ?? 0,
      precipMm: 0.0,
      chanceOfRain: chanceOfRainToday,
      sunrise: sunriseStr,
      sunset: sunsetStr,
      airQualityCategory: 'Good',
      hourlyForecast: hourlyList,
      dailyForecast: dailyList,
      isCached: false,
      providerName: 'OpenWeatherMap',
    );
  }

  /// Create a safe fallback snapshot based on city and current time
  factory WeatherSnapshot.createDefaultFallback({
    String cityName = 'Islamabad',
    String region = 'Islamabad Capital Territory',
    String country = 'Pakistan',
  }) {
    final now = DateTime.now();
    final isDay = now.hour >= 6 && now.hour < 19;
    return WeatherSnapshot(
      cityName: cityName,
      region: region,
      country: country,
      latitude: 33.6844,
      longitude: 73.0479,
      localTime: now.toIso8601String(),
      lastUpdated: now,
      temperatureC: isDay ? 26.0 : 19.0,
      feelsLikeC: isDay ? 27.0 : 18.5,
      tempMinC: 17.0,
      tempMaxC: 29.0,
      conditionText: isDay ? 'Sunny' : 'Clear',
      conditionCode: 1000,
      iconUrl: '',
      isDay: isDay,
      humidity: 48,
      windKph: 12.0,
      windDirection: 'NE',
      windDegree: 45,
      pressureHpa: 1014.0,
      visibilityKm: 10.0,
      uvIndex: isDay ? 6.0 : 0.0,
      cloudPercent: 15,
      precipMm: 0.0,
      chanceOfRain: 5,
      sunrise: '06:12 AM',
      sunset: '06:45 PM',
      airQualityCategory: 'Good',
      hourlyForecast: List.generate(24, (i) {
        final hour = (now.hour + i) % 24;
        final hDay = hour >= 6 && hour < 19;
        return HourlyForecast(
          time: '${hour.toString().padLeft(2, '0')}:00',
          tempC: (22 + (hDay ? 5 : -4)).toDouble(),
          conditionText: hDay ? 'Sunny' : 'Clear',
          conditionCode: 1000,
          iconUrl: '',
          chanceOfRain: 5,
          isDay: hDay,
        );
      }),
      dailyForecast: List.generate(3, (i) {
        final d = now.add(Duration(days: i));
        return DailyForecast(
          date: d.toIso8601String(),
          dayOfWeek: _dayName(d.weekday),
          tempMinC: 18.0,
          tempMaxC: 28.0 + i,
          conditionText: 'Partly Cloudy',
          conditionCode: 1003,
          iconUrl: '',
          chanceOfRain: 10,
          uvIndex: 6.0,
        );
      }),
      isCached: true,
      providerName: 'Offline Cache',
    );
  }

  /// Serialization to JSON for local persistent caching
  Map<String, dynamic> toJson() => {
    'cityName': cityName,
    'region': region,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'localTime': localTime,
    'lastUpdated': lastUpdated.toIso8601String(),
    'temperatureC': temperatureC,
    'feelsLikeC': feelsLikeC,
    'tempMinC': tempMinC,
    'tempMaxC': tempMaxC,
    'conditionText': conditionText,
    'conditionCode': conditionCode,
    'iconUrl': iconUrl,
    'isDay': isDay,
    'humidity': humidity,
    'windKph': windKph,
    'windDirection': windDirection,
    'windDegree': windDegree,
    'windGustKph': windGustKph,
    'pressureHpa': pressureHpa,
    'visibilityKm': visibilityKm,
    'uvIndex': uvIndex,
    'cloudPercent': cloudPercent,
    'precipMm': precipMm,
    'chanceOfRain': chanceOfRain,
    'sunrise': sunrise,
    'sunset': sunset,
    'airQualityCategory': airQualityCategory,
    'pm2_5': pm2_5,
    'pm10': pm10,
    'hourlyForecast': hourlyForecast.map((h) => h.toJson()).toList(),
    'dailyForecast': dailyForecast.map((d) => d.toJson()).toList(),
    'providerName': providerName,
  };

  factory WeatherSnapshot.fromCachedJson(Map<String, dynamic> json) {
    return WeatherSnapshot(
      cityName: json['cityName'] as String? ?? 'Islamabad',
      region: json['region'] as String? ?? '',
      country: json['country'] as String? ?? 'Pakistan',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      localTime: json['localTime'] as String? ?? '',
      lastUpdated: DateTime.tryParse(json['lastUpdated']?.toString() ?? '') ?? DateTime.now(),
      temperatureC: (json['temperatureC'] as num?)?.toDouble() ?? 25.0,
      feelsLikeC: (json['feelsLikeC'] as num?)?.toDouble() ?? 25.0,
      tempMinC: (json['tempMinC'] as num?)?.toDouble() ?? 18.0,
      tempMaxC: (json['tempMaxC'] as num?)?.toDouble() ?? 28.0,
      conditionText: json['conditionText'] as String? ?? 'Clear',
      conditionCode: (json['conditionCode'] as num?)?.toInt() ?? 1000,
      iconUrl: json['iconUrl'] as String? ?? '',
      isDay: json['isDay'] as bool? ?? true,
      humidity: (json['humidity'] as num?)?.toInt() ?? 50,
      windKph: (json['windKph'] as num?)?.toDouble() ?? 10.0,
      windDirection: json['windDirection'] as String? ?? 'N',
      windDegree: (json['windDegree'] as num?)?.toInt() ?? 0,
      windGustKph: (json['windGustKph'] as num?)?.toDouble() ?? 0.0,
      pressureHpa: (json['pressureHpa'] as num?)?.toDouble() ?? 1013.0,
      visibilityKm: (json['visibilityKm'] as num?)?.toDouble() ?? 10.0,
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 5.0,
      cloudPercent: (json['cloudPercent'] as num?)?.toInt() ?? 0,
      precipMm: (json['precipMm'] as num?)?.toDouble() ?? 0.0,
      chanceOfRain: (json['chanceOfRain'] as num?)?.toInt() ?? 0,
      sunrise: json['sunrise'] as String? ?? '06:00 AM',
      sunset: json['sunset'] as String? ?? '06:30 PM',
      airQualityCategory: json['airQualityCategory'] as String? ?? 'Good',
      pm2_5: (json['pm2_5'] as num?)?.toDouble(),
      pm10: (json['pm10'] as num?)?.toDouble(),
      hourlyForecast: ((json['hourlyForecast'] as List<dynamic>?) ?? [])
          .map((h) => HourlyForecast.fromCachedJson(h as Map<String, dynamic>))
          .toList(),
      dailyForecast: ((json['dailyForecast'] as List<dynamic>?) ?? [])
          .map((d) => DailyForecast.fromCachedJson(d as Map<String, dynamic>))
          .toList(),
      isCached: true,
      providerName: json['providerName'] as String? ?? 'Cache',
    );
  }

  static String _dayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Today';
    }
  }

  static String _mapWmoCodeToCondition(int code) {
    if (code == 0) return 'Clear Sky';
    if (code == 1) return 'Mainly Clear';
    if (code == 2) return 'Partly Cloudy';
    if (code == 3) return 'Overcast';
    if (code >= 45 && code <= 48) return 'Foggy';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 61 && code <= 65) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Cloudy';
  }

  static String _mapDegreeToDirection(int deg) {
    const directions = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    final idx = ((deg + 11.25) / 22.5).floor() % 16;
    return directions[idx];
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }
}

/// Hourly forecast item
class HourlyForecast {
  final String time;
  final double tempC;
  final String conditionText;
  final int conditionCode;
  final String iconUrl;
  final int chanceOfRain;
  final bool isDay;

  const HourlyForecast({
    required this.time,
    required this.tempC,
    required this.conditionText,
    required this.conditionCode,
    required this.iconUrl,
    required this.chanceOfRain,
    required this.isDay,
  });

  factory HourlyForecast.fromWeatherApiJson(Map<String, dynamic> json) {
    final condition = json['condition'] as Map<String, dynamic>? ?? {};
    return HourlyForecast(
      time: json['time']?.toString() ?? '',
      tempC: (json['temp_c'] as num?)?.toDouble() ?? 0.0,
      conditionText: condition['text']?.toString() ?? 'Clear',
      conditionCode: (condition['code'] as num?)?.toInt() ?? 1000,
      iconUrl: condition['icon']?.toString() ?? '',
      chanceOfRain: (json['chance_of_rain'] as num?)?.toInt() ?? 0,
      isDay: ((json['is_day'] as num?)?.toInt() ?? 1) == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'time': time,
    'tempC': tempC,
    'conditionText': conditionText,
    'conditionCode': conditionCode,
    'iconUrl': iconUrl,
    'chanceOfRain': chanceOfRain,
    'isDay': isDay,
  };

  factory HourlyForecast.fromCachedJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'] as String? ?? '',
      tempC: (json['tempC'] as num?)?.toDouble() ?? 20.0,
      conditionText: json['conditionText'] as String? ?? 'Clear',
      conditionCode: (json['conditionCode'] as num?)?.toInt() ?? 1000,
      iconUrl: json['iconUrl'] as String? ?? '',
      chanceOfRain: (json['chanceOfRain'] as num?)?.toInt() ?? 0,
      isDay: json['isDay'] as bool? ?? true,
    );
  }
}

/// Daily forecast item
class DailyForecast {
  final String date;
  final String dayOfWeek;
  final double tempMinC;
  final double tempMaxC;
  final String conditionText;
  final int conditionCode;
  final String iconUrl;
  final int chanceOfRain;
  final double uvIndex;

  const DailyForecast({
    required this.date,
    required this.dayOfWeek,
    required this.tempMinC,
    required this.tempMaxC,
    required this.conditionText,
    required this.conditionCode,
    required this.iconUrl,
    required this.chanceOfRain,
    required this.uvIndex,
  });

  factory DailyForecast.fromWeatherApiJson(Map<String, dynamic> json) {
    final day = json['day'] as Map<String, dynamic>? ?? {};
    final condition = day['condition'] as Map<String, dynamic>? ?? {};
    final dateStr = json['date']?.toString() ?? '';
    final dt = DateTime.tryParse(dateStr) ?? DateTime.now();

    return DailyForecast(
      date: dateStr,
      dayOfWeek: WeatherSnapshot._dayName(dt.weekday),
      tempMinC: (day['mintemp_c'] as num?)?.toDouble() ?? 18.0,
      tempMaxC: (day['maxtemp_c'] as num?)?.toDouble() ?? 28.0,
      conditionText: condition['text']?.toString() ?? 'Clear',
      conditionCode: (condition['code'] as num?)?.toInt() ?? 1000,
      iconUrl: condition['icon']?.toString() ?? '',
      chanceOfRain: (day['daily_chance_of_rain'] as num?)?.toInt() ?? 0,
      uvIndex: (day['uv'] as num?)?.toDouble() ?? 5.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'dayOfWeek': dayOfWeek,
    'tempMinC': tempMinC,
    'tempMaxC': tempMaxC,
    'conditionText': conditionText,
    'conditionCode': conditionCode,
    'iconUrl': iconUrl,
    'chanceOfRain': chanceOfRain,
    'uvIndex': uvIndex,
  };

  factory DailyForecast.fromCachedJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'] as String? ?? '',
      dayOfWeek: json['dayOfWeek'] as String? ?? 'Day',
      tempMinC: (json['tempMinC'] as num?)?.toDouble() ?? 18.0,
      tempMaxC: (json['tempMaxC'] as num?)?.toDouble() ?? 28.0,
      conditionText: json['conditionText'] as String? ?? 'Clear',
      conditionCode: (json['conditionCode'] as num?)?.toInt() ?? 1000,
      iconUrl: json['iconUrl'] as String? ?? '',
      chanceOfRain: (json['chanceOfRain'] as num?)?.toInt() ?? 0,
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 5.0,
    );
  }
}

/// City/Location suggestion model for search-as-you-type
class LocationSuggestion {
  final String name;
  final String region;
  final String country;
  final double latitude;
  final double longitude;

  const LocationSuggestion({
    required this.name,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory LocationSuggestion.fromWeatherApiJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      name: json['name']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      latitude: (json['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['lon'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory LocationSuggestion.fromOpenMeteoJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      name: json['name']?.toString() ?? '',
      region: json['admin1']?.toString() ?? '',
      country: json['country']?.toString() ?? 'Pakistan',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory LocationSuggestion.fromOpenWeatherJson(Map<String, dynamic> json) {
    final countryCode = json['country']?.toString() ?? 'PK';
    final state = json['state']?.toString() ?? '';
    return LocationSuggestion(
      name: json['name']?.toString() ?? '',
      region: state.isNotEmpty ? state : (countryCode == 'PK' ? 'Pakistan' : countryCode),
      country: countryCode == 'PK' ? 'Pakistan' : countryCode,
      latitude: (json['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['lon'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class _OpenWeatherRawNode {
  final DateTime localDt;
  final double tempC;
  final String conditionText;
  final int conditionCode;
  final String iconUrl;
  final int chanceOfRain;
  final bool isDay;

  const _OpenWeatherRawNode({
    required this.localDt,
    required this.tempC,
    required this.conditionText,
    required this.conditionCode,
    required this.iconUrl,
    required this.chanceOfRain,
    required this.isDay,
  });
}
