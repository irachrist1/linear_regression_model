import 'package:flutter_test/flutter_test.dart';
import 'package:summartive_ml/main.dart';

void main() {
  testWidgets('Student Predictor app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DevPulseApp());
    expect(find.text('Student Predictor'), findsOneWidget);
    expect(find.text('Predict'), findsOneWidget);
  });
}
