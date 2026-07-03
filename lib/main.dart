import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/flight_repositories.dart';
import 'blocs/flight/flight_bloc.dart';
import 'views/flight_map_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => FlightRepository(),
      child: BlocProvider(
        create:
            (context) =>
                FlightBloc(repository: context.read<FlightRepository>()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          // Wrap FlightMapView with the flow initialization widget
          home: const LoginFlowWrapper(child: FlightMapView()),
        ),
      ),
    );
  }
}

// Custom wrapper to manage the lifecycle of the login popup and snackbar
class LoginFlowWrapper extends StatefulWidget {
  final Widget child;
  const LoginFlowWrapper({super.key, required this.child});

  @override
  State<LoginFlowWrapper> createState() => _LoginFlowWrapperState();
}

class _LoginFlowWrapperState extends State<LoginFlowWrapper> {
  @override
  void initState() {
    super.initState();
    // Triggers as soon as the first frame of the app finishes rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoginDialog();
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Forces user interaction
      builder: (BuildContext context) {
        final TextEditingController userId = TextEditingController();
        final TextEditingController password = TextEditingController();

        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Please login to track flights',
            style: TextStyle(color: Color(0xFF000000)),
          ),
          actionsAlignment: MainAxisAlignment.center,

          content: Column(
            mainAxisSize:
                MainAxisSize.min, // Prevents the dialog from taking full screen
            children: [
              TextField(
                controller: userId,
                style: TextStyle(color: Color(0xFF000000)),
                decoration: const InputDecoration(labelText: 'UserID'),
              ),
              const SizedBox(height: 10), // Adds space between fields
              TextField(
                controller: password,
                style: TextStyle(color: Color(0xFF000000)),
                obscureText: true, // Hides password characters
                decoration: const InputDecoration(labelText: 'Password'),
              ),
            ],
          ),

          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(color: Color(0xFF58b783), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              child: const Text(
                'Login',
                style: TextStyle(color: Color(0xFF5e8d83)),
              ),
              onHover: (value) => Color(0xff58b783),
              onPressed: () {
                if (userId.text.isNotEmpty && password.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  _showWelcomeNotification();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showWelcomeNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Welcome! Loading flight details...',
          textAlign: TextAlign.center,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Returns FlightMapView dynamically after setting up the dialog trigger
    return widget.child;
  }
}
