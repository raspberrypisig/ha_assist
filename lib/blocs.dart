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
  late HADiscoveredRepository _repository;
  final HARestAPI _haApi = HARestAPI();
  ConnectionDetails? _connection;
  List<ResolvedBonsoirService> _discovered = [];
  List<ConnectionDetails> _previous = [];

  HAConnectionBloc(HADiscoveredRepository repository)
      : super(HADisconnectedState()) {
    _repository = repository;
    on<ConnectionsPageLoad>(_onConnectionsPageLoad);
    on<TokenFound>(_onTokenFound);
    on<HATalk>(_onHATalk);
    on<FindHAInstancesEvent>(_onFindHAInstances);
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
      emit(HADiscoveredState());
      debugPrint("HA Rest API Alive");
    } else {
      emit(HADisconnectedState());
      debugPrint("HA Rest API Not Alive");
    }
  }

  FutureOr<void> _onHATalk(
      HATalk event, Emitter<HAConnectionState> emit) async {
    if (apiAvailable) {
      String result = await _haApi.talkToHA(
          _connection!.homeassistant, _connection!.token, event.message);
      debugPrint(result);
    }
  }

  FutureOr<void> _onFindHAInstances(
      FindHAInstancesEvent event, Emitter<HAConnectionState> emit) async {
    await for (ResolvedBonsoirService service in _repository.find()) {
      _discovered.add(service);
      final ids = Set();
      _discovered.retainWhere((x) => ids.add(x.attributes!['base_url']));

      final newState = HADiscoveredState.fromList(_discovered);
      emit(newState);
    }
  }
}
