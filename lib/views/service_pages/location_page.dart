// location_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/localStogare_service/location_storage.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/customize_kit_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/brands_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/category_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/ritual_pandit_provider.dart';
import 'package:samagrah/views/service_pages/location_provider.dart';

// ---------------------------------------------------------------------------
// Full city list – for local filter suggestions
// ---------------------------------------------------------------------------
const List<Map<String, String>> _kAllCities = [
  {'city': 'Agra', 'state': 'Uttar Pradesh'},
  {'city': 'Ahmedabad', 'state': 'Gujarat'},
  {'city': 'Allahabad', 'state': 'Uttar Pradesh'},
  {'city': 'Amritsar', 'state': 'Punjab'},
  {'city': 'Aurangabad', 'state': 'Maharashtra'},
  {'city': 'Bengaluru', 'state': 'Karnataka'},
  {'city': 'Bhopal', 'state': 'Madhya Pradesh'},
  {'city': 'Bhubaneswar', 'state': 'Odisha'},
  {'city': 'Chandigarh', 'state': 'Punjab'},
  {'city': 'Chennai', 'state': 'Tamil Nadu'},
  {'city': 'Coimbatore', 'state': 'Tamil Nadu'},
  {'city': 'Dehradun', 'state': 'Uttarakhand'},
  {'city': 'Delhi', 'state': 'Delhi'},
  {'city': 'Faridabad', 'state': 'Haryana'},
  {'city': 'Ghaziabad', 'state': 'Uttar Pradesh'},
  {'city': 'Gurgaon', 'state': 'Haryana'},
  {'city': 'Guwahati', 'state': 'Assam'},
  {'city': 'Hyderabad', 'state': 'Telangana'},
  {'city': 'Indore', 'state': 'Madhya Pradesh'},
  {'city': 'Jaipur', 'state': 'Rajasthan'},
  {'city': 'Jalandhar', 'state': 'Punjab'},
  {'city': 'Jammu', 'state': 'J&K'},
  {'city': 'Jodhpur', 'state': 'Rajasthan'},
  {'city': 'Kanpur', 'state': 'Uttar Pradesh'},
  {'city': 'Kochi', 'state': 'Kerala'},
  {'city': 'Kolkata', 'state': 'West Bengal'},
  {'city': 'Lucknow', 'state': 'Uttar Pradesh'},
  {'city': 'Ludhiana', 'state': 'Punjab'},
  {'city': 'Madurai', 'state': 'Tamil Nadu'},
  {'city': 'Mangalore', 'state': 'Karnataka'},
  {'city': 'Meerut', 'state': 'Uttar Pradesh'},
  {'city': 'Mumbai', 'state': 'Maharashtra'},
  {'city': 'Mysore', 'state': 'Karnataka'},
  {'city': 'Nagpur', 'state': 'Maharashtra'},
  {'city': 'Nashik', 'state': 'Maharashtra'},
  {'city': 'Noida', 'state': 'Uttar Pradesh'},
  {'city': 'Patna', 'state': 'Bihar'},
  {'city': 'Pune', 'state': 'Maharashtra'},
  {'city': 'Raipur', 'state': 'Chhattisgarh'},
  {'city': 'Rajkot', 'state': 'Gujarat'},
  {'city': 'Ranchi', 'state': 'Jharkhand'},
  {'city': 'Surat', 'state': 'Gujarat'},
  {'city': 'Thane', 'state': 'Maharashtra'},
  {'city': 'Thiruvananthapuram', 'state': 'Kerala'},
  {'city': 'Udaipur', 'state': 'Rajasthan'},
  {'city': 'Vadodara', 'state': 'Gujarat'},
  {'city': 'Varanasi', 'state': 'Uttar Pradesh'},
  {'city': 'Vijayawada', 'state': 'Andhra Pradesh'},
  {'city': 'Visakhapatnam', 'state': 'Andhra Pradesh'},
];

// ---------------------------------------------------------------------------
// Popular cities shown as chips when search is empty
// ---------------------------------------------------------------------------
const List<Map<String, String>> _kPopularCities = [
  {'city': 'Delhi', 'state': 'Delhi'},
  {'city': 'Mumbai', 'state': 'Maharashtra'},
  {'city': 'Bengaluru', 'state': 'Karnataka'},
  {'city': 'Hyderabad', 'state': 'Telangana'},
  {'city': 'Chennai', 'state': 'Tamil Nadu'},
  {'city': 'Kolkata', 'state': 'West Bengal'},
  {'city': 'Pune', 'state': 'Maharashtra'},
  {'city': 'Ahmedabad', 'state': 'Gujarat'},
  {'city': 'Jaipur', 'state': 'Rajasthan'},
  {'city': 'Lucknow', 'state': 'Uttar Pradesh'},
  {'city': 'Noida', 'state': 'Uttar Pradesh'},
  {'city': 'Gurgaon', 'state': 'Haryana'},
  {'city': 'Meerut', 'state': 'Uttar Pradesh'},
  {'city': 'Chandigarh', 'state': 'Punjab'},
  {'city': 'Indore', 'state': 'Madhya Pradesh'},
  {'city': 'Surat', 'state': 'Gujarat'},
  {'city': 'Patna', 'state': 'Bihar'},
  {'city': 'Bhopal', 'state': 'Madhya Pradesh'},
];

// ---------------------------------------------------------------------------
// Input mode enum
// ---------------------------------------------------------------------------
enum _InputMode {
  idle, // nothing typed — GPS + popular cities
  citySearch, // text typed — local filter list shown instantly
  cityLoading, // geocoding city in progress
  cityResults, // geocoded city results list
  pincodeSearch, // digits typed but not searched yet
  pincodeLoading, // geocoding pincode in progress
  pincodeResults, // geocoded pincode results list
}

// ---------------------------------------------------------------------------
// LocationPage
// ---------------------------------------------------------------------------
class LocationPage extends ConsumerStatefulWidget {
  const LocationPage({super.key});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  // ── Search field ──────────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  _InputMode _mode = _InputMode.idle;

  // City – local filter (instant, no network)
  List<Map<String, String>> _citySuggestions = [];

  // Geocoded results (both city & pincode share the same list)
  List<Map<String, String>> _resolvedPlaces = [];

  // Errors
  String? _searchError;
  String? _gpsError;

  // GPS loading
  bool _isGpsLoading = false;

  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Input listener — auto-detect pincode vs city
  // ---------------------------------------------------------------------------
  void _onInputChanged() {
    final trimmed = _searchController.text.trim();

    // Clear error whenever user types
    if (_searchError != null) setState(() => _searchError = null);

    if (trimmed.isEmpty) {
      setState(() {
        _mode = _InputMode.idle;
        _citySuggestions = [];
        _resolvedPlaces = [];
      });
      return;
    }

    final isAllDigits = RegExp(r'^\d+$').hasMatch(trimmed);

    if (isAllDigits) {
      // Pincode mode — reset results on every digit change
      setState(() {
        _mode = _InputMode.pincodeSearch;
        _citySuggestions = [];
        _resolvedPlaces = [];
      });
    } else {
      // City mode — show instant local filter
      final query = trimmed.toLowerCase();
      final matched = _kAllCities
          .where(
            (c) =>
                c['city']!.toLowerCase().startsWith(query) ||
                c['city']!.toLowerCase().contains(query),
          )
          .toList();
      setState(() {
        _mode = _InputMode.citySearch;
        _citySuggestions = matched;
        _resolvedPlaces = [];
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Unified geocode lookup — handles both city name and pincode
  // ---------------------------------------------------------------------------
  Future<void> _lookupLocation(bool isFromHome, {String? overrideQuery}) async {
    final input = overrideQuery ?? _searchController.text.trim();
    if (input.isEmpty) return;

    final isPincode = RegExp(r'^\d+$').hasMatch(input);

    if (isPincode && input.length != 6) {
      setState(() => _searchError = 'Please enter a complete 6-digit pincode.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _mode = isPincode ? _InputMode.pincodeLoading : _InputMode.cityLoading;
      _searchError = null;
      _resolvedPlaces = [];
    });

    try {
      final locations = await locationFromAddress('$input, India');

      if (locations.isEmpty) {
        setState(() {
          _searchError =
              'No location found for "$input". Try a different name or pincode.';
          _mode = isPincode ? _InputMode.pincodeSearch : _InputMode.citySearch;
        });
        return;
      }

      final List<Map<String, String>> results = [];

      for (final loc in locations) {
        final placemarks = await placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );

        for (final place in placemarks) {
          final city = place.locality?.isNotEmpty == true
              ? place.locality!
              : place.subAdministrativeArea ?? '';
          final state = place.administrativeArea ?? '';
          final area = place.subLocality?.isNotEmpty == true
              ? place.subLocality!
              : place.name ?? '';
          final street = place.street ?? '';
          final pincode = place.postalCode ?? '';

          if (city.isEmpty) continue;

          final fullAddress = [
            if (street.isNotEmpty) street,
            if (area.isNotEmpty) area,
            city,
            state,
            if (pincode.isNotEmpty) 'India - $pincode' else 'India',
          ].join(', ');

          final key = '$area|$city|$state';
          if (!results.any(
            (r) => '${r['area']}|${r['city']}|${r['state']}' == key,
          )) {
            results.add({
              'city': city,
              'state': state,
              'pincode': pincode,
              'area': area,
              'address': fullAddress,
            });
          }
        }
      }

      if (results.isEmpty) {
        setState(() {
          _searchError =
              'Could not resolve "$input". Try another city or pincode.';
          _mode = isPincode ? _InputMode.pincodeSearch : _InputMode.citySearch;
        });
        return;
      }

      setState(() {
        _resolvedPlaces = results;
        _mode = isPincode ? _InputMode.pincodeResults : _InputMode.cityResults;
      });
    } catch (e) {
      setState(() {
        _searchError = 'Something went wrong. Check internet and try again.';
        _mode = isPincode ? _InputMode.pincodeSearch : _InputMode.citySearch;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final bool isFromHome =
        ModalRoute.of(context)?.settings.arguments as bool? ?? false;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopSection(isFromHome),
              Expanded(child: _buildBody(isFromHome)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top section — title + search field
  // ---------------------------------------------------------------------------
  Widget _buildTopSection(bool isFromHome) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Your City',
            style: text26(
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Search by city name or enter a 6-digit pincode.',
            style: text16(color: AppColors.grey600),
          ),
          const SizedBox(height: 20),
          _buildSearchField(isFromHome),
          if (_searchError != null) ...[
            const SizedBox(height: 10),
            _buildErrorCard(_searchError!),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Unified search field
  // ---------------------------------------------------------------------------
  Widget _buildSearchField(bool isFromHome) {
    final isPincodeMode =
        _mode == _InputMode.pincodeSearch ||
        _mode == _InputMode.pincodeLoading ||
        _mode == _InputMode.pincodeResults;

    final isLoading =
        _mode == _InputMode.cityLoading || _mode == _InputMode.pincodeLoading;

    // Arrow button appears: pincode=6 digits OR city=3+ chars typed
    final inputLen = _searchController.text.trim().length;
    final showSearchArrow =
        !isLoading &&
        _searchController.text.isNotEmpty &&
        (isPincodeMode ? inputLen == 6 : inputLen >= 3);

    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      keyboardType: isPincodeMode ? TextInputType.number : TextInputType.text,
      inputFormatters: isPincodeMode
          ? [FilteringTextInputFormatter.digitsOnly]
          : [],
      maxLength: isPincodeMode ? 6 : null,
      textCapitalization: TextCapitalization.words,
      style: TextStyle(
        fontSize: isPincodeMode ? 18 : 16,
        fontWeight: FontWeight.w600,
        letterSpacing: isPincodeMode ? 3 : 0,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: 'Search city or enter pincode...',
        hintStyle: TextStyle(
          color: AppColors.grey600,
          fontSize: 15,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isPincodeMode ? Icons.pin_drop_rounded : Icons.search_rounded,
            key: ValueKey(isPincodeMode),
            size: 22,
            color: isPincodeMode ? AppColors.button : AppColors.grey600,
          ),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(13),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : showSearchArrow
                  ? _buildArrowButton(isFromHome)
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: _clearSearch,
                    )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: _inputBorder(),
        enabledBorder: _inputBorder(),
        focusedBorder: _inputBorder(focused: true),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 16,
        ),
      ),
      onSubmitted: (_) => _lookupLocation(isFromHome),
    );
  }

  // Orange arrow button inside field
  Widget _buildArrowButton(bool isFromHome) {
    return GestureDetector(
      onTap: () => _lookupLocation(isFromHome),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.button,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder({bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: focused
          ? BorderSide(color: AppColors.button, width: 1.8)
          : BorderSide(color: AppColors.grey900.withAlpha(30)),
    );
  }

  // ---------------------------------------------------------------------------
  // Body router
  // ---------------------------------------------------------------------------
  Widget _buildBody(bool isFromHome) {
    switch (_mode) {
      case _InputMode.citySearch:
        return _buildCitySuggestions(isFromHome);
      case _InputMode.cityLoading:
      case _InputMode.pincodeLoading:
        return _buildLoadingHint();
      case _InputMode.cityResults:
      case _InputMode.pincodeResults:
        return _buildResolvedResults(isFromHome);
      case _InputMode.pincodeSearch:
        return _buildPincodeHint();
      case _InputMode.idle:
        return _buildDefaultContent(isFromHome);
    }
  }

  // ---------------------------------------------------------------------------
  // City suggestions — instant local filter list
  // ---------------------------------------------------------------------------
  Widget _buildCitySuggestions(bool isFromHome) {
    final typedCity = _searchController.text.trim();

    // "Use X as city" tile — always at top, tapping geocodes it
    final useTypedTile = _buildSuggestionTile(
      icon: Icons.add_location_alt_rounded,
      title: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: [
            const TextSpan(text: 'Search "'),
            TextSpan(
              text: _toTitleCase(typedCity),
              style: TextStyle(color: AppColors.button),
            ),
            const TextSpan(text: '"'),
          ],
        ),
      ),
      subtitle: 'Tap to find areas for this city',
      trailingIcon: Icons.search_rounded,
      onTap: () => _lookupLocation(isFromHome),
    );

    if (_citySuggestions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            useTypedTile,
            const SizedBox(height: 20),
            Center(
              child: Text(
                'No city matched.\nTap "Search" above to look up via location.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.grey600),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: _citySuggestions.length + 1,

      separatorBuilder: (_, __) =>
          Divider(height: 1, color: AppColors.grey900.withAlpha(15)),
      itemBuilder: (context, index) {
        if (index == 0) return useTypedTile;
        final item = _citySuggestions[index - 1];
        return _buildSuggestionTile(
          icon: Icons.location_on_rounded,
          title: Text(
            item['city']!,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: item['state']!,
          trailingIcon: Icons.north_west_rounded,
          onTap: () {
            // Set field text → then geocode
            _searchController.text = item['city']!;
            _lookupLocation(isFromHome, overrideQuery: item['city']!);
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Pincode hint — user typing digits but hasn't searched yet
  // ---------------------------------------------------------------------------
  Widget _buildPincodeHint() {
    final digits = _searchController.text.trim().length;
    final remaining = 6 - digits;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pin_drop_outlined,
              size: 52,
              color: AppColors.grey600.withAlpha(100),
            ),
            const SizedBox(height: 12),
            Text(
              remaining > 0
                  ? 'Enter $remaining more digit${remaining > 1 ? 's' : ''}'
                  : 'Tap → to find areas for this pincode',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading hint
  // ---------------------------------------------------------------------------
  Widget _buildLoadingHint() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.button),
          const SizedBox(height: 16),
          Text(
            'Searching location...',
            style: TextStyle(fontSize: 14, color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Resolved results — same UI for city & pincode
  // ---------------------------------------------------------------------------
  Widget _buildResolvedResults(bool isFromHome) {
    final isPincode = _mode == _InputMode.pincodeResults;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Expanded(child: Divider(color: AppColors.grey900.withAlpha(20))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  isPincode ? 'SELECT YOUR AREA' : 'SELECT YOUR LOCATION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppColors.grey900.withAlpha(20))),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: _resolvedPlaces.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: AppColors.grey900.withAlpha(15)),
            itemBuilder: (context, index) {
              final place = _resolvedPlaces[index];
              final areaTitle = place['area']!.isNotEmpty
                  ? place['area']!
                  : place['city']!;
              return ListTile(
                onTap: () => _saveAndNavigate(
                  city: place['city']!,
                  state: place['state']!,
                  pincode: place['pincode']!,
                  address: place['address']!,
                  isFromHome: isFromHome,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                leading: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: AppColors.button.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColors.button,
                    size: 20,
                  ),
                ),
                title: Text(
                  areaTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  place['address']!,
                  style: TextStyle(fontSize: 12, color: AppColors.grey600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.grey600,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Default content — GPS + popular cities
  // ---------------------------------------------------------------------------
  Widget _buildDefaultContent(bool isFromHome) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // GPS button
          OutlinedButton.icon(
            onPressed: _isGpsLoading ? null : () => _detectGps(isFromHome),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.button,
              side: BorderSide(color: AppColors.button, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: _isGpsLoading
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.button,
                      ),
                    ),
                  )
                : const Icon(Icons.my_location_rounded, size: 20),
            label: Text(
              _isGpsLoading ? 'Detecting location...' : 'Use current location',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),

          if (_gpsError != null) ...[
            const SizedBox(height: 14),
            _buildErrorCard(_gpsError!),
          ],

          const SizedBox(height: 28),

          // Divider with label
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.grey900.withAlpha(20))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'POPULAR CITIES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppColors.grey900.withAlpha(20))),
            ],
          ),

          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _kPopularCities.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3.2,
            ),
            itemBuilder: (context, index) =>
                _buildCityChip(_kPopularCities[index], isFromHome),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // City chip (popular grid)
  // ---------------------------------------------------------------------------
  Widget _buildCityChip(Map<String, String> cityData, bool isFromHome) {
    return InkWell(
      onTap: () =>
          _lookupLocation(isFromHome, overrideQuery: cityData['city']!),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.grey900.withAlpha(25)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.location_on_rounded, color: AppColors.button, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cityData['city']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    cityData['state']!,
                    style: TextStyle(fontSize: 11, color: AppColors.grey600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Reusable suggestion tile
  // ---------------------------------------------------------------------------
  Widget _buildSuggestionTile({
    required IconData icon,
    required Widget title,
    required String subtitle,
    required IconData trailingIcon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.button.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.button, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.grey600),
                  ),
                ],
              ),
            ),
            Icon(trailingIcon, size: 16, color: AppColors.grey600),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error card
  // ---------------------------------------------------------------------------
  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade600,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade900, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Save + navigate (all paths converge here)
  // ---------------------------------------------------------------------------
  Future<void> _saveAndNavigate({
    required String city,
    required String state,
    required bool isFromHome,
    String pincode = '',
    String? address,
  }) async {
    FocusScope.of(context).unfocus();

    final finalAddress = address ?? '$city, $state, India';

    await LocationStorage.saveLocation(
      address: finalAddress,
      lat: 0.0,
      lng: 0.0,
      city: city,
      state: state,
      pincode: pincode,
    );

    ref.read(locationProvider.notifier).state = LocationModel(
      city: city,
      state: state,
      pincode: pincode,
    );

    ref.invalidate(categoryProvider);
    ref.invalidate(productProvider);
    ref.invalidate(userDraftKits);
    ref.invalidate(brandProvider);
    ref.invalidate(ritualProvider);

    if (!mounted) return;
    _navigate(isFromHome);
  }

  // ---------------------------------------------------------------------------
  // GPS detection
  // ---------------------------------------------------------------------------
  Future<void> _detectGps(bool isFromHome) async {
    setState(() {
      _isGpsLoading = true;
      _gpsError = null;
    });

    try {
      final permission = await Permission.location.request();

      if (permission.isDenied) {
        setState(() {
          _gpsError = 'Location permission denied. Enable it in settings.';
          _isGpsLoading = false;
        });
        return;
      }

      if (permission.isPermanentlyDenied) {
        setState(() {
          _gpsError =
              'Permission permanently denied. Open app settings to enable.';
          _isGpsLoading = false;
        });
        await openAppSettings();
        return;
      }

      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() {
          _gpsError = 'Location services disabled. Please enable them.';
          _isGpsLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality ?? '';
        final state = place.administrativeArea ?? '';
        final pincode = place.postalCode ?? '';
        final addr = [
          place.street,
          place.subLocality,
          city,
          state,
          place.country,
          if (pincode.isNotEmpty) pincode,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        await _saveAndNavigate(
          city: city,
          state: state,
          pincode: pincode,
          address: addr,
          isFromHome: isFromHome,
        );
      } else {
        setState(() {
          _gpsError = 'Could not detect location. Please try again.';
          _isGpsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _gpsError = 'Could not detect location. Please try again.';
        _isGpsLoading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _mode = _InputMode.idle;
      _citySuggestions = [];
      _resolvedPlaces = [];
      _searchError = null;
    });
  }

  void _navigate(bool isFromHome) {
    if (isFromHome) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }

  String _toTitleCase(String input) => input
      .trim()
      .split(' ')
      .map(
        (w) => w.isEmpty
            ? ''
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
      )
      .join(' ');
}
