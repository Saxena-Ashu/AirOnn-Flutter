import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/flight_repositories.dart';
import 'flight_event.dart';
import 'flight_state.dart';

class FlightBloc extends Bloc<FlightEvent, FlightState> {
  final FlightRepository repository;

  FlightBloc({required this.repository}) : super(FlightInitial()) {
    on<LoadFlightsEvent>((event, emit) async {
      // If it's the very first load, show a full-screen spinner
      if (state is FlightInitial) emit(FlightLoading());

      try {
        final flights = await repository.fetchLiveFlights();
        emit(FlightLoaded(flights));
      } catch (e) {
        emit(FlightError(e.toString()));
      }
    });
  }
}
