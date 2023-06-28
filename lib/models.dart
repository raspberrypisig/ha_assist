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

//class FindHAInstancesEvent extends DiscoveredEvent {}
class FindHAInstancesEvent extends ConnectionStatusEvent {}

//STATE

sealed class HAConnectionState {}

class HAState extends HAConnectionState {
  ConnectionDetails? connection;
  final List<ResolvedBonsoirService> discovered = [];
  final List<ConnectionDetails> previous = [];

  bool get apiAvailable {
    if (connection != null) {
      return true;
    }
    return false;
  }
}

class ConnectionDetails {
  String homeassistant;
  String token;

  ConnectionDetails(this.homeassistant, this.token);
}

final class HADisconnectedState extends HAConnectionState {}

final class HADiscoveredState extends HAConnectionState {
  List<ResolvedBonsoirService> haInstances;

  HADiscoveredState._internal() : haInstances = [];

  factory HADiscoveredState() {
    return HADiscoveredState._internal();
  }

  void addService(ResolvedBonsoirService service) {
    haInstances.add(service);
  }

  void removeService(ResolvedBonsoirService service) {
    haInstances.remove(service);
  }

  factory HADiscoveredState.fromList(List<ResolvedBonsoirService> services) {
    HADiscoveredState newState = HADiscoveredState();
    newState.haInstances = services;
    return newState;
  }
}
