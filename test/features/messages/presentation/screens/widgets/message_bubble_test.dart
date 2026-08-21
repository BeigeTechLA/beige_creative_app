import 'package:beige_creative_app/app/colors.dart';
import 'package:beige_creative_app/features/messages/domain/entities/message.dart';
import 'package:beige_creative_app/features/messages/presentation/screens/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _frame(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: child),
    ),
  );
}

void main() {
  group('MessageBubble System Notice Tests', () {
    testWidgets('displays normal system message unchanged', (tester) async {
      final message = Message(
        id: 'sys_1',
        senderId: 'system',
        senderName: 'System',
        type: MessageType.system,
        body: 'This is a normal system alert',
        sentAt: DateTime.now(),
      );

      await tester.pumpWidget(
        _frame(
          MessageBubble(
            message: message,
            isMine: false,
            showSenderHeader: false,
          ),
        ),
      );

      expect(find.text('This is a normal system alert'), findsOneWidget);
    });

    testWidgets('strips the trailing " as <role>" suffix', (tester) async {
      final message = Message(
        id: 'sys_2',
        senderId: 'system',
        senderName: 'System',
        type: MessageType.system,
        body: 'Krunal added John as Admin',
        sentAt: DateTime.now(),
      );

      await tester.pumpWidget(
        _frame(
          MessageBubble(
            message: message,
            isMine: false,
            showSenderHeader: false,
          ),
        ),
      );

      expect(find.text('Krunal added John'), findsOneWidget);
      expect(find.text('Krunal added John as Admin'), findsNothing);
    });

    testWidgets('strips another role format e.g. " as Participant"', (tester) async {
      final message = Message(
        id: 'sys_3',
        senderId: 'system',
        senderName: 'System',
        type: MessageType.system,
        body: 'Alice added Bob as Participant',
        sentAt: DateTime.now(),
      );

      await tester.pumpWidget(
        _frame(
          MessageBubble(
            message: message,
            isMine: false,
            showSenderHeader: false,
          ),
        ),
      );

      expect(find.text('Alice added Bob'), findsOneWidget);
      expect(find.text('Alice added Bob as Participant'), findsNothing);
    });
  });
}
