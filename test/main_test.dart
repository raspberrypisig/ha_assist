import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ha_assist/blocs.dart';
import 'package:ha_assist/main.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:ha_assist/models.dart';
import 'package:ha_assist/repository.dart';

class MockHAConnectionBloc extends MockBloc<ConnectionStatusEvent, HAState>
    implements HAConnectionBloc {
  final MockHADiscoveredRepository repository;
  MockHAConnectionBloc(this.repository);
}

class MockHADiscoveredRepository extends Fake
    implements HADiscoveredRepository {}

void main() {
  group("Opening screen test", () {
    setUpAll(() {});

    testWidgets('Opening screen: HA disconnected and mic is off',
        (tester) async {
      final MockHAConnectionBloc bloc =
          MockHAConnectionBloc(MockHADiscoveredRepository());

      whenListen(bloc, Stream.fromIterable([HAState()]),
          initialState: HAState());

      await tester.pumpWidget(BlocProvider<HAConnectionBloc>(
        create: (context) => bloc,
        child: const MaterialApp(
          home: MainScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text("Press the mic button and start speaking..."),
          findsOneWidget);
      expect(find.text("HA Connected"), findsNothing);
      expect(find.text("HA Disconnected"), findsOneWidget);
    });
  });
}
