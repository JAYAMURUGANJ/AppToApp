import 'package:flutter_nps/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('renders CapturePage', (tester) async {
      await tester.pumpWidget(const SampleApp());
      expect(find.byType(SamplePage), findsOneWidget);
    });
  });
}
