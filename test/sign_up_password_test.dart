import 'package:fluffychat/pages/sign_up_password.dart';
import 'package:fluffychat/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test if the widget can be created', (WidgetTester tester) async {
    await tester.pumpWidget(
      FluffyChatApp(
        testWidget: SignUpPassword(),
      ),
    );
  });
}
