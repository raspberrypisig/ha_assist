import 'package:flutter/material.dart';

class HAScreen extends StatelessWidget {
  const HAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Finding Home Assistant")),
        backgroundColor: const Color(0xff764abc),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                top: 30.0,
                bottom: 10.0,
                left: 20.0,
              ),
              child: Text(
                "NEW",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Flexible(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    subtitle: const Text('IP: 192.168.20.98 Port:8123'),
                    trailing: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.navigate_next)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
