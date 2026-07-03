import '../models/flight_model.dart';

abstract class IFlightRepository {
  Future<List<Flight>> fetchLiveFlights();
}
