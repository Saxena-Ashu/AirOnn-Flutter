import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('AirConn'),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('MAP'),
            onTap: () {
              Navigator.pop(context); // closes the drawer
              // navigate or do something
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
