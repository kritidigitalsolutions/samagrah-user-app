import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/localStogare_service/location_storage.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/views/service_pages/location_provider.dart';

class LocationPage extends ConsumerStatefulWidget {
  const LocationPage({super.key});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  bool _isLoading = false;
  String? _currentAddress;
  String? _city;
  String? _state;
  String? _country;
  String? _postalCode;
  double? _latitude;
  double? _longitude;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Icon
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.button.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    size: 60,
                    color: AppColors.button,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Enable Location',
                  style: text26(
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'We need your location to provide you with the best experience and personalized services.',
                  style: text16(color: AppColors.grey600),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Location Details Card
                if (_currentAddress != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.green.withAlpha(100),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Location Detected',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildLocationDetail('Address', _currentAddress!),
                        if (_city != null) _buildLocationDetail('City', _city!),
                        if (_state != null)
                          _buildLocationDetail('State', _state!),
                        if (_country != null)
                          _buildLocationDetail('Country', _country!),
                        if (_postalCode != null)
                          _buildLocationDetail('Postal Code', _postalCode!),
                        if (_latitude != null && _longitude != null)
                          _buildLocationDetail(
                            'Coordinates',
                            '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Get Location Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _getCurrentLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.button,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Get Current Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),

                const SizedBox(height: 12),

                // Continue Button (only show if location is fetched)
                if (_currentAddress != null)
                  ElevatedButton(
                    onPressed: _continueToApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Skip Button
                TextButton(
                  onPressed: _skipLocation,
                  child: Text(
                    'Skip for now',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check and request location permission
      final permission = await Permission.location.request();

      if (permission.isDenied) {
        setState(() {
          _errorMessage =
              'Location permission denied. Please enable it in settings.';
          _isLoading = false;
        });
        return;
      }

      if (permission.isPermanentlyDenied) {
        setState(() {
          _errorMessage =
              'Location permission permanently denied. Please enable it in app settings.';
          _isLoading = false;
        });
        await openAppSettings();
        return;
      }

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them.';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _city = place.locality;
          _state = place.administrativeArea;
          _country = place.country;
          _postalCode = place.postalCode;

          // Build full address
          _currentAddress =
              [
                    place.street,
                    place.subLocality,
                    place.locality,
                    place.administrativeArea,
                    place.country,
                    place.postalCode,
                  ]
                  .where((element) => element != null && element.isNotEmpty)
                  .join(', ');

          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _continueToApp() async {
    if (_currentAddress == null || _latitude == null || _longitude == null) {
      setState(() {
        _errorMessage = "Please fetch location first";
      });
      return;
    }

    // SAVE LOCATION
    await LocationStorage.saveLocation(
      address: _currentAddress!,
      lat: _latitude!,
      lng: _longitude!,
      city: _city!,
      state: _state!,
    );

    ref.read(locationProvider.notifier).state = LocationModel(
      city: _city,
      state: _state,
    );

    // NAVIGATE TO HOME
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _skipLocation() {
    Navigator.pop(context);
  }
}
