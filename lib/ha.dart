import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_qr/native_qr.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
      body: const SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
              child: NewHAWidget(),
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
  List<ResolvedBonsoirService> _haInstances = [];
  final _nativeQr = NativeQr();

  @override
  void initState() {
    super.initState();
    //BlocProvider.of<HADiscoveredBloc>(context).add(FindHAInstancesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HADiscoveredBloc, HAConnectedState>(
      listener: (ctx, state) {
        print("give me from bloclistener");
        print(state);
        print(state.haInstances);
        setState(() {
          _haInstances = List.from(state.haInstances);
        });
      },
      child: _haInstances.isEmpty
          ? const SizedBox.shrink()
          : ListView.builder(
              itemCount: _haInstances.length,
              itemBuilder: (context, index) {
                //print(index);
                String friendlyName = _haInstances[index].name;
                String ip = _haInstances[index].ip!;
                String port = _haInstances[index].port.toString();

                return ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(friendlyName),
                  subtitle: Text('IP: $ip Port: $port'),
                  trailing: IconButton(
                      onPressed: () async {
                        try {
                          var result = await _nativeQr.get();
                          print(result);
                        } catch (err) {
                          print(err);
                        }
                      },
                      icon: const Icon(Icons.navigate_next)),
                );
              }),
    );
  }
}