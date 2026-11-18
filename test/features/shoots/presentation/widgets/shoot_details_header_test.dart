import 'dart:ui' as ui;

import 'package:beige_creative_app/app/theme.dart';
import 'package:beige_creative_app/features/shoots/presentation/widgets/shoot_details_header.dart';
import 'package:beige_creative_app/model_class/upcoming_shootview_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('white photo stays dark behind back throughout collapse', (
    tester,
  ) async {
    // Seed a genuinely white image without HTTP. A dark placeholder would hide
    // the regression where the top gradient scrolls away with the photograph.
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawRect(
      const Rect.fromLTWH(0, 0, 400, 400),
      Paint()..color = Colors.white,
    );
    final picture = recorder.endRecording();
    final white = await tester.runAsync(() => picture.toImage(400, 400));
    picture.dispose();
    const provider = CachedNetworkImageProvider(
      'https://example.test/white.png',
    );
    PaintingBinding.instance.imageCache.putIfAbsent(
      provider,
      () =>
          OneFrameImageStreamCompleter(Future.value(ImageInfo(image: white!))),
    );
    addTearDown(() => PaintingBinding.instance.imageCache.evict(provider));
    final controller = ScrollController();
    addTearDown(controller.dispose);
    const boundaryKey = ValueKey('header-contrast-capture');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: RepaintBoundary(
          key: boundaryKey,
          child: Scaffold(
            body: CustomScrollView(
              controller: controller,
              slivers: [
                ShootDetailsHeader(
                  project: Project.fromJson({
                    'project_name': 'Skyline',
                    'image_url': provider.url,
                  }),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 1500)),
              ],
            ),
          ),
        ),
      ),
    );
    for (final offset in [0.0, 140.0, 280.0, 350.0]) {
      controller.jumpTo(offset);
      await tester.pumpAndSettle();
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(boundaryKey),
      );
      final image = await tester.runAsync(() => boundary.toImage());
      final bytes = await tester.runAsync(
        () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
      );
      // Sample either side of the arrow, avoiding the white artwork itself.
      for (final x in [25, 60]) {
        final index = (28 * image!.width + x) * 4;
        for (var channel = 0; channel < 3; channel++) {
          expect(
            bytes!.getUint8(index + channel),
            lessThan(100),
            reason: 'Toolbar must stay dark at scroll offset $offset',
          );
        }
      }
      image!.dispose();
      expect(find.byTooltip('Back').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
