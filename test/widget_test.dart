import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meditrak/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MediTrack smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MediTrack());
    await tester.pumpAndSettle();

    // Verify that MediTrak title and Login button are present when not logged in.
    expect(find.text('MediTrak'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
