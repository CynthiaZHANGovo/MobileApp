import 'package:envpostcard_everyday/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('environmental postcard app renders headline', (tester) async {
    await tester.pumpWidget(const EnvironmentalPostcardApp());

    expect(find.text('Environmental Postcard'), findsOneWidget);
    expect(find.text('生成今日环境明信片'), findsOneWidget);
  });
}
