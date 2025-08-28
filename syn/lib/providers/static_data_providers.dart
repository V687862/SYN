// lib/providers/static_data_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/static_data_service.dart';
import '../models/country.dart';
import '../models/gender_option.dart';
import '../models/core_drive.dart';

// Provider for the service itself
final staticDataServiceProvider = Provider<StaticDataService>((ref) {
  return StaticDataService();
});

// FutureProvider to load countries
final countriesProvider = FutureProvider<List<Country>>((ref) async {
  final staticDataService = ref.watch(staticDataServiceProvider);
  return staticDataService.getCountries();
});

// FutureProvider to load core drives
final coreDrivesProvider = FutureProvider<List<CoreDrive>>((ref) async {
  final staticDataService = ref.watch(staticDataServiceProvider);
  return staticDataService.getCoreDrives();
});


// FutureProvider to load genders
final gendersProvider = FutureProvider<List<GenderOption>>((ref) async {
  final staticDataService = ref.watch(staticDataServiceProvider);
  return staticDataService.getGenders();
});