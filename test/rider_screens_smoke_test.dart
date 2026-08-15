import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftride/app.dart';
import 'package:swiftride/features/rider/application/rider_flow_controller.dart';
import 'package:swiftride/features/rider/domain/rider_stage.dart';

void main() {
  testWidgets('every Rider stage renders without a framework exception', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final stage in RiderStage.values) {
      final container = ProviderContainer();
      final controller = container.read(riderFlowControllerProvider.notifier);
      controller.go(stage, remember: false);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const SwiftRideApp(),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'Failed at ${stage.name}');
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    }
  });
}
