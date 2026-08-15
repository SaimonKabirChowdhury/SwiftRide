import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftride/app.dart';

void main() {
  testWidgets('renders the SwiftRide rider sign-in experience', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SwiftRideApp()));
    await tester.pumpAndSettle();

    expect(find.text('Ready when\nyou are.'), findsOneWidget);
    expect(find.text('Send verification code'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
  });
}
