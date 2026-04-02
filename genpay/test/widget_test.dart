import 'package:flutter_test/flutter_test.dart';
import 'package:genpay/main.dart';

void main() {
  testWidgets('GenPay app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const GenPayApp());
    expect(find.text('GenPay'), findsAny);
  });
}
