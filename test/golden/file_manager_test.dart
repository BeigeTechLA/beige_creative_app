import 'package:beige_creative_app/app/colors.dart';
import 'package:beige_creative_app/app/spacing.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/file_type.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_node.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/link_state.dart';
import 'package:beige_creative_app/features/file_manager/presentation/widgets/fm_file_card.dart';
import 'package:beige_creative_app/features/file_manager/presentation/widgets/fm_folder_card.dart';
import 'package:beige_creative_app/features/file_manager/presentation/widgets/fm_linked_badge.dart';
import 'package:beige_creative_app/features/file_manager/presentation/widgets/fm_tag_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tests for file-manager cards. Each test sizes its own viewport
/// to fit the rendered content without overflow.

Future<void> _pumpAt(
  WidgetTester tester, {
  required Size logicalSize,
  required Widget child,
}) async {
  tester.view.physicalSize = logicalSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('FmTagChip + FmLinkedBadge variants', (tester) async {
    await _pumpAt(
      tester,
      logicalSize: const Size(540, 280),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FmTagChip(label: 'Corporate Event'),
              FmTagChip(label: 'Wedding'),
            ],
          ),
          SizedBox(height: AppSpacing.base),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FmLinkedBadge(state: LinkState.linked),
              FmLinkedBadge(state: LinkState.unlinked),
            ],
          ),
        ],
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/fm_chip_badge_dark.png'),
    );
  });

  testWidgets('FmFolderCard — tagged + linked', (tester) async {
    final opened = DateTime.now().subtract(const Duration(hours: 2));
    await _pumpAt(
      tester,
      logicalSize: const Size(560, 360),
      child: FmFolderCard(
        folder: FmFolder(
          id: 'a',
          name: 'Corporate_Lana_#123456',
          fileCount: 2,
          openedAt: opened,
          tagLabel: 'Corporate Event',
          linkState: LinkState.linked,
        ),
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/fm_folder_card_tagged_dark.png'),
    );
  });

  testWidgets('FmFolderCard — plain', (tester) async {
    final opened = DateTime.now().subtract(const Duration(hours: 2));
    await _pumpAt(
      tester,
      logicalSize: const Size(480, 220),
      child: FmFolderCard(
        folder: FmFolder(
          id: 'b',
          name: 'Drafts',
          fileCount: 1,
          openedAt: opened,
        ),
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/fm_folder_card_plain_dark.png'),
    );
  });

  testWidgets('FmFileCard — pdf', (tester) async {
    final opened = DateTime.now().subtract(const Duration(hours: 3));
    await _pumpAt(
      tester,
      logicalSize: const Size(420, 420),
      child: FmFileCard(
        file: FmFile(
          id: 'f1',
          name: 'Example.pdf',
          type: FileType.pdf,
          sizeBytes: 100,
          downloadUrl: 'https://x/example.pdf',
          openedAt: opened,
        ),
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/fm_file_card_pdf_dark.png'),
    );
  });

  testWidgets('FmFileCard — video', (tester) async {
    final opened = DateTime.now().subtract(const Duration(hours: 3));
    await _pumpAt(
      tester,
      logicalSize: const Size(420, 420),
      child: FmFileCard(
        file: FmFile(
          id: 'f2',
          name: 'Edit_v1.mp4',
          type: FileType.video,
          sizeBytes: 100,
          downloadUrl: 'https://x/edit.mp4',
          openedAt: opened,
        ),
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/fm_file_card_video_dark.png'),
    );
  });
}
