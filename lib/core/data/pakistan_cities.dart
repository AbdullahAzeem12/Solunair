/// Curated catalogue of Pakistan cities by province/region with exact coordinates
class PakistanCity {
  final String name;
  final String province;
  final double latitude;
  final double longitude;
  final bool isMajor;

  const PakistanCity({
    required this.name,
    required this.province,
    required this.latitude,
    required this.longitude,
    this.isMajor = false,
  });
}

class PakistanCitiesDatabase {
  PakistanCitiesDatabase._();

  static const List<String> regions = [
    'All Pakistan',
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Islamabad Capital Territory',
    'Gilgit-Baltistan',
    'Azad Jammu and Kashmir',
  ];

  static const List<PakistanCity> cities = [
    // Islamabad Capital Territory
    PakistanCity(name: 'Islamabad', province: 'Islamabad Capital Territory', latitude: 33.6844, longitude: 73.0479, isMajor: true),

    // Punjab
    PakistanCity(name: 'Lahore', province: 'Punjab', latitude: 31.5497, longitude: 74.3436, isMajor: true),
    PakistanCity(name: 'Faisalabad', province: 'Punjab', latitude: 31.4504, longitude: 73.1350, isMajor: true),
    PakistanCity(name: 'Rawalpindi', province: 'Punjab', latitude: 33.5651, longitude: 73.0169, isMajor: true),
    PakistanCity(name: 'Multan', province: 'Punjab', latitude: 30.1575, longitude: 71.5249, isMajor: true),
    PakistanCity(name: 'Gujranwala', province: 'Punjab', latitude: 32.1877, longitude: 74.1945, isMajor: true),
    PakistanCity(name: 'Sialkot', province: 'Punjab', latitude: 32.4945, longitude: 74.5229, isMajor: true),
    PakistanCity(name: 'Bahawalpur', province: 'Punjab', latitude: 29.3544, longitude: 71.6911, isMajor: true),
    PakistanCity(name: 'Sargodha', province: 'Punjab', latitude: 32.0836, longitude: 72.6711),
    PakistanCity(name: 'Sheikhupura', province: 'Punjab', latitude: 31.7131, longitude: 73.9783),
    PakistanCity(name: 'Jhelum', province: 'Punjab', latitude: 32.9405, longitude: 73.7276),
    PakistanCity(name: 'Gujarat', province: 'Punjab', latitude: 32.5742, longitude: 74.0754),
    PakistanCity(name: 'Kasur', province: 'Punjab', latitude: 31.1167, longitude: 74.4500),
    PakistanCity(name: 'Sahiwal', province: 'Punjab', latitude: 30.6682, longitude: 73.1114),
    PakistanCity(name: 'Rahim Yar Khan', province: 'Punjab', latitude: 28.4195, longitude: 70.3026),
    PakistanCity(name: 'Murree', province: 'Punjab', latitude: 33.9070, longitude: 73.3943, isMajor: true),
    PakistanCity(name: 'Attock', province: 'Punjab', latitude: 33.7667, longitude: 72.3667),
    PakistanCity(name: 'Dera Ghazi Khan', province: 'Punjab', latitude: 30.0561, longitude: 70.6348),

    // Sindh
    PakistanCity(name: 'Karachi', province: 'Sindh', latitude: 24.8607, longitude: 67.0011, isMajor: true),
    PakistanCity(name: 'Hyderabad', province: 'Sindh', latitude: 25.3960, longitude: 68.3578, isMajor: true),
    PakistanCity(name: 'Sukkur', province: 'Sindh', latitude: 27.7052, longitude: 68.8574, isMajor: true),
    PakistanCity(name: 'Larkana', province: 'Sindh', latitude: 27.5589, longitude: 68.2120, isMajor: true),
    PakistanCity(name: 'Nawabshah', province: 'Sindh', latitude: 26.2483, longitude: 68.4096),
    PakistanCity(name: 'Mirpur Khas', province: 'Sindh', latitude: 25.5276, longitude: 69.0125),
    PakistanCity(name: 'Thatta', province: 'Sindh', latitude: 24.7474, longitude: 67.9235),
    PakistanCity(name: 'Jacobabad', province: 'Sindh', latitude: 28.2819, longitude: 68.4375),
    PakistanCity(name: 'Badin', province: 'Sindh', latitude: 24.6558, longitude: 68.8384),
    PakistanCity(name: 'Shikarpur', province: 'Sindh', latitude: 27.9556, longitude: 68.6382),

    // Khyber Pakhtunkhwa (KPK)
    PakistanCity(name: 'Peshawar', province: 'Khyber Pakhtunkhwa', latitude: 34.0151, longitude: 71.5249, isMajor: true),
    PakistanCity(name: 'Abbottabad', province: 'Khyber Pakhtunkhwa', latitude: 34.1688, longitude: 73.2215, isMajor: true),
    PakistanCity(name: 'Mardan', province: 'Khyber Pakhtunkhwa', latitude: 34.1989, longitude: 72.0450, isMajor: true),
    PakistanCity(name: 'Mingora', province: 'Khyber Pakhtunkhwa', latitude: 34.7717, longitude: 72.3602, isMajor: true),
    PakistanCity(name: 'Kohat', province: 'Khyber Pakhtunkhwa', latitude: 33.5869, longitude: 71.4414),
    PakistanCity(name: 'Dera Ismail Khan', province: 'Khyber Pakhtunkhwa', latitude: 31.8314, longitude: 70.9019),
    PakistanCity(name: 'Haripur', province: 'Khyber Pakhtunkhwa', latitude: 33.9998, longitude: 72.9341),
    PakistanCity(name: 'Swabi', province: 'Khyber Pakhtunkhwa', latitude: 34.1202, longitude: 72.4698),
    PakistanCity(name: 'Nowshera', province: 'Khyber Pakhtunkhwa', latitude: 34.0153, longitude: 71.9747),
    PakistanCity(name: 'Bannu', province: 'Khyber Pakhtunkhwa', latitude: 32.9861, longitude: 70.6042),
    PakistanCity(name: 'Chitral', province: 'Khyber Pakhtunkhwa', latitude: 35.8510, longitude: 71.7864, isMajor: true),

    // Balochistan
    PakistanCity(name: 'Quetta', province: 'Balochistan', latitude: 30.1798, longitude: 66.9750, isMajor: true),
    PakistanCity(name: 'Gwadar', province: 'Balochistan', latitude: 25.1216, longitude: 62.3254, isMajor: true),
    PakistanCity(name: 'Turbat', province: 'Balochistan', latitude: 26.0031, longitude: 63.0544),
    PakistanCity(name: 'Khuzdar', province: 'Balochistan', latitude: 27.8119, longitude: 66.6186),
    PakistanCity(name: 'Chaman', province: 'Balochistan', latitude: 30.9236, longitude: 66.4512),
    PakistanCity(name: 'Ziarat', province: 'Balochistan', latitude: 30.3824, longitude: 67.7256, isMajor: true),
    PakistanCity(name: 'Sibi', province: 'Balochistan', latitude: 29.5440, longitude: 67.8764),
    PakistanCity(name: 'Hub', province: 'Balochistan', latitude: 25.0253, longitude: 66.8833),

    // Gilgit-Baltistan
    PakistanCity(name: 'Gilgit', province: 'Gilgit-Baltistan', latitude: 35.9221, longitude: 74.3087, isMajor: true),
    PakistanCity(name: 'Skardu', province: 'Gilgit-Baltistan', latitude: 35.2971, longitude: 75.6333, isMajor: true),
    PakistanCity(name: 'Hunza', province: 'Gilgit-Baltistan', latitude: 36.3167, longitude: 74.6500, isMajor: true),
    PakistanCity(name: 'Chilas', province: 'Gilgit-Baltistan', latitude: 35.4129, longitude: 74.0969),
    PakistanCity(name: 'Astore', province: 'Gilgit-Baltistan', latitude: 35.3667, longitude: 74.9000),

    // Azad Jammu and Kashmir
    PakistanCity(name: 'Muzaffarabad', province: 'Azad Jammu and Kashmir', latitude: 34.3700, longitude: 73.4711, isMajor: true),
    PakistanCity(name: 'Mirpur', province: 'Azad Jammu and Kashmir', latitude: 33.1478, longitude: 73.7519, isMajor: true),
    PakistanCity(name: 'Kotli', province: 'Azad Jammu and Kashmir', latitude: 33.5156, longitude: 73.9019),
    PakistanCity(name: 'Rawalakot', province: 'Azad Jammu and Kashmir', latitude: 33.8584, longitude: 73.7604),
    PakistanCity(name: 'Bhimber', province: 'Azad Jammu and Kashmir', latitude: 32.9744, longitude: 74.0789),
  ];

  /// Filter cities by region/province
  static List<PakistanCity> getByRegion(String region) {
    if (region == 'All Pakistan') return cities;
    return cities.where((c) => c.province == region).toList();
  }

  /// Search matching cities by name or province
  static List<PakistanCity> search(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return cities.where((c) => c.isMajor).toList();
    return cities.where((c) =>
      c.name.toLowerCase().contains(cleanQuery) ||
      c.province.toLowerCase().contains(cleanQuery)
    ).toList();
  }
}
