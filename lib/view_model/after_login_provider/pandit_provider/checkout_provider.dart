import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/service_selection_screen.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/temple_selection_screen.dart';

// service selection
final serviceSelected = StateProvider<int?>((ref) => null);
final selectedServiceProvider = StateProvider<ServiceModel?>((ref) => null);

// temple selection

final templeSelected = StateProvider<int?>((ref) => null);
final selectedTempleProvider = StateProvider<TempleModel?>((ref) => null);
