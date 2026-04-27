import 'package:envpostcard_everyday/main.dart';
import 'package:envpostcard_everyday/screens/launch_splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('environmental postcard app shows splash then capture page', (tester) async {
    await tester.pumpWidget(const EnvironmentalPostcardApp());

    expect(find.byType(LaunchSplashPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 4300));
    await tester.pumpAndSettle();

    expect(find.text('Capture'), findsOneWidget);
    expect(find.byType(LaunchSplashPage), findsNothing);
    expect(find.byIcon(Icons.auto_awesome_mosaic_rounded), findsOneWidget);
  });
}
