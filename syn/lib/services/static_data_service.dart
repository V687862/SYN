import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/country.dart';
import '../models/gender_option.dart';
import '../models/core_drive.dart';
import '../models/baby_name.dart';
import '../models/school.dart';

class StaticDataService {
  List<Country>? _countries;
  List<GenderOption>? _genders;
  List<CoreDrive>? _coreDrives;
  List<BabyName>? _babyNames;
  List<School>? _schools;

  Future<List<T>> _loadJsonList<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final String response = await rootBundle.loadString(assetPath);
      final List<dynamic> data = json.decode(response);

      return data.map<T>((item) {
        try {
          return fromJson(item as Map<String, dynamic>);
        } catch (e) {
          debugPrint("Error parsing item in $assetPath: $e");
          rethrow; // optionally skip bad entries instead of rethrowing
        }
      }).toList();
    } catch (e) {
      debugPrint("Error loading $assetPath: $e");
      return [];
    }
  }

  Future<List<Country>> getCountries() async {
    return _countries ??= await _loadJsonList(
      'assets/static/countries.json',
      Country.fromJson,
    );
  }

  Future<List<GenderOption>> getGenders() async {
    return _genders ??= await _loadJsonList(
      'assets/static/genders.json',
      GenderOption.fromJson,
    );
  }

  Future<List<CoreDrive>> getCoreDrives() async {
    return _coreDrives ??= await _loadJsonList(
      'assets/static/core_drives.json',
      CoreDrive.fromJson,
    );
  }

  // Baby names support
  Future<List<BabyName>> getBabyNames() async {
    // Attempts to load from an optional asset. Returns [] on failure.
    return _babyNames ??= await _loadJsonList(
      'assets/static/baby_names.json',
      BabyName.fromJson,
    );
  }

  Future<List<BabyName>> getBabyNamesByCountry(String countryCode) async {
    final names = await getBabyNames();
    return names.where((n) => n.countryCodes == null || n.countryCodes!.contains(countryCode)).toList();
  }

  Future<List<BabyName>> getBabyNamesByGender(String genderId) async {
    final names = await getBabyNames();
    return names.where((n) => n.genderId == null || n.genderId == genderId).toList();
  }

  // Education (schools) support
  Future<List<School>> getSchools() async {
    // Attempts to load from an optional asset. Returns [] on failure.
    return _schools ??= await _loadJsonList(
      'assets/static/education_schools.json',
      School.fromJson,
    );
  }
}
