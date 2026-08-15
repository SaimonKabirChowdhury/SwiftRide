import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/rider_stage.dart';
import 'rider_flow_state.dart';

final riderFlowControllerProvider =
    NotifierProvider<RiderFlowController, RiderFlowState>(
      RiderFlowController.new,
    );

class RiderFlowController extends Notifier<RiderFlowState> {
  Timer? _matchTimer;

  @override
  RiderFlowState build() {
    ref.onDispose(() => _matchTimer?.cancel());
    return const RiderFlowState();
  }

  void go(RiderStage next, {bool remember = true}) {
    _matchTimer?.cancel();
    final history = remember ? [...state.history, state.stage] : state.history;
    state = state.copyWith(stage: next, history: List.unmodifiable(history));
  }

  void back() {
    _matchTimer?.cancel();
    if (state.history.isEmpty) return;
    final history = [...state.history];
    final previous = history.removeLast();
    state = state.copyWith(
      stage: previous,
      history: List.unmodifiable(history),
    );
  }

  void resetToHome() {
    _matchTimer?.cancel();
    state = state.copyWith(stage: RiderStage.home, history: const []);
  }

  void startMatching() {
    go(RiderStage.searching);
    _matchTimer = Timer(const Duration(seconds: 4), () {
      if (state.stage == RiderStage.searching) go(RiderStage.matched);
    });
  }

  void appendOtp(String digit) {
    if (state.otp.length >= 6) return;
    state = state.copyWith(otp: '${state.otp}$digit');
  }

  void deleteOtpDigit() {
    if (state.otp.isEmpty) return;
    state = state.copyWith(otp: state.otp.substring(0, state.otp.length - 1));
  }

  void setOtp(String value) => state = state.copyWith(otp: value);
  void selectRide(String value) => state = state.copyWith(selectedRide: value);
  void selectPayment(String value) =>
      state = state.copyWith(paymentMethod: value);
  void setRating(int value) => state = state.copyWith(rating: value);
  void setTip(int value) => state = state.copyWith(tip: value);
  void markTripShared() => state = state.copyWith(tripShared: true);
}
