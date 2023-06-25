import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ha_assist/harestapi.dart';
import 'package:ha_assist/models.dart';
import 'package:ha_assist/repository.dart';

class ConnectionDetails {
  String homeassistant;
  String token;

  ConnectionDetails(this.homeassistant, this.token);
}

class HAConnectionBloc extends Bloc<ConnectionStatusEvent, HAConnectionState> {
  final HARestAPI _haApi = HARestAPI();
  ConnectionDetails? _connection;

  HAConnectionBloc(HADiscoveredRepository repository)
      : super(HADisconnectedState()) {
    on<ConnectionsPageLoad>(_onConnectionsPageLoad);
    on<TokenFound>(_onTokenFound);
    on<HATalk>(_onHATalk);
  }

  bool get apiAvailable {
    if (_connection != null) {
      return true;
    }
    return false;
  }

  FutureOr<void> _onConnectionsPageLoad(
      ConnectionStatusEvent event, Emitter<HAConnectionState> emit) {
    emit(HADisconnectedState());
  }

  FutureOr<void> _onTokenFound(
      TokenFound event, Emitter<HAConnectionState> emit) async {
    debugPrint("Token found: ${event.token} for url: ${event.url}");
    var token = event.token.trim();
    bool isRestApiAvailable = await _haApi.ping(event.url, token);
    if (isRestApiAvailable) {
      _connection = ConnectionDetails(event.url, token);
      emit(HAConnectedState());
      debugPrint("HA Rest API Alive");
    } else {
      emit(HADisconnectedState());
      debugPrint("HA Rest API Not Alive");
    }
  }

  FutureOr<void> _onHATalk(HATalk event, Emitter<HAConnectionState> emit) {}
}

class HADiscoveredBloc extends Bloc<DiscoveredEvent, HAConnectedState> {
  late HADiscoveredRepository _repository;
  List<ResolvedBonsoirService> haservices = [];

  HADiscoveredBloc(HADiscoveredRepository repository)
      : super(HAConnectedState()) {
    _repository = repository;
    on<FindHAInstancesEvent>(_onFindHAInstances);
  }

  FutureOr<void> _onFindHAInstances(
      event, Emitter<HAConnectedState> emit) async {
    print("Finding HA Instances...");
    await for (List<ResolvedBonsoirService> services in _repository.find()) {
      haservices = services;
      final newState = HAConnectedState.fromList(services);
      emit(newState);
    }
  }
}
