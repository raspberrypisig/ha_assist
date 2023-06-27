import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'blocs.dart';
import 'models.dart';

class HAScreen extends StatelessWidget {
  const HAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
        child: Scaffold(
      //   appBar: AppBar(
      //     title: const Center(child: Text("Finding Home Assistant")),
      //     backgroundColor: const Color(0xff764abc),
      //   ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: HAInstancesWidget(),
          ),
        ],
      ),
    ));
  }
}

class HAInstancesWidget extends StatefulWidget {
  const HAInstancesWidget({super.key});

  @override
  State<HAInstancesWidget> createState() => _HAInstancesWidgetState();
}

class _HAInstancesWidgetState extends State<HAInstancesWidget>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finding Home Assistant"),
        backgroundColor: const Color(0xff764abc),
        bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.amberAccent,
            indicatorWeight: 8,
            tabs: const [
              Tab(
                text: "NEW",
              ),
              Tab(
                text: "PREVIOUS",
              ),
              Tab(
                text: "CONNECTED",
              ),
            ]),
      ),
      body: TabBarView(controller: _tabController, children: const [
        Center(
          child: NewHAWidget(),
        ),
        Center(
          child: PreviousHAWidget(),
        ),
        Center(
          child: ConnectedHAWidget(),
        ),
      ]),
    );
  }
}

class NewHAWidget extends StatefulWidget {
  const NewHAWidget({super.key});

  @override
  State<NewHAWidget> createState() => _NewHAWidgetState();
}

class _NewHAWidgetState extends State<NewHAWidget> {
  List<ResolvedBonsoirService> _haInstances = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<HAConnectionBloc>(context).add(FindHAInstancesEvent());
    //TODO: BlocProvider.of<HADiscoveredBloc>(context).add(RestoreNewlyDiscoveredEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HAConnectionBloc, HAConnectionState>(
      listener: (ctx, state) {
        setState(() {
          var discovered = state as HADiscoveredState;
          _haInstances = List.from(discovered.haInstances);
        });
      },
      child: _haInstances.isEmpty
          ? const SizedBox.shrink()
          : ListView.builder(
              itemCount: _haInstances.length,
              itemBuilder: (context, index) {
                String friendlyName = _haInstances[index].name;
                String ip = _haInstances[index].ip!;
                String port = _haInstances[index].port.toString();
                String url = _haInstances[index].attributes!['base_url']!;
                return ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(friendlyName),
                  subtitle: Text('IP: $ip Port: $port'),
                  trailing: IconButton(
                      onPressed: () {
                        context.goNamed('qrcamera',
                            pathParameters: {'haurl': url});
                      },
                      icon: const Icon(Icons.navigate_next)),
                );
              }),
    );
  }
}

class PreviousHAWidget extends StatefulWidget {
  const PreviousHAWidget({super.key});

  @override
  State<PreviousHAWidget> createState() => _PreviousHAWidgetState();
}

class _PreviousHAWidgetState extends State<PreviousHAWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ConnectedHAWidget extends StatefulWidget {
  const ConnectedHAWidget({super.key});

  @override
  State<ConnectedHAWidget> createState() => _ConnectedHAWidgetState();
}

class _ConnectedHAWidgetState extends State<ConnectedHAWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
