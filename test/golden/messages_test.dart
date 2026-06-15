import 'package:beige_creative_app/app/colors.dart';
import 'package:beige_creative_app/app/spacing.dart';
import 'package:beige_creative_app/app/text_styles.dart';
import 'package:beige_creative_app/features/messages/domain/entities/conversation.dart';
import 'package:beige_creative_app/features/messages/domain/entities/message.dart';
import 'package:beige_creative_app/features/messages/presentation/screens/widgets/audio_bubble.dart';
import 'package:beige_creative_app/features/messages/presentation/screens/widgets/conversation_tile.dart';
import 'package:beige_creative_app/features/messages/presentation/screens/widgets/details_section_card.dart';
import 'package:beige_creative_app/features/messages/presentation/screens/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden coverage for message-specific UI surfaces added in Phase M5.
///
/// Regenerate with:
/// `flutter test --update-goldens test/golden/messages_test.dart`

final _sentAt = DateTime(2026, 1, 23, 9, 25);

Widget _frame(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: SizedBox(width: 390, child: child)),
    ),
  );
}

Future<void> _pumpFrame(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(_frame(child));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('ConversationTile — unread and online state', (tester) async {
    await _pumpFrame(
      tester,
      ConversationTile(
        conversation: Conversation(
          id: 'conv_001',
          title: 'Angela Kia',
          unreadCount: 3,
          isOnline: true,
          participantIds: const ['user_me', 'user_angela'],
          lastMessage: ConversationPreview(
            preview: "Hey! How's it going?",
            sentAt: _sentAt,
            fromMe: false,
          ),
        ),
        onTap: () {},
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/messages_conversation_tile_dark.png'),
    );
  });

  testWidgets('MessageBubble — incoming, outgoing, and audio', (tester) async {
    await _pumpFrame(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MessageBubble(
            message: Message(
              id: 'm1',
              senderId: 'user_angela',
              senderName: 'Angela Kia',
              type: MessageType.text,
              body: 'Hello! Puerto, how are you?',
              sentAt: _sentAt,
            ),
            isMine: false,
            showSenderHeader: true,
          ),
          MessageBubble(
            message: Message(
              id: 'm2',
              senderId: 'user_me',
              senderName: 'Me',
              type: MessageType.text,
              body: 'You did your job well!',
              sentAt: _sentAt,
              deliveryStatus: DeliveryStatus.read,
            ),
            isMine: true,
            showSenderHeader: true,
          ),
          AudioBubble(
            message: Message(
              id: 'm3',
              senderId: 'user_me',
              senderName: 'Me',
              type: MessageType.file,
              sentAt: _sentAt,
              file: const MessageFile(
                url: 'local://voice',
                name: 'voice.m4a',
                mimeType: 'audio/m4a',
                sizeBytes: 0,
                durationMs: 16000,
              ),
            ),
            isMine: true,
            showSenderHeader: false,
          ),
        ],
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/messages_bubbles_dark.png'),
    );
  });

  testWidgets('DetailsSectionCard — expanded body', (tester) async {
    await _pumpFrame(
      tester,
      DetailsSectionCard(
        icon: Icons.folder_outlined,
        title: 'Shared Files',
        trailingCount: 2,
        initiallyExpanded: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Shoot - Jan 2026',
              style: AppTextStyles.bodyMediumStrong.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '24 files',
              style: AppTextStyles.body12.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/messages_details_section_card_dark.png'),
    );
  });
}
