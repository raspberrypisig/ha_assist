import 'package:bonsoir/bonsoir.dart';
//import 'package:equatable/equatable.dart';

//-- Home Assistant connected status --

//EVENTS
class ConnectionStatusEvent {}

//STATE

sealed class HAConnectionState {}

final class HADisconnectedState extends HAConnectionState {}

final class HAConnectedState extends HAConnectionState {
  List<ResolvedBonsoirService> haInstances = [];

  void addService(ResolvedBonsoirService service) {
    haInstances.add(service);
  }

  void removeService(ResolvedBonsoirService service) {
    haInstances.remove(service);
  }
}
