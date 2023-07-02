import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
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
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getTemporaryDirectory(),
  );
  runApp(RepositoryProvider(
    create: (_) => HADiscoveredRepository(),
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => HAConnectionBloc(
                RepositoryProvider.of<HADiscoveredRepository>(context))
              ..add(ConnectionsPageLoad())),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SpeechToText _speech;
  late bool _isListening = false;
  String _text = 'Press the mic button and start speaking...';

  @override
  void initState() {
    super.initState();
    _speech = SpeechToText();
    _initSpeechToText();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text(widget.title)),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: BlocBuilder<HAConnectionBloc, HAState>(
                builder: (context, state) {
                  bool apiAvailable = state.apiAvailable;
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
                            if (apiAvailable) {
                              BlocProvider.of<HAConnectionBloc>(context)
                                  .add(DisconnectConnection());
                            } else {
                              context.pushNamed('ha');
                            }
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
      ),
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
