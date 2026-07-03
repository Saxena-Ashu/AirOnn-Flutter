import 'package:airon/blocs/flight/flight_bloc.dart';
import 'package:airon/data/repositories/i_flight_repository.dart';
import 'package:airon/views/flight_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_flight_repository.dart';

void main() {
  testWidgets('FlightMapView loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      RepositoryProvider<IFlightRepository>(
        create: (_) => FakeFlightRepository(),
        child: BlocProvider(
          create:
              (context) =>
                  FlightBloc(repository: context.read<IFlightRepository>()),
          child: const MaterialApp(home: FlightMapView()),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
