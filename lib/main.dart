import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ha_assist/camera.dart';
import 'package:ha_assist/repository.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'blocs.dart';
import 'ha.dart';
import 'models.dart';

const appTitle = "HA Speak";

// GoRouter configuration
final _router = GoRouter(
  routes: [
    GoRoute(
      name: 'home',
      path: '/',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      name: 'ha',
      path: '/ha',
      builder: (context, state) {
        return const HAScreen();
      },
    ),
    GoRoute(
      name: 'qrcamera',
      path: '/qrcamera/:haurl',
      builder: (context, state) {
        return QrCameraScreen(haUrl: state.pathParameters['haurl']);
      },
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RepositoryProvider(
    create: (_) => HADiscoveredRepository(),
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => HAConnectionBloc(
                RepositoryProvider.of<HADiscoveredRepository>(context))
              ..add(ConnectionsPageLoad())),
        BlocProvider(
            create: (context) => HADiscoveredBloc(
                RepositoryProvider.of<HADiscoveredRepository>(context))
              ..add(FindHAInstancesEvent())),
      ],
      child: const MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SpeechToText _speech;
  late bool _isListening = false;
  //late BonsoirDiscovery _mdnsService;
  String _text = 'Press the mic button and start speaking...';

  @override
  void initState() {
    super.initState();
    _speech = SpeechToText();
    _initSpeechToText();
    //_mdnsService = BonsoirDiscovery(type: _type);
  }

  Future<void> _initSpeechToText() async {
    await _speech.initialize(
        onError: _onSpeechToTextError, onStatus: _onSpeechToTextStatus);
  }

  void _onSpeechToTextError(SpeechRecognitionError errorNotification) {
    debugPrint("$errorNotification");
  }

  void _onSpeechToTextStatus(String status) {
    debugPrint(status);
    if (status == "done" && _isListening) {
      startListening();
    }
  }

  Future<void> startListening() async {
    await _speech.listen(onResult: (result) {
      debugPrint(result.recognizedWords);
      setState(() {
        _text = result.recognizedWords;
      });
      if (result.recognizedWords != "") {
        BlocProvider.of<HAConnectionBloc>(context)
            .add(HATalk(result.recognizedWords));
      }
    });
  }

  Future<void> stopListening() async {
    //await _speech.stop();
    await _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center(child: Text(widget.title)),
      ),
      body: Container(
        color: Colors.white,
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: BlocBuilder<HAConnectionBloc, HAConnectionState>(
                builder: (context, state) {
                  bool apiAvailable = state is HAConnectedState;
                  MaterialColor backgroundButtonColor = Colors.yellow;
                  String text = "HA Disconnected";
                  if (apiAvailable) {
                    text = "HA Connected";
                    backgroundButtonColor = Colors.green;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: backgroundButtonColor,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            context.pushNamed('ha');
                          },
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 20.0,
                            ),
                          )),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    _text,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMic,
        tooltip: 'Toggle Mic',
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _toggleMic() async {
    if (_speech.isAvailable) {
      debugPrint("speech is not available");
    } else {
      debugPrint("speech not available");
    }
    setState(() {
      _isListening = !_isListening;
    });
    debugPrint(
      "Mic on: $_isListening",
    );
    if (_speech.isAvailable && _isListening) {
      debugPrint("about to do it.");
      startListening();
    }

    if (_speech.isAvailable && !_isListening) {
      debugPrint("not about to do it.");
      stopListening();
    }
  }
}
