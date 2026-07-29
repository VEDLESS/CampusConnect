import 'package:campus_connect/core/campus_connect_app.dart';
import 'package:campus_connect/features/auth/presentation/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows Firebase setup instructions before configuration', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [firebaseConfiguredProvider.overrideWithValue(false)],
        child: CampusConnectApp(),
      ),
    );

    expect(find.text('Connect Firebase to continue'), findsOneWidget);
  });
}
