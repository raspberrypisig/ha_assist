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
  MockHAConnectionBloc(this.repository) : super() {
    on<ConnectionsPageLoad>(
        (ConnectionStatusEvent event, Emitter<HAConnectionState> emit) {});
  }
}

class MockHADiscoveredRepository extends Fake
    implements HADiscoveredRepository {}

void main() {
  group("Opening screen test", () {
    setUpAll(() {});

    testWidgets('Opening screen: HA disconnected and mic is off',
        (tester) async {
      await tester.pumpWidget(BlocProvider<HAConnectionBloc>(
        create: (context) => MockHAConnectionBloc(MockHADiscoveredRepository()),
        child: const MaterialApp(
          home: MainScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text("Disconnected"), findsOneWidget);
    });
  });
}
