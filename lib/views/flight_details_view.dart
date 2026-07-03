import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import '../data/models/flight_model.dart';
import '../data/flight_data_source.dart';
import '../widgets/flip_card.dart';
import '../widgets/flight_info_card.dart';
import 'side_bar.dart';

class FlightDetailsView extends StatefulWidget {
  final Flight selectedFlight;
  final List<Flight> flights;

  const FlightDetailsView({
    super.key,
    required this.selectedFlight,
    required this.flights,
  });

  @override
  State<FlightDetailsView> createState() => _FlightDetailsViewState();
}

class _FlightDetailsViewState extends State<FlightDetailsView> {
  late FlightDataSource dataSource;
  late Flight currentFlight;
  late List<Flight> displayedFlights;

  @override
  void initState() {
    super.initState();

    currentFlight = widget.selectedFlight;
    displayedFlights = List.from(widget.flights);

    dataSource = FlightDataSource(
      flights: displayedFlights,
      selectedCallsign: currentFlight.callsign,
      onFlightSelected: _selectFlight,
    );
  }

  void _selectFlight(Flight flight) {
    setState(() {
      currentFlight = flight;
      displayedFlights.removeWhere((f) => f.callsign == flight.callsign);
      displayedFlights.insert(0, flight);

      dataSource = FlightDataSource(
        flights: displayedFlights,
        selectedCallsign: flight.callsign,
        onFlightSelected: _selectFlight,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF042630),
      appBar: AppBar(
        title: Text("Flight ${currentFlight.callsign}"),
        centerTitle: true,
      ),
      drawer: const SideBar(),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: FlipCard(
                front: FlightFrontCard(flight: currentFlight),
                back: FlightBackCard(flight: currentFlight),
              ),
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 350, maxWidth: 600),
              child: IntrinsicWidth(
                child: TextField(
                  decoration: const InputDecoration(
                    fillColor: Color(0xFF1d3f58),
                    hoverColor: Color(0xFF537692),
                    contentPadding: EdgeInsets.symmetric(horizontal: 150),
                    hintText: "Search Flight...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                  ),
                  onChanged: (value) => dataSource.search(value),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: SfDataGridTheme(
                data: SfDataGridThemeData(
                  rowHoverColor: const Color(0xFF4c7273),
                ),
                child: SfDataGrid(
                  source: dataSource,
                  allowSorting: true,
                  allowFiltering: true,
                  allowColumnsDragging: true,
                  allowPullToRefresh: true,
                  highlightRowOnHover: true,
                  selectionMode: SelectionMode.single,
                  columnWidthMode: ColumnWidthMode.fill,
                  columns: [
                    GridColumn(
                      allowFiltering: true,
                      columnName: 'callsign',
                      label: _buildHeader("Callsign"),
                    ),
                    GridColumn(
                      allowEditing: true,
                      columnName: 'latitude',
                      label: _buildHeader("Latitude"),
                    ),
                    GridColumn(
                      allowFiltering: true,
                      columnName: 'longitude',
                      label: _buildHeader("Longitude"),
                    ),
                    GridColumn(
                      allowFiltering: true,
                      columnName: 'velocity',
                      label: _buildHeader("Velocity"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      alignment: Alignment.center,
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
