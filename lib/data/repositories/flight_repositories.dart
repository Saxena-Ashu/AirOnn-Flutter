import 'package:dio/dio.dart';
import '../models/flight_model.dart';

class FlightRepository {
  final Dio _dio = Dio();

  static const String _clientId = String.fromEnvironment('OPENSKY_CLIENT_ID');
  static const String _clientSecret = String.fromEnvironment(
    'OPENSKY_CLIENT_SECRET',
  );

  Future<String> _getAccessToken() async {
    try {
      final response = await _dio.post(
        'https://auth.opensky-network.org/auth/realms/opensky-network/protocol/openid-connect/token',
        data: {
          'grant_type': 'client_credentials',
          'client_id': _clientId,
          'client_secret': _clientSecret,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      return response.data['access_token'] as String;
    } on DioException catch (e) {
      throw Exception('OpenSky Authentication Failed: ${e.message}');
    }
  }

  Future<List<Flight>> fetchLiveFlights() async {
    try {
      final token = await _getAccessToken();

      final response = await _dio.get(
        'https://opensky-network.org/api/states/all',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> flights = response.data['states'] ?? [];
        return flights.map((state) => Flight.fromRawArray(state)).toList();
      }

      throw Exception("Failed to load flights");
    } on DioException catch (e) {
      throw Exception("Network error: ${e.message}");
    }
  }
}
