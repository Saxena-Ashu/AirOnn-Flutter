import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../blocs/flight/flight_bloc.dart';
import '../blocs/flight/flight_event.dart';
import '../blocs/flight/flight_state.dart';
import '../data/models/flight_model.dart';
import 'flight_details_view.dart';

class FlightMapView extends StatefulWidget {
  const FlightMapView({super.key});

  @override
  State<FlightMapView> createState() => _FlightMapViewState();
}

class _FlightMapViewState extends State<FlightMapView> {
  Timer? _timer;

  // Filter state — all unchecked by default, nothing shows until selected
  bool _showLowAltitude = false;
  bool _showMidAltitude = false;
  bool _showHighAltitude = false;

  @override
  void initState() {
    super.initState();
    context.read<FlightBloc>().add(LoadFlightsEvent());
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      context.read<FlightBloc>().add(LoadFlightsEvent());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Color-code markers by altitude band
  Color _colorForAltitude(double altitude) {
    if (altitude < 3000) return Colors.greenAccent;
    if (altitude < 10000) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  bool _passesFilter(Flight flight) {
    final alt = flight.altitude;
    if (alt < 3000) return _showLowAltitude;
    if (alt < 10000) return _showMidAltitude;
    return _showHighAltitude;
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filter Flights by Altitude",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Select which altitude bands to show on the map",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _showLowAltitude,
                    title: const Row(
                      children: [
                        Icon(Icons.circle, color: Colors.greenAccent, size: 14),
                        SizedBox(width: 8),
                        Text("Low altitude (< 3000m)"),
                      ],
                    ),
                    onChanged: (v) {
                      setModalState(() => _showLowAltitude = v ?? false);
                      setState(() {});
                    },
                  ),
                  CheckboxListTile(
                    value: _showMidAltitude,
                    title: const Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: Colors.orangeAccent,
                          size: 14,
                        ),
                        SizedBox(width: 8),
                        Text("Mid altitude (3000–10000m)"),
                      ],
                    ),
                    onChanged: (v) {
                      setModalState(() => _showMidAltitude = v ?? false);
                      setState(() {});
                    },
                  ),
                  CheckboxListTile(
                    value: _showHighAltitude,
                    title: const Row(
                      children: [
                        Icon(Icons.circle, color: Colors.redAccent, size: 14),
                        SizedBox(width: 8),
                        Text("High altitude (> 10000m)"),
                      ],
                    ),
                    onChanged: (v) {
                      setModalState(() => _showHighAltitude = v ?? false);
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('✈️ AirConn')),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: BlocBuilder<FlightBloc, FlightState>(
        builder: (context, state) {
          if (state is FlightLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FlightError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is FlightLoaded) {
            final filteredFlights = state.flights.where(_passesFilter).toList();

            final markers =
                filteredFlights.map((flight) {
                  final color = _colorForAltitude(flight.altitude);

                  return Marker(
                    point: LatLng(flight.latitude, flight.longitude),
                    width: 90,
                    height: 60,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => FlightDetailsView(
                                  selectedFlight: flight,
                                  flights: state.flights,
                                ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flight, color: color, size: 28),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "${flight.callsign}\n${flight.altitude.round()}m",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();

            return Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(20.0, 0.0),
                    initialZoom: 2.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.flight_tracker',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                Positioned(bottom: 16, left: 16, child: _buildLegend()),
                if (markers.isEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Tap the filter icon and select an altitude range to see flights",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }
          return const Center(child: Text('Initialize Map Data...'));
        },
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            "Altitude",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 6),
          _LegendRow(color: Colors.greenAccent, label: "< 3000m"),
          SizedBox(height: 4),
          _LegendRow(color: Colors.orangeAccent, label: "3000–10000m"),
          SizedBox(height: 4),
          _LegendRow(color: Colors.redAccent, label: "> 10000m"),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    );
  }
}
