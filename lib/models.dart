import 'package:bonsoir/bonsoir.dart';
//import 'package:equatable/equatable.dart';

//-- Home Assistant connected status --

//EVENTS
class ConnectionStatusEvent {}

class ConnectionsPageLoad extends ConnectionStatusEvent {}

class TokenFound extends ConnectionStatusEvent {
  String token;
  String url;

  TokenFound(this.url, this.token);
}

class HATalk extends ConnectionStatusEvent {
  String message;

  HATalk(this.message);
}

class DiscoveredEvent {}

class NewlyDiscoveredEvent extends DiscoveredEvent {}

class PreviouslyDiscoveredEvent extends DiscoveredEvent {}

class FindHAInstancesEvent extends DiscoveredEvent {}

//STATE

sealed class HAConnectionState {}

final class HADisconnectedState extends HAConnectionState {}

final class HAConnectedState extends HAConnectionState {
  List<ResolvedBonsoirService> haInstances;

  HAConnectedState._internal() : haInstances = [];

  factory HAConnectedState() {
    return HAConnectedState._internal();
  }

  void addService(ResolvedBonsoirService service) {
    haInstances.add(service);
  }

  void removeService(ResolvedBonsoirService service) {
    haInstances.remove(service);
  }

  factory HAConnectedState.fromList(List<ResolvedBonsoirService> services) {
    HAConnectedState newState = HAConnectedState();
    newState.haInstances = services;
    return newState;
  }
}
