import 'package:airon/data/models/flight_model.dart';
import 'package:airon/data/repositories/i_flight_repository.dart';

class FakeFlightRepository implements IFlightRepository {
  @override
  Future<List<Flight>> fetchLiveFlights() async {
    return [
      Flight(
        callsign: 'AI101',
        latitude: 28.6139,
        longitude: 77.2090,
        velocity: 850,
        altitude: 9000,
      ),

      Flight(
        callsign: 'BA202',
        latitude: 19.0760,
        longitude: 72.8777,
        velocity: 700,
        altitude: 4000,
      ),

      Flight(
        callsign: 'LH303',
        latitude: 13.0827,
        longitude: 80.2707,
        velocity: 950,
        altitude: 12000,
      ),
    ];
  }
}
