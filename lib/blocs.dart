import 'dart:async';
import 'dart:convert';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:ha_assist/harestapi.dart';
import 'package:ha_assist/models.dart';
import 'package:ha_assist/repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class HAConnectionBloc extends HydratedBloc<ConnectionStatusEvent, HAState> {
  late HADiscoveredRepository _repository;
  final HARestAPI _haApi = HARestAPI();

  HAConnectionBloc(HADiscoveredRepository repository) : super(HAState()) {
    _repository = repository;
    on<ConnectionsPageLoad>(_onConnectionsPageLoad);
    on<TokenFound>(_onTokenFound);
    on<HATalk>(_onHATalk);
    on<FindHAInstancesEvent>(_onFindHAInstances);
    on<DisconnectConnection>(_onDisconnectionConnection);
  }

  FutureOr<void> _onConnectionsPageLoad(
      ConnectionStatusEvent event, Emitter<HAConnectionState> emit) {
    emit(state);
  }

  FutureOr<void> _onTokenFound(
      TokenFound event, Emitter<HAConnectionState> emit) async {
    debugPrint("Token found: ${event.token} for url: ${event.url}");
    var token = event.token.trim();
    bool isRestApiAvailable = await _haApi.ping(event.url, token);
    if (isRestApiAvailable) {
      state.connectionDetails(event.url, token);
      emit(state.clone());
      debugPrint("HA Rest API Alive");
    } else {
      debugPrint("HA Rest API Not Alive");
    }
  }

  FutureOr<void> _onHATalk(
      HATalk event, Emitter<HAConnectionState> emit) async {
    if (state.apiAvailable) {
      String result = await _haApi.talkToHA(state.connection!.homeassistant,
          state.connection!.token, event.message);
      debugPrint(result);
    }
  }

  FutureOr<void> _onFindHAInstances(
      FindHAInstancesEvent event, Emitter<HAConnectionState> emit) async {
    await for (ResolvedBonsoirService service in _repository.find()) {
      final ids = <String?>{};
      List<ResolvedBonsoirService> discovered = List.from(state.discovered);
      discovered.add(service);
      discovered.retainWhere((x) => ids.add(x.attributes!['base_url']));
      state.discovered = discovered;
      emit(state.clone());
    }
  }

  @override
  HAState? fromJson(Map<String, dynamic> json) {
    if (json["previous"] == null) {
      return HAState();
    }
    final prev = List<Map<String, dynamic>>.from(jsonDecode(json["previous"]))
        .map((x) => ConnectionDetails.fromJson(x));
    List<ConnectionDetails> previous = List<ConnectionDetails>.from(prev);
    return HAState(previous: previous);
  }

  @override
  Map<String, dynamic>? toJson(HAState state) {
    List<ConnectionDetails> previous = List.from(state.previous);
    var connection = state.connection;
    if (connection != null) {
      previous.add(connection);
    }
    final ids = <ConnectionDetails>{};
    previous.retainWhere((x) => ids.add(x));
    return {'previous': jsonEncode(previous)};
  }

  FutureOr<void> _onDisconnectionConnection(
      DisconnectConnection event, Emitter<HAState> emit) {
    state.connection = null;
    emit(state.clone());
  }
}
