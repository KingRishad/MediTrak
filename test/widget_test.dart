import 'package:flutter_test/flutter_test.dart';

import 'package:meditrak/main.dart';

void main() {
  testWidgets('MediTrack smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MediTrack());

    // Verify that MediTrack title and Login button are present.
    expect(find.text('MediTrack'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
