import 'package:shared_preferences/shared_preferences.dart';

class LocationStorage {
  static const _addressKey = "user_address";
  static const _latKey = "user_lat";
  static const _lngKey = "user_lng";
  static const _cityKey = "user_city";
  static const _stateKey = "user_state";

  // Save
  static Future<void> saveLocation({
    required String address,
    required double lat,
    required double lng,
    required String city,
    required String state,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_addressKey, address);
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_lngKey, lng);
    await prefs.setString(_cityKey, city);
    await prefs.setString(_stateKey, state);
  }

  // Get
  static Future<String?> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_addressKey);
  }

  static Future<String?> getCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cityKey);
  }

  static Future<String?> getState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_stateKey);
  }

  static Future<double?> getLat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_latKey);
  }

  static Future<double?> getLng() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_lngKey);
  }
}
