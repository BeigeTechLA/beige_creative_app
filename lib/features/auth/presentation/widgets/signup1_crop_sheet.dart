import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';

/// Opens the circular profile-crop bottom sheet for [imageFile]. When the
/// user taps Save, the cropped file is returned. Tapping the close icon (or
/// dismissing the sheet) returns `null`.
Future<File?> showSignUp1CropSheet({
  required BuildContext context,
  required File imageFile,
}) {
  return showModalBottomSheet<File?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) => _SignUp1CropSheet(imageFile: imageFile),
  );
}

class _SignUp1CropSheet extends StatefulWidget {
  final File imageFile;
  const _SignUp1CropSheet({required this.imageFile});

  @override
  State<_SignUp1CropSheet> createState() => _SignUp1CropSheetState();
}

class _SignUp1CropSheetState extends State<_SignUp1CropSheet> {
  Offset offset = Offset.zero;
  double scale = 1.0;
  double startScale = 1.0;
  Offset startOffset = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surfaceCropSheet,
        borderRadius: AppRadii.topMassive,
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
                "Crop your Profile",
                style: AppTextStyles.body18Medium.copyWith(
                  color: AppColors.white,
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: AppRadii.hugeAll,
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  child: Icon(Icons.close, color: AppColors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.dividerDark),
          Expanded(
            child: Center(
              child: GestureDetector(
                onScaleStart: (details) {
                  startScale = scale;
                  startOffset = offset;
                  _lastFocalPoint = details.focalPoint;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    scale = (startScale * details.scale).clamp(1.0, 4.0);
                    final delta = details.focalPoint - _lastFocalPoint;
                    offset = offset + delta;
                    _lastFocalPoint = details.focalPoint;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRect(
                      child: SizedBox(
                        width: double.infinity,
                        height: 320,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..translateByDouble(offset.dx, offset.dy, 0, 1)
                            ..scaleByDouble(scale, scale, 1, 1),
                          child: Image.file(
                            widget.imageFile,
                            fit: BoxFit.cover,
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
                SvgPicture.asset(AppAssets.imageZoom, height: 20, width: 20),
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
                SvgPicture.asset(AppAssets.imageZoom, height: 20, width: 20),
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
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.lgAll,
                ),
                elevation: 0,
              ),
              onPressed: () async {
                final cropped =
                    await cropSignUp1Image(widget.imageFile, scale, offset);
                if (!context.mounted) return;
                Navigator.pop(context, cropped);
              },
              child: Text(
                "Save",
                style: AppTextStyles.displayLabel14.copyWith(
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<File?> cropSignUp1Image(
  File imageFile,
  double scale,
  Offset offset,
) async {
  try {
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final ui.Image image = frame.image;

    const double uiSize = 320;
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
      "${dir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.png",
    );
    await file.writeAsBytes(data!.buffer.asUint8List());
    return file;
  } catch (e) {
    debugPrint("Crop failed: $e");
    return null;
  }
}

class CircleHolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.black.withValues(alpha: 0.6),
    );

    final center = Offset(size.width / 2, size.height / 2);
    const radius = 130.0;
    canvas.drawCircle(center, radius, Paint()..blendMode = BlendMode.clear);

    canvas.restore();

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
