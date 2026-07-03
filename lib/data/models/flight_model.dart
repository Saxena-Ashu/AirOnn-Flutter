class Flight {
  final String callsign;
  final double latitude;
  final double longitude;
  final double velocity;
  final double altitude;

  Flight({
    required this.callsign,
    required this.latitude,
    required this.longitude,
    required this.velocity,
    required this.altitude,
  });

  factory Flight.fromRawArray(List<dynamic> array) {
    return Flight(
      callsign: (array[1] as String? ?? 'Unknown').trim(),
      longitude: (array[5] as num? ?? 0).toDouble(),
      latitude: (array[6] as num? ?? 0).toDouble(),
      velocity: (array[9] as num? ?? 0).toDouble(),
      altitude: (array[7] as num?)?.toDouble() ?? 0,
    );
  }
}
