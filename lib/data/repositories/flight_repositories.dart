import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/flight_model.dart';

class FlightRepository {
  final Dio _dio = Dio();

  static const String _tokenUrl =
      'https://auth.opensky-network.org/auth/realms/opensky-network/protocol/openid-connect/token';
  static const String _statesUrl = 'https://opensky-network.org/api/states/all';

  // TODO: move these to a secure source (--dart-define, .env + flutter_dotenv,
  // or a backend proxy) rather than hardcoding in source control.
  static const String _clientId = 'saxena_ashu-api-client';
  static const String _clientSecret = 'EdzqOYWjzTjNE9G5HfIK7HxKaw5kxeqz';

  String? _accessToken;
  DateTime? _tokenExpiry;

  Future<String> _getAccessToken() async {
    // Reuse the cached token if it's still valid (with a small safety margin).
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(
          _tokenExpiry!.subtract(const Duration(seconds: 30)),
        )) {
      return _accessToken!;
    }

    try {
      final response = await _dio.post(
        _tokenUrl,
        data: {
          'grant_type': 'client_credentials',
          'client_id': _clientId,
          'client_secret': _clientSecret,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final data =
          response.data is String ? jsonDecode(response.data) : response.data;

      _accessToken = data['access_token'] as String;
      final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 1800;
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

      return _accessToken!;
    } on DioException catch (e) {
      throw Exception("Failed to authenticate with OpenSky: ${e.message}");
    }
  }

  Future<List<Flight>> fetchLiveFlights() async {
    try {
      final token = await _getAccessToken();

      final response = await _dio.get(
        _statesUrl,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data =
            response.data is String ? jsonDecode(response.data) : response.data;

        final List<dynamic> flights = data['states'] ?? [];
        return flights.map((state) => Flight.fromRawArray(state)).toList();
      }

      throw Exception("Failed to load flights");
    } on DioException catch (e) {
      // If the token expired mid-flight, clear cache so next call refreshes it.
      if (e.response?.statusCode == 401) {
        _accessToken = null;
        _tokenExpiry = null;
      }
      throw Exception("Network error: ${e.message}");
    }
  }
}
