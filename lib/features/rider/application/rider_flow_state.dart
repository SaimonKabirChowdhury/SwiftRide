import '../domain/rider_stage.dart';

class RiderFlowState {
  const RiderFlowState({
    this.stage = RiderStage.signIn,
    this.history = const [],
    this.otp = '',
    this.selectedRide = 'SwiftGo',
    this.paymentMethod = 'Visa •••• 4821',
    this.rating = 0,
    this.tip = 0,
    this.tripShared = false,
  });

  final RiderStage stage;
  final List<RiderStage> history;
  final String otp;
  final String selectedRide;
  final String paymentMethod;
  final int rating;
  final int tip;
  final bool tripShared;

  RiderFlowState copyWith({
    RiderStage? stage,
    List<RiderStage>? history,
    String? otp,
    String? selectedRide,
    String? paymentMethod,
    int? rating,
    int? tip,
    bool? tripShared,
  }) {
    return RiderFlowState(
      stage: stage ?? this.stage,
      history: history ?? this.history,
      otp: otp ?? this.otp,
      selectedRide: selectedRide ?? this.selectedRide,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      rating: rating ?? this.rating,
      tip: tip ?? this.tip,
      tripShared: tripShared ?? this.tripShared,
    );
  }
}
