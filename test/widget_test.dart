import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire_game/main.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    await tester.pumpWidget(const SolitaireApp());
    expect(find.text('Solitaire'), findsWidgets);
  });
}
