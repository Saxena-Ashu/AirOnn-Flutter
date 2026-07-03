import '../../data/models/flight_model.dart';

abstract class FlightState {}

class FlightInitial extends FlightState {}

class FlightLoading extends FlightState {}

class FlightLoaded extends FlightState {
  final List<Flight> flights;
  FlightLoaded(this.flights);
}

class FlightError extends FlightState {
  final String message;
  FlightError(this.message);
}
