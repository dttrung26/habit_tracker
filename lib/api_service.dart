import 'dart:convert';

import 'package:http/http.dart' as http;

/// External API integration: REST Countries (https://restcountries.com).
///
/// The app makes a GET request to load every country name, which fills the
/// country dropdown on the Register and Personal Info screens.
class ApiService {
  /// The `fields=name` filter is required by the current REST Countries API
  /// (calling /v3.1/all without it returns an error) and keeps the response small.
  static const String countriesUrl =
      'https://restcountries.com/v3.1/all?fields=name';

  /// Used only if the API cannot be reached (for example, no internet).
  static const List<String> fallbackCountries = [
    'Australia',
    'Brazil',
    'Canada',
    'China',
    'France',
    'Germany',
    'India',
    'Japan',
    'South Africa',
    'United Kingdom',
    'United States',
    'Vietnam',
  ];

  /// Sends a GET request and returns the country names sorted A-Z.
  static Future<List<String>> fetchCountries() async {
    final response = await http
        .get(Uri.parse(countriesUrl))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      final names = data
          .map((country) => country['name']['common'] as String)
          .toSet() // remove any duplicates
          .toList()
        ..sort();
      return names;
    } else {
      throw Exception(
          'Failed to fetch countries (status code ${response.statusCode})');
    }
  }
}
