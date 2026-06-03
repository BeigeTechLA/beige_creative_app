import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../auth/presentation/widgets/signup1_crop_sheet.dart'
    show CircleHolePainter;

/// Custom crop bottom sheet shown after the user picks a new avatar.
/// Returns the cropped [File] via callback; parent decides what to do with it.
class ProfileImageCropSheet extends StatefulWidget {
  final File imageFile;
  final Future<void> Function(File cropped) onCropped;

  const ProfileImageCropSheet({
    super.key,
    required this.imageFile,
    required this.onCropped,
  });

  @override
  State<ProfileImageCropSheet> createState() => _ProfileImageCropSheetState();
}

class _ProfileImageCropSheetState extends State<ProfileImageCropSheet> {
  Offset offset = Offset.zero;
  Offset startOffset = Offset.zero;
  double scale = 1.0;
  double startScale = 1.0;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surfaceCropSheet,
        borderRadius: AppRadii.topRound,
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 35,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.white30,
                borderRadius: AppRadii.xxxlAll,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Crop your Profile',
                style: AppTextStyles.body18Medium
                    .copyWith(color: AppColors.white),
              ),
              InkWell(
                onTap: () => context.pop(),
                borderRadius: AppRadii.hugeAll,
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.dividerDark),
          Expanded(
            child: Center(
              child: GestureDetector(
                onScaleStart: (details) {
                  startScale = scale;
                  startOffset = offset;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    scale = (startScale * details.scale).clamp(1.0, 4.0);
                    offset += details.focalPointDelta;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRect(
                      child: SizedBox(
                        width: 320,
                        height: 320,
                        child: ClipRect(
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..translateByDouble(offset.dx, offset.dy, 0, 1)
                              ..scaleByDouble(scale, scale, 1, 1),
                            child: Image.file(
                              widget.imageFile,
                              width: 340,
                              height: 340,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: CustomPaint(
                        size: const Size(320, 320),
                        painter: CircleHolePainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppAssets.imageZoom,
                  height: 20,
                  width: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor:
                          AppColors.white.withValues(alpha: 0.3),
                      thumbColor: AppColors.primary,
                    ),
                    child: Slider(
                      min: 1,
                      max: 5,
                      value: scale,
                      onChanged: (v) => setState(() => scale = v),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SvgPicture.asset(
                  AppAssets.imageZoom,
                  height: 26,
                  width: 26,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
                elevation: 0,
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      setState(() => isSaving = true);
                      try {
                        final cropped = await _cropImage(
                          widget.imageFile,
                          scale,
                          offset,
                        );
                        if (cropped != null) await widget.onCropped(cropped);
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        debugPrint('❌ Error: $e');
                      } finally {
                        if (context.mounted) {
                          setState(() => isSaving = false);
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.black),
                      ),
                    )
                  : const Text(
                      'Save',
                      style: AppTextStyles.displayLabel14,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pure function; doesn't touch widget state. Returns null on failure.
Future<File?> _cropImage(
    File imageFile, double scale, Offset offset) async {
  try {
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final ui.Image image = frame.image;

    const double uiSize = 360;
    const double cropUI = 260;

    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();

    final ratioX = imgW / uiSize;
    final ratioY = imgH / uiSize;
    final ratio = ratioX < ratioY ? ratioX : ratioY;

    final cropSize = (cropUI * ratio) / scale;

    double dx = (imgW / 2) - (cropSize / 2) - (offset.dx * ratio);
    double dy = (imgH / 2) - (cropSize / 2) - (offset.dy * ratio);

    dx = dx.clamp(0.0, imgW - cropSize);
    dy = dy.clamp(0.0, imgH - cropSize);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(dx, dy, cropSize, cropSize),
      Rect.fromLTWH(0, 0, cropSize, cropSize),
      paint,
    );

    final pic = recorder.endRecording();
    final cropped = await pic.toImage(cropSize.toInt(), cropSize.toInt());

    final data = await cropped.toByteData(format: ui.ImageByteFormat.png);

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    await file.writeAsBytes(data!.buffer.asUint8List());
    return file;
  } catch (e) {
    debugPrint('❌ Crop failed: $e');
    return null;
  }
}
