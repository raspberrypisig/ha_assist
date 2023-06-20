import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ha_assist/models.dart';

class HAConnectionBloc extends Bloc<ConnectionStatusEvent, HAConnectionState> {
  HAConnectionBloc(super.initialState) {
    on<ConnectionStatusEvent>(_onConnectionStatus);
  }

  FutureOr<void> _onConnectionStatus(
      ConnectionStatusEvent event, Emitter<HAConnectionState> emit) {
    emit(HADisconnectedState());
  }
}
