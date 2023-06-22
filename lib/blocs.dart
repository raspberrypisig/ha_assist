import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ha_assist/models.dart';
import 'package:ha_assist/repository.dart';

class HAConnectionBloc extends Bloc<ConnectionStatusEvent, HAConnectionState> {
  HAConnectionBloc(HADiscoveredRepository repository)
      : super(HADisconnectedState()) {
    on<ConnectionsPageLoad>(_onConnectionsPageLoad);
  }

  FutureOr<void> _onConnectionsPageLoad(
      ConnectionStatusEvent event, Emitter<HAConnectionState> emit) {
    emit(HADisconnectedState());
  }
}

class HADiscoveredBloc extends Bloc<DiscoveredEvent, HAConnectedState> {
  late HADiscoveredRepository _repository;

  HADiscoveredBloc(HADiscoveredRepository repository)
      : super(HAConnectedState()) {
    _repository = repository;
    on<FindHAInstancesEvent>(_onFindHAInstances);
  }

  FutureOr<void> _onFindHAInstances(
      event, Emitter<HAConnectedState> emit) async {
    print("Finding HA Instances...");
    await for (final service in _repository.find()) {
      print("please give me something");
      emit(HAConnectedState()..fromService(service));
    }
  }
}
