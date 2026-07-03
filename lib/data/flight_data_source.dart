import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'models/flight_model.dart';

class FlightDataSource extends DataGridSource {
  FlightDataSource({
    required List<Flight> flights,
    required String selectedCallsign,
    required this.onFlightSelected,
  }) : _allFlights = flights,
       _filteredFlights = List.from(flights),
       _selectedCallsign = selectedCallsign {
    _buildRows();
  }

  final List<Flight> _allFlights;
  List<Flight> _filteredFlights;
  final String _selectedCallsign;
  final Function(Flight) onFlightSelected;

  List<DataGridRow> _rows = [];

  @override
  List<DataGridRow> get rows => _rows;

  void _buildRows() {
    _rows =
        _filteredFlights.map((flight) {
          return DataGridRow(
            cells: [
              DataGridCell<String>(
                columnName: 'callsign',
                value: flight.callsign,
              ),
              DataGridCell<double>(
                columnName: 'latitude',
                value: flight.latitude,
              ),
              DataGridCell<double>(
                columnName: 'longitude',
                value: flight.longitude,
              ),
              DataGridCell<String>(
                columnName: 'velocity',
                value: "${(flight.velocity * 3.6).toStringAsFixed(2)} km/h",
              ),
            ],
          );
        }).toList();
  }

  void search(String keyword) {
    List<Flight> searchedFlights;

    if (keyword.isEmpty) {
      searchedFlights = List.from(_allFlights);
    } else {
      searchedFlights =
          _allFlights
              .where(
                (flight) => flight.callsign.toLowerCase().contains(
                  keyword.toLowerCase(),
                ),
              )
              .toList();
    }

    final index = searchedFlights.indexWhere(
      (f) => f.callsign == _selectedCallsign,
    );

    if (index != -1) {
      final selected = searchedFlights.removeAt(index);
      searchedFlights.insert(0, selected);
    }

    _filteredFlights = searchedFlights;
    _buildRows();
    notifyListeners();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final String callsign = row.getCells()[0].value.toString();
    final bool isSelected = callsign == _selectedCallsign;

    return DataGridRowAdapter(
      color: isSelected ? Colors.amber.withValues(alpha: 0.4) : null,
      cells: List.generate(row.getCells().length, (index) {
        final cell = row.getCells()[index];
        return GestureDetector(
          onTap: () {
            final flight = _allFlights.firstWhere(
              (f) => f.callsign == callsign,
            );
            onFlightSelected(flight);
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: Text(
              cell.value.toString(),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
    );
  }
}
