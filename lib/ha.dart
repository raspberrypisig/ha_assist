import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs.dart';
import 'models.dart';

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
                  ),
                  const NewHAWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class NewHAWidget extends StatefulWidget {
  const NewHAWidget({super.key});

  @override
  State<NewHAWidget> createState() => _NewHAWidgetState();
}

class _NewHAWidgetState extends State<NewHAWidget> {
  @override
  void initState() {
    super.initState();
    //BlocProvider.of<HADiscoveredBloc>(context).add(FindHAInstancesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HADiscoveredBloc, HAConnectedState>(
      listener: (ctx, state) {
        print("give me something");
      },
      child: const Text("boo"),
    );
  }
}
