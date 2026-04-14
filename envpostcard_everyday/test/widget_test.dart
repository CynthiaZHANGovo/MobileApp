import 'package:envpostcard_everyday/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('environmental postcard app renders capture page', (tester) async {
    await tester.pumpWidget(const EnvironmentalPostcardApp());

    expect(find.text('Capture'), findsOneWidget);
    expect(find.text('Photo Input'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome_mosaic_rounded), findsOneWidget);
  });
}
