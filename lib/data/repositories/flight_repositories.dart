import 'package:dio/dio.dart';
import '../models/flight_model.dart';

class FlightRepository {
  final Dio _dio = Dio();

  Future<List<Flight>> fetchLiveFlights() async {
    try {
      final response = await _dio.get(
        'https://opensky-network.org/api/states/all',
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
