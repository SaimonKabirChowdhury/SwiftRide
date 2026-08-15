import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftride/features/rider/application/rider_flow_controller.dart';
import 'package:swiftride/features/rider/domain/rider_stage.dart';

void main() {
  test('rider flow supports forward and back navigation', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(riderFlowControllerProvider.notifier);
    controller.go(RiderStage.otp);
    expect(container.read(riderFlowControllerProvider).stage, RiderStage.otp);

    controller.back();
    expect(
      container.read(riderFlowControllerProvider).stage,
      RiderStage.signIn,
    );
  });

  test('booking selections remain in immutable flow state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(riderFlowControllerProvider.notifier);

    controller.selectRide('SwiftXL');
    controller.selectPayment('Cash');
    controller.setRating(5);

    final state = container.read(riderFlowControllerProvider);
    expect(state.selectedRide, 'SwiftXL');
    expect(state.paymentMethod, 'Cash');
    expect(state.rating, 5);
  });
}
