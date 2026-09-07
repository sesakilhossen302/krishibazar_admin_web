import 'package:flutter_test/flutter_test.dart';
import 'package:krishibazar_admin_web/Core/Dependency/dependency.dart';
import 'package:krishibazar_admin_web/main.dart';

void main() {
  testWidgets('Web Admin App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(Dependency.wrapWithProviders(const KrishiAdminWebApp()));
    expect(find.byType(KrishiAdminWebApp), findsOneWidget);
  });
}
