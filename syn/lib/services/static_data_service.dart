import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/country.dart';
import '../models/gender_option.dart';
import '../models/core_drive.dart';

class StaticDataService {
  List<Country>? _countries;
  List<GenderOption>? _genders;
  List<CoreDrive>? _coreDrives;

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

  // TODO: Add methods for baby names, education, etc.
}
