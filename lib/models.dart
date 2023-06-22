import 'package:bonsoir/bonsoir.dart';
//import 'package:equatable/equatable.dart';

//-- Home Assistant connected status --

//EVENTS
class ConnectionStatusEvent {}

class ConnectionsPageLoad extends ConnectionStatusEvent {}

class DiscoveredEvent {}

class NewlyDiscoveredEvent extends DiscoveredEvent {}

class PreviouslyDiscoveredEvent extends DiscoveredEvent {}

class FindHAInstancesEvent extends DiscoveredEvent {}

//STATE

sealed class HAConnectionState {}

final class HADisconnectedState extends HAConnectionState {}

final class HAConnectedState extends HAConnectionState {
  List<ResolvedBonsoirService> haInstances = [];

  HAConnectedState();

  void addService(ResolvedBonsoirService service) {
    haInstances.add(service);
  }

  void removeService(ResolvedBonsoirService service) {
    haInstances.remove(service);
  }

  HAConnectedState fromService(List<ResolvedBonsoirService> services) {
    HAConnectedState newState = HAConnectedState();
    newState.haInstances = services;
    return newState;
  }
}
