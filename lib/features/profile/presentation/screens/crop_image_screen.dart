import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

/// Full-screen profile image cropper.
/// Provides smooth full-range pan & scale inside a circular lens without
/// bottom sheet gesture conflicts.
class CropImageScreen extends StatefulWidget {
  const CropImageScreen({
    super.key,
    required this.imageFile,
    this.outputSize = 512,
  });

  final File imageFile;
  final int outputSize;

  @override
  State<CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  ui.Image? _decodedImage;
  bool _isLoading = true;
  bool _isSaving = false;

  double _userScale = 1.0;
  double _startScale = 1.0;

  Offset _offset = Offset.zero;
  Offset _startOffset = Offset.zero;
  Offset _startFocalPoint = Offset.zero;

  int _rotationQuarterTurns = 0; // 0=0°, 1=90°, 2=180°, 3=270°

  static const double _circleDiameter = 280.0;
  static const double _backdropBoxSize = 330.0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _decodedImage = frame.image;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Calculates effective image width & height considering rotation.
  double get _effectiveImgW {
    if (_decodedImage == null) return _circleDiameter;
    return (_rotationQuarterTurns % 2 == 1)
        ? _decodedImage!.height.toDouble()
        : _decodedImage!.width.toDouble();
  }

  double get _effectiveImgH {
    if (_decodedImage == null) return _circleDiameter;
    return (_rotationQuarterTurns % 2 == 1)
        ? _decodedImage!.width.toDouble()
        : _decodedImage!.height.toDouble();
  }

  /// Calculates display size (fitted image dimensions).
  Size _calculateFittedSize() {
    final imgW = _effectiveImgW;
    final imgH = _effectiveImgH;
    final aspect = imgW / imgH;

    double fittedW;
    double fittedH;

    if (aspect >= 1.0) {
      fittedH = _backdropBoxSize;
      fittedW = fittedH * aspect;
      if (fittedW < _circleDiameter) {
        fittedW = _circleDiameter;
        fittedH = fittedW / aspect;
      }
    } else {
      fittedW = _backdropBoxSize;
      fittedH = fittedW / aspect;
      if (fittedH < _circleDiameter) {
        fittedH = _circleDiameter;
        fittedW = fittedH * aspect;
      }
    }

    return Size(fittedW, fittedH);
  }

  /// Clamps offset allowing full reach to all corners & edges of the image inside circle.
  Offset _clampOffset(Offset rawOffset, double userScale) {
    final fittedSize = _calculateFittedSize();
    final displayW = fittedSize.width * userScale;
    final displayH = fittedSize.height * userScale;

    final maxDx = (displayW / 2.0) + (_circleDiameter / 2.0) - 20.0;
    final maxDy = (displayH / 2.0) + (_circleDiameter / 2.0) - 20.0;

    final clampedX = rawOffset.dx.clamp(-maxDx, maxDx);
    final clampedY = rawOffset.dy.clamp(-maxDy, maxDy);

    return Offset(clampedX, clampedY);
  }

  void _rotateClockwise() {
    setState(() {
      _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4;
      _offset = _clampOffset(_offset, _userScale);
    });
  }

  void _resetTransform() {
    setState(() {
      _userScale = 1.0;
      _offset = Offset.zero;
      _rotationQuarterTurns = 0;
    });
  }

  Future<void> _handleSave() async {
    if (_decodedImage == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final croppedFile = await _cropImage();
      if (mounted) {
        context.pop(croppedFile);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<File?> _cropImage() async {
    if (_decodedImage == null) return null;

    // Step 1: Handle rotation if needed
    ui.Image workingImage = _decodedImage!;
    final turns = _rotationQuarterTurns % 4;

    if (turns != 0) {
      final rotW =
          (turns % 2 == 1) ? workingImage.height : workingImage.width;
      final rotH =
          (turns % 2 == 1) ? workingImage.width : workingImage.height;

      final rotRecorder = ui.PictureRecorder();
      final rotCanvas = Canvas(rotRecorder);

      rotCanvas.translate(rotW / 2.0, rotH / 2.0);
      rotCanvas.rotate(turns * (math.pi / 2.0));
      rotCanvas.drawImage(
        workingImage,
        Offset(-workingImage.width / 2.0, -workingImage.height / 2.0),
        Paint()..filterQuality = FilterQuality.high,
      );

      final rotPic = rotRecorder.endRecording();
      workingImage = await rotPic.toImage(rotW, rotH);
    }

    // Step 2: Render crisp cropped PNG matching exact UI layout
    final outSize = widget.outputSize.toDouble();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw blurred image backdrop to fill background smoothly
    final backdropPaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.medium;

    canvas.drawImageRect(
      workingImage,
      Rect.fromLTWH(
        0,
        0,
        workingImage.width.toDouble(),
        workingImage.height.toDouble(),
      ),
      Rect.fromLTWH(0, 0, outSize, outSize),
      backdropPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, outSize, outSize),
      Paint()..color = AppColors.black.withValues(alpha: 0.40),
    );

    // Render sharp photo matching UI scale & offset
    final fittedSize = _calculateFittedSize();
    final userScale = _userScale;
    final clampedOffset = _clampOffset(_offset, userScale);

    final uiToCanvasScale = outSize / _circleDiameter;
    final displayW = fittedSize.width * userScale;
    final displayH = fittedSize.height * userScale;

    final canvasImgW = displayW * uiToCanvasScale;
    final canvasImgH = displayH * uiToCanvasScale;

    final canvasCenterX = (outSize / 2.0) + (clampedOffset.dx * uiToCanvasScale);
    final canvasCenterY = (outSize / 2.0) + (clampedOffset.dy * uiToCanvasScale);

    final canvasImgLeft = canvasCenterX - (canvasImgW / 2.0);
    final canvasImgTop = canvasCenterY - (canvasImgH / 2.0);

    final sharpPaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;

    canvas.drawImageRect(
      workingImage,
      Rect.fromLTWH(
        0,
        0,
        workingImage.width.toDouble(),
        workingImage.height.toDouble(),
      ),
      Rect.fromLTWH(canvasImgLeft, canvasImgTop, canvasImgW, canvasImgH),
      sharpPaint,
    );

    final picture = recorder.endRecording();
    final croppedImage = await picture.toImage(
      widget.outputSize,
      widget.outputSize,
    );

    final byteData = await croppedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) return null;

    final tempDir = await getTemporaryDirectory();
    final cropPath =
        "${tempDir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.png";
    final file = File(cropPath);
    await file.writeAsBytes(byteData.buffer.asUint8List());

    return file;
  }

  @override
  Widget build(BuildContext context) {
    final fittedSize = _calculateFittedSize();
    final clampedOffset = _clampOffset(_offset, _userScale);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER TITLE & BACK BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: AppRadii.hugeAll,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: SvgPicture.asset(
                        AppAssets.back,
                        height: 24,
                        width: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Crop Profile Photo",
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.white,
                      fontFamily: AppAssets.fontOutfit,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: _resetTransform,
                    tooltip: "Reset",
                    icon: const Icon(
                      Icons.restart_alt,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.dividerDark, height: 1),

            /// MAIN CROPPING AREA
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onScaleStart: (details) {
                        setState(() {
                          _startScale = _userScale;
                          _startOffset = _offset;
                          _startFocalPoint = details.focalPoint;
                        });
                      },
                      onScaleUpdate: (details) {
                        setState(() {
                          final nextScale =
                              (_startScale * details.scale).clamp(1.0, 4.0);
                          _userScale = nextScale;
                          final delta = details.focalPoint - _startFocalPoint;
                          _offset =
                              _clampOffset(_startOffset + delta, nextScale);
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// "Move and scale" SUBHEADER
                          Text(
                            "Move and scale",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          AppSpacing.verticalXl,

                          /// CROPPER AREA: SHARP CIRCLE LENS OVER BLURRED PHOTO BACKDROP
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 350,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                /// 1. BLURRED PHOTO BACKDROP (FULL CONTAINER)
                                SizedBox(
                                  width: _backdropBoxSize,
                                  height: _backdropBoxSize,
                                  child: ClipRect(
                                    child: ImageFiltered(
                                      imageFilter: ui.ImageFilter.blur(
                                        sigmaX: 18,
                                        sigmaY: 18,
                                      ),
                                      child: Container(
                                        color: AppColors.black.withValues(
                                          alpha: 0.4,
                                        ),
                                        child: OverflowBox(
                                          maxWidth: double.infinity,
                                          maxHeight: double.infinity,
                                          child: Transform.translate(
                                            offset: clampedOffset,
                                            child: Transform.scale(
                                              scale: _userScale,
                                              child: RotatedBox(
                                                quarterTurns:
                                                    _rotationQuarterTurns,
                                                child: Image.file(
                                                  widget.imageFile,
                                                  width: fittedSize.width,
                                                  height: fittedSize.height,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                /// DARK OVERLAY SHADE ON BLURRED BACKDROP
                                Container(
                                  width: _backdropBoxSize,
                                  height: _backdropBoxSize,
                                  color:
                                      AppColors.black.withValues(alpha: 0.35),
                                ),

                                /// 2. SHARP UNBLURRED PHOTO (INSIDE CIRCLE LENS)
                                SizedBox(
                                  width: _circleDiameter,
                                  height: _circleDiameter,
                                  child: ClipOval(
                                    child: Stack(
                                      children: [
                                        /// BLURRED BACKDROP FILL INSIDE CIRCLE FOR UNCOVERED CORNERS
                                        Positioned.fill(
                                          child: ImageFiltered(
                                            imageFilter: ui.ImageFilter.blur(
                                              sigmaX: 18,
                                              sigmaY: 18,
                                            ),
                                            child: Image.file(
                                              widget.imageFile,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Container(
                                            color: AppColors.black.withValues(
                                              alpha: 0.35,
                                            ),
                                          ),
                                        ),

                                        /// SHARP PHOTO LAYER
                                        Positioned.fill(
                                          child: OverflowBox(
                                            maxWidth: double.infinity,
                                            maxHeight: double.infinity,
                                            child: Transform.translate(
                                              offset: clampedOffset,
                                              child: Transform.scale(
                                                scale: _userScale,
                                                child: RotatedBox(
                                                  quarterTurns:
                                                      _rotationQuarterTurns,
                                                  child: Image.file(
                                                    widget.imageFile,
                                                    width: fittedSize.width,
                                                    height: fittedSize.height,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                /// 3. CRISP WHITE CIRCLE RING BORDER
                                IgnorePointer(
                                  child: Container(
                                    width: _circleDiameter,
                                    height: _circleDiameter,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            /// TOOLBAR (ROTATE & RESET)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _rotateClockwise,
                    icon: const Icon(
                      Icons.rotate_90_degrees_cw_outlined,
                      color: AppColors.white70,
                      size: 20,
                    ),
                    label: Text(
                      "Rotate",
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  AppSpacing.gapHMd,
                  TextButton.icon(
                    onPressed: _resetTransform,
                    icon: const Icon(
                      Icons.center_focus_strong,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    label: Text(
                      "Center",
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// ZOOM SLIDER
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.imageZoom,
                    height: 18,
                    width: 18,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white70,
                      BlendMode.srcIn,
                    ),
                  ),
                  AppSpacing.gapHSmd,
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 5,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 9,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14,
                        ),
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.white.withValues(
                          alpha: 0.3,
                        ),
                        thumbColor: AppColors.primary,
                      ),
                      child: Slider(
                        min: 1.0,
                        max: 4.0,
                        value: _userScale,
                        onChanged: (v) {
                          setState(() {
                            _userScale = v;
                            _offset = _clampOffset(_offset, v);
                          });
                        },
                      ),
                    ),
                  ),
                  AppSpacing.gapHSmd,
                  SvgPicture.asset(
                    AppAssets.imageZoom,
                    height: 24,
                    width: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalBase,

            /// PRIMARY ACTION BUTTON ("Save Profile Photo")
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.lgAll,
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.black,
                          ),
                        )
                      : Text(
                          "Save Profile Photo",
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.black,
                            fontFamily: AppAssets.fontUnbounded,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            AppSpacing.verticalSm,
          ],
        ),
      ),
    );
  }
}
