import 'package:flutter/material.dart';
import '../data/models/flight_model.dart';

class FlightFrontCard extends StatelessWidget {
  final Flight flight;

  const FlightFrontCard({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF041421),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Selected Flight",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFd0d6d6),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                flight.callsign,
                style: const TextStyle(fontSize: 18, color: Color(0xFFd0d6d6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlightBackCard extends StatelessWidget {
  final Flight flight;

  const FlightBackCard({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF329596),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Flight Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildInfoRow("Callsign", flight.callsign),
              _buildInfoRow("Latitude", flight.latitude.toStringAsFixed(4)),
              _buildInfoRow("Longitude", flight.longitude.toStringAsFixed(4)),
              _buildInfoRow(
                "Velocity",
                "${(flight.velocity * 3.6).toStringAsFixed(2)} km/h",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
