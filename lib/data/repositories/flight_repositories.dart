import 'package:dio/dio.dart';
import '../models/flight_model.dart';

class FlightRepository {
  final Dio _dio = Dio();

  // Helper method: Authenticates with OpenSky and fetches a temporary access token
  Future<String> _getAccessToken() async {
    try {
      final response = await _dio.post(
        'https://auth.opensky-network.org/auth/realms/opensky-network/protocol/openid-connect/token',
        data: {
          'grant_type': 'client_credentials',
          'client_id': 'saxena_ashu-api-client',
          'client_secret': 'Zz0u0gT3d5t6mJLJj7hxEGalrIfo7snv',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      return response.data['access_token'] as String;
    } on DioException catch (e) {
      throw Exception('OpenSky Authentication Failed: ${e.message}');
    }
  }

  // Main tracking method
  Future<List<Flight>> fetchLiveFlights() async {
    try {
      final token = await _getAccessToken();

      final response = await _dio.get(
        'https://opensky-network.org/api/states/all',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> flights = response.data['states'] ?? [];

        return flights
            //.where((state) => state[5] != null && state[6] != null)
            .map((state) => Flight.fromRawArray(state))
            .toList();
      }

      throw Exception("Failed to load flights");
    } on DioException catch (e) {
      throw Exception("Network error: ${e.message}");
    }
  }
}
