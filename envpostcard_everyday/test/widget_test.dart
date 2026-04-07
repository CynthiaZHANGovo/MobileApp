import 'package:envpostcard_everyday/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('environmental postcard app renders capture page', (tester) async {
    await tester.pumpWidget(const EnvironmentalPostcardApp());

    expect(find.text('Capture today on purpose.'), findsOneWidget);
    expect(find.text('Photo Input'), findsOneWidget);
    expect(find.text('Studio'), findsOneWidget);
  });
}
