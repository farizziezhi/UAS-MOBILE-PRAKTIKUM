import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_gacha/main.dart';

void main() {
  testWidgets('App should render MainScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const PokedexGachaApp());
    // Verifikasi BottomNavigationBar ada
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
