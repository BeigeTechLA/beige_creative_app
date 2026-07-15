import 'package:beige_creative_app/features/file_manager/domain/models/file_type.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_folder_key.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_node.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_phase.dart';
import 'package:beige_creative_app/features/file_manager/presentation/widgets/fm_file_preview_sheet.dart';
import 'package:beige_creative_app/features/file_manager/presentation/widgets/fm_status_pill.dart';
import 'package:beige_creative_app/features/file_manager/presentation/widgets/fm_upload_sheet.dart';
import 'package:beige_creative_app/features/file_manager/presentation/widgets/fm_version_tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('FileManager Expanded UI Widgets', () {
    testWidgets('FmVersionTag renders version numbers correctly', (tester) async {
      await tester.pumpProviderApp(
        const FmVersionTag(version: 2, isLatest: true),
      );
      await tester.pumpAndSettle();

      expect(find.text('V2'), findsOneWidget);
      expect(find.text('Latest'), findsOneWidget);
    });

    testWidgets('FmStatusPill renders status labels correctly', (tester) async {
      await tester.pumpProviderApp(
        const FmStatusPill(label: 'File Selected For Edits'),
      );
      await tester.pumpAndSettle();

      expect(find.text('File Selected For Edits'), findsOneWidget);
      expect(find.byIcon(Icons.edit_note_outlined), findsOneWidget);
    });

    testWidgets('FmFilePreviewSheet renders preview, metadata, and comments', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final file = FmFile(
        id: 'fil_test_preview',
        name: 'Draft_Proposal.pdf',
        type: FileType.pdf,
        sizeBytes: 1536 * 1024, // 1.5MB
        downloadUrl: 'https://files.dummy/test/proposal.pdf',
        openedAt: DateTime.now().subtract(const Duration(days: 1)),
        version: 3,
        isLatest: true,
        statusLabel: 'Raw Files Uploaded',
        uploaderName: 'Alex Rivera',
      );

      await tester.pumpProviderApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => FmFilePreviewSheet.show(context, file),
            child: const Text('Show Sheet'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open the sheet
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Draft_Proposal.pdf'), findsOneWidget);
      expect(find.text('1.5 MB'), findsOneWidget);
      expect(find.text('V3'), findsNWidgets(2)); // Badge + Metadata row
      expect(find.text('Raw Files Uploaded'), findsOneWidget);
      expect(find.text('Uploaded by'), findsOneWidget);
      expect(find.text('Alex Rivera'), findsOneWidget);
      expect(find.text('Add a comment...'), findsOneWidget);
    });

    testWidgets('FmUploadSheet displays empty dropzone and picking state', (tester) async {
      await tester.pumpProviderApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => FmUploadSheet.show(
              context,
              const FmFolderKey(externalId: 'fld_post', phase: FmPhase.post),
              'Post Production',
            ),
            child: const Text('Show Upload'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open upload sheet
      await tester.tap(find.text('Show Upload'));
      await tester.pumpAndSettle();

      expect(find.text('Upload Files'), findsNWidgets(2)); // Header + Button
      expect(find.text('Uploading to folder: Post Production'), findsOneWidget);
      expect(find.text('Drag and drop files here or browse'), findsOneWidget);
      expect(find.text('Browse Files'), findsOneWidget);
    });
  });
}
