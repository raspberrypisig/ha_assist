//import 'dart:convert';

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

class DisconnectConnection extends ConnectionStatusEvent {}

class DiscoveredEvent {}

class NewlyDiscoveredEvent extends DiscoveredEvent {}

class PreviouslyDiscoveredEvent extends DiscoveredEvent {}

//class FindHAInstancesEvent extends DiscoveredEvent {}
class FindHAInstancesEvent extends ConnectionStatusEvent {}

//STATE

sealed class HAConnectionState {}

class HAState extends HAConnectionState {
  ConnectionDetails? connection;
  late List<ResolvedBonsoirService> discovered;
  late List<ConnectionDetails> previous;

  HAState(
      {this.connection, this.discovered = const [], this.previous = const []});

  bool get apiAvailable {
    if (connection != null) {
      return true;
    }
    return false;
  }

  void addDiscoveredService(ResolvedBonsoirService service) {
    discovered.add(service);
  }

  void connectionDetails(String url, String token) {
    connection = ConnectionDetails(url, token);
  }

  HAState clone() {
    return HAState(
        connection: connection, discovered: discovered, previous: previous);
  }

  /*
  HAState copyWith(
      {ConnectionDetails? connection,
      List<ResolvedBonsoirService>? discovered,
      List<ConnectionDetails>? previous}) {
    return HAState(
        connection: connection ?? this.connection,
        discovered: discovered ?? this.discovered,
        previous: previous ?? this.previous);
  }
  */
}

class ConnectionDetails {
  String homeassistant;
  String token;

  ConnectionDetails(this.homeassistant, this.token);

  ConnectionDetails.fromJson(Map<String, dynamic> json)
      : homeassistant = json['homeassistant'],
        token = json['token'];

  Map<String, dynamic> toJson() => {
        'homeassistant': homeassistant,
        'token': token,
      };
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
