import 'dart:io';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../app/route_names.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../service/google_config.dart';
import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/shadows.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/Topmessgae.dart';
import '../../widgets/app_loder.dart' show AppLoader;
import '../../widgets/common_uploader.dart';
import '../../widgets/custom_text_field.dart';

class SignUp1Screen extends StatefulWidget {
  const SignUp1Screen({super.key});

  @override
  State<SignUp1Screen> createState() => SignUp1ScreenState();
}

class SignUp1ScreenState extends State<SignUp1Screen> {
  Offset offset = Offset.zero;
  double scale = 1.0;
  Offset _lastFocalPoint = Offset.zero; // 👈 add karo
  bool isLocationFocused = false;

  File? profileImage;
  final FocusNode _locationFocus = FocusNode();
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool savePassword = false;
  bool isLoggingIn = false;

  GoogleMapController? mapController;
  LatLng? currentLatLng;
  bool showMap = false;
  String selectedAddress = "Search or select location";
  bool isMapOpen = false; // 👈 map show / hide
  bool _isPlusCode(String value) {
    return RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$').hasMatch(value);
  }

  String? selectedDistance;
  bool isLoading = false;

  //double scale = 1.0;
  double startScale = 1.0;

  // Offset offset = Offset.zero;
  Offset startOffset = Offset.zero;

  bool get isFormValid {
    return passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        savePassword; // ✅ checkbox must be checked
  }

  int _calculateCompletion() {
    int totalFields = 7; // 👈 total required fields count
    int filled = 0;

    if (firstNameController.text.trim().isNotEmpty) filled++;
    if (lastNameController.text.trim().isNotEmpty) filled++;
    if (emailController.text.trim().isNotEmpty) filled++;
    if (passwordController.text.trim().isNotEmpty) filled++;
    if (confirmPasswordController.text.trim().isNotEmpty) filled++;
    if (profileImage != null) filled++;
    if (selectedDistance != null && selectedDistance!.isNotEmpty) filled++;

    double percent = (filled / totalFields) * 30;
    return percent.toInt();
  }

  @override
  void initState() {
    super.initState();
    firstNameController.addListener(() => setState(() {}));
    lastNameController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
    _locationFocus.addListener(() {
      if (_locationFocus.hasFocus) {
        setState(() {
          showMap = true;
        });
      }
    });

    _getCurrentLocation();
  }

  bool get isPreviewVisible =>
      firstNameController.text.trim().isNotEmpty ||
      lastNameController.text.trim().isNotEmpty ||
      emailController.text.trim().isNotEmpty ||
      profileImage != null;

  Future<void> _pickImage() async {
    final file = await CommonUploader.pickFromGallery();

    if (file == null) return;

    openCustomCropSheet(file);
  }

  void openCustomCropSheet(File imageFile) {
    Offset offset = Offset.zero;
    double scale = 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                        onTap: () =>
                            Navigator.pop(context), // ❌ close bottom sheet
                        borderRadius: AppRadii.hugeAll,
                        child: Padding(
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

                  SizedBox(height: 20),

                  Divider(color: AppColors.dividerDark),

                  /// 🔥 CIRCULAR PREVIEW AREA
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onScaleStart: (details) {
                          startScale = scale;
                          startOffset = offset;
                          _lastFocalPoint = details.focalPoint;
                        },
                        onScaleUpdate: (details) {
                          setSheetState(() {
                            scale = (startScale * details.scale).clamp(
                              1.0,
                              4.0,
                            );
                            final delta = details.focalPoint - _lastFocalPoint;
                            offset = offset + delta;
                            _lastFocalPoint = details.focalPoint;
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            /// IMAGE (NOW CLIPPED)
                            ClipRect(
                              child: SizedBox(
                                width: double.infinity,
                                height: 320,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..translate(offset.dx, offset.dy)
                                    ..scale(scale),
                                  child: Image.file(
                                    imageFile,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            /// CIRCLE OVERLAY
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

                  /// 🔥 ZOOM SLIDER
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        /// 🔹 LEFT IMAGE ICON
                        SvgPicture.asset(
                          AppAssets.Image_zoom,
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(width: 10),

                        /// 🔹 SLIDER
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
                              inactiveTrackColor: AppColors.white.withValues(
                                alpha: 0.3,
                              ),
                              thumbColor: AppColors.primary,
                            ),
                            child: Slider(
                              min: 1,
                              max: 5,
                              value: scale,
                              onChanged: (v) {
                                setSheetState(() => scale = v);
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// 🔹 RIGHT IMAGE ICON
                        /// 🔹 LEFT IMAGE ICON
                        SvgPicture.asset(
                          AppAssets.Image_zoom,
                          height: 20,
                          width: 20,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 🔥 SAVE BUTTON
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
                        final cropped = await _cropImage(
                          imageFile,
                          scale,
                          offset,
                        );

                        if (cropped != null) {
                          setState(() {
                            profileImage = cropped;
                          });
                        }

                        Navigator.pop(context);
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
          },
        );
      },
    );
  }

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Future<void> searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        final loc = locations.first;

        final latLng = LatLng(loc.latitude, loc.longitude);

        setState(() {
          currentLatLng = latLng;
        });

        mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));

        await getAddressFromLatLng(latLng);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Location not found")));
    }
  }

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final address =
            "${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";

        setState(() {
          selectedAddress = address;

          /// 🔥 IMPORTANT: TextField ko bhi update karo
          searchController.text = address;
        });
      }
    } catch (e) {
      debugPrint("Reverse geocode error: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location permission permanently denied. Enable from settings.",
          ),
        ),
      );
      await Geolocator.openAppSettings(); // 👈 Open app settings
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _updateLocationFromLatLng(LatLng latLng) async {
    setState(() {
      currentLatLng = latLng;
    });

    mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));

    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        // 🔥 BUILD CLEAN ADDRESS (NO PLUS CODE)
        final parts = <String>[
          if (p.name != null && !_isPlusCode(p.name!)) p.name!,
          if (p.subLocality != null) p.subLocality!,
          if (p.locality != null) p.locality!,
          if (p.administrativeArea != null) p.administrativeArea!,
        ];

        selectedAddress = parts.join(', ');

        searchController.text = selectedAddress;
        searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: searchController.text.length),
        );
      }
    } catch (e) {
      debugPrint("Reverse geocode error: $e");
    }
  }

  final List<String> distances = [
    "Upto 50 Miles",
    "Upto 75 miles",
    "Upto 100 miles",
    "I’m open to traveling",
  ];
  Future<File?> _cropImage(File imageFile, double scale, Offset offset) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      // UI size (crop widget size)
      const double uiSize = 320;
      const double cropUI = 260; // jitna UI me crop box hai

      final imgW = image.width.toDouble();
      final imgH = image.height.toDouble();

      // Ratio (safe for portrait + landscape)
      final ratioX = imgW / uiSize;
      final ratioY = imgH / uiSize;
      final ratio = ratioX < ratioY ? ratioX : ratioY;

      // Real image crop size
      final cropSize = (cropUI * ratio) / scale;

      // Center based crop
      double dx = (imgW / 2) - (cropSize / 2) - (offset.dx * ratio);
      double dy = (imgH / 2) - (cropSize / 2) - (offset.dy * ratio);

      // Prevent overflow
      dx = dx.clamp(0.0, imgW - cropSize);
      dy = dy.clamp(0.0, imgH - cropSize);

      // Canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final paint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high;

      // ✅ NO CLIP — PURE RECTANGLE IMAGE
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
      debugPrint("❌ Crop failed: $e");
      return null;
    }
  }

  Future<void> _fetchSingup() async {
    // 🔐 Password match check
    if (passwordController.text != confirmPasswordController.text) {
      _showSnack("Password and Confirm Password do not match");
      return;
    }

    // ☑️ Terms check
    if (!savePassword) {
      _showSnack("Please accept Terms & Conditions");
      return;
    }

    // 🖼 Profile image check
    if (profileImage == null) {
      _showSnack("Please upload profile picture");
      return;
    }

    // 📏 Working distance check (IMPORTANT)
    if (selectedDistance == null || selectedDistance!.isEmpty) {
      _showSnack("Please select working distance");
      return;
    }

    if (currentLatLng == null) {
      _showSnack("Please select location on map");
      setState(() => isLoggingIn = false);
      return;
    }

    setState(() => isLoggingIn = true);

    debugPrint("📸 PROFILE IMAGE: ${profileImage!.path}");

    try {
      final response = await ApiService()
          .postMultipart(ApiEndpoints.register_step1, {
            "first_name": firstNameController.text.trim(),
            "last_name": lastNameController.text.trim(),
            "email": emailController.text.trim(),
            "phone": phoneController.text.trim(),
            "password": passwordController.text.trim(),
            "location": searchController.text.trim(),
            "working_distance": selectedDistance!,
            "lat": currentLatLng!.latitude.toString(),
            "lng": currentLatLng!.longitude.toString(),
          }, profileImage!);

      debugPrint("📥 API RESPONSE: $response");

      if (response != null && response['error'] == false) {
        final crewMemberId = response['data']?['crew_member_id'];

        if (crewMemberId == null) {
          _showSnack("Crew member id not received");
          return;
        }

        context.goNamed(
          RouteNames.signupStep2,
          extra: {
            "crewMemberId": response["data"]["crew_member_id"],
            "profileImage": profileImage,
            "email": emailController.text.trim(),
            "firstName": firstNameController.text.trim(),
            "lastName": lastNameController.text.trim(),
            "location": searchController.text.trim(),
            "workingDistance": selectedDistance,
            "step1Progress": _calculateCompletion(),
          },
        );
      } else {
        _showSnack(response?['message'] ?? "Something went wrong");
      }
    } catch (e) {
      if (e is DioException) {
        debugPrint("❌ STATUS: ${e.response?.statusCode}");
        debugPrint("❌ ERROR DATA: ${e.response?.data}");

        final errorMessage =
            e.response?.data?['message'] ?? "Something went wrong";

        _showSnack(errorMessage);
      } else {
        _showSnack("Something went wrong");
      }
    } finally {
      setState(() => isLoggingIn = false);
    }
  }

  void _showSnack(String message) {
    TopMessage.show(context, message);
  }

  @override
  Widget build(BuildContext context) {
    String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#212121"}]
    },
    {
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#212121"}]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [{"color": "#757575"}]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#383838"}]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#8a8a8a"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#000000"}]
    }
  ]
  ''';
    bool isLocationFilled = searchController.text.isNotEmpty;
    bool locationHighlight = isLocationFocused || isLocationFilled;

    return Scaffold(
      // backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  /// 🔝 TOP IMAGE + TITLE SECTION
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.28,
                    child: Stack(
                      children: [
                        /// 🖼️ BACKGROUND IMAGE
                        Positioned.fill(
                          child: Image.asset(
                            AppAssets.rectangle,
                            fit: BoxFit.fill,
                          ),
                        ),

                        /// 🔙 BACK BUTTON
                        Positioned(
                          top: 30,
                          left: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              /// 📄 STEP COUNT
                              Text(
                                "1/3",
                                style: AppTextStyles.body14Medium.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// 🏷️ TITLE + SUBTITLE (CENTER)
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Build your Creative Profile",
                                style: AppTextStyles.displayStrong16.copyWith(
                                  color: AppColors.white,
                                ),
                              ),

                              SizedBox(height: 10),

                              Text(
                                "Create your profile to get discovered by\n production teams.",

                                textAlign: TextAlign.center,
                                style: AppTextStyles.body14.copyWith(
                                  color: AppColors.white30,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  3,
                                  (index) => Container(
                                    width: 40, // 🔥 fixed width
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xxs,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          index ==
                                              0 // 👈 current step change here
                                          ? AppColors.primary
                                          : AppColors.textSubtle,
                                      borderRadius: AppRadii.hugeAll,
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
                  SizedBox(height: 25),

                  /// 📦 FORM CONTAINER (NICHE)
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        /// 🧱 MAIN FORM CONTAINER
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.xl,
                            isPreviewVisible ? 110 : 60,
                            AppSpacing.xl,
                            AppSpacing.xl,
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.base,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppRadii.massiveAll,
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.06),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              // _buildField("First Name",  firstNameController),
                              CustomTextField(
                                label: "First Name",
                                controller: firstNameController,
                              ),

                              SizedBox(height: 20),

                              // _buildField("Last Name", lastNameController),
                              CustomTextField(
                                label: "Last Name",
                                controller: lastNameController,
                              ),

                              SizedBox(height: 20),

                              //   _buildField("Email Address", emailController),
                              CustomTextField(
                                label: "Email Address",
                                controller: emailController,
                              ),
                              SizedBox(height: 20),
                              CustomTextField(
                                label: "Phone Number",
                                controller: phoneController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly, // only numbers
                                  LengthLimitingTextInputFormatter(
                                    10,
                                  ), // max 10 digits
                                ],
                              ),

                              SizedBox(height: 20),

                              /* Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.transparent,
                                    borderRadius: AppRadii.lgAll,
                                    border: Border.all(
                                      color: AppColors.white30,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: GooglePlaceAutoCompleteTextField(
                                    textEditingController: searchController,
                                    focusNode: _locationFocus, // ✅ ADD THIS
          
                                    googleAPIKey: GoogleConfig.placesApiKey,
                                    debounceTime: 600,
          
                                    isLatLngRequired: true,
          
          
                                    textStyle: const TextStyle(
                                      color: AppColors.white,
                                      fontFamily: "Outfit",
                                      fontSize: 14,
                                    ),
          
                                    inputDecoration: const InputDecoration(
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      hintText: "Search or select location",
                                      hintStyle: TextStyle(
                                        color: AppColors.white30,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      suffixIcon: Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: Icon(
                                          Icons.location_on_outlined,
                                          color: AppColors.white30,
                                        ),
                                      ),
                                    ),
                                    getPlaceDetailWithLatLng: (prediction) async {
                                      final latLng = LatLng(
                                        double.parse(prediction.lat!),
                                        double.parse(prediction.lng!),
                                      );
          
                                      _locationFocus.unfocus();
          
                                      await _updateLocationFromLatLng(latLng);
          
                                      setState(() {
                                        currentLatLng = latLng;
                                        selectedAddress = prediction.description ?? "";
                                        showMap = true;
                                      });
          
                                      searchController.text = selectedAddress;
                                      searchController.selection = TextSelection.fromPosition(
                                        TextPosition(offset: searchController.text.length),
                                      );
          
                                      mapController?.animateCamera(
                                        CameraUpdate.newLatLngZoom(latLng, 14),
                                      );
                                    },
          
          
                                    itemClick: (prediction) {
                                      searchController.text = prediction.description ?? "";
                                      searchController.selection = TextSelection.fromPosition(
                                        TextPosition(offset: searchController.text.length),
                                      );
                                    },
          
                                    isCrossBtnShown: true,
                                  ),
                                ),
          */
                              Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                      top: AppSpacing.smd,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: AppRadii.lgAll,
                                      border: Border.all(
                                        color: locationHighlight
                                            ? AppColors
                                                  .borderGold // ✅ ACTIVE
                                            : AppColors.white30,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: GooglePlaceAutoCompleteTextField(
                                      textEditingController: searchController,
                                      focusNode: _locationFocus,
                                      googleAPIKey: GoogleConfig.placesApiKey,
                                      debounceTime: 600,
                                      isLatLngRequired: true,

                                      textStyle: AppTextStyles.system14
                                          .copyWith(color: AppColors.white),

                                      inputDecoration: InputDecoration(
                                        border: InputBorder.none,
                                        // hintText: "Search location",
                                        hintStyle: AppTextStyles.systemDefault
                                            .copyWith(
                                              color: AppColors.white30,
                                            ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.base,
                                              vertical: AppSpacing.base,
                                            ),
                                      ),

                                      getPlaceDetailWithLatLng:
                                          (prediction) async {
                                            final latLng = LatLng(
                                              double.parse(prediction.lat!),
                                              double.parse(prediction.lng!),
                                            );

                                            _locationFocus.unfocus();
                                            await _updateLocationFromLatLng(
                                              latLng,
                                            );
                                          },

                                      itemClick: (prediction) {
                                        searchController.text =
                                            prediction.description ?? "";
                                      },
                                    ),
                                  ),

                                  /// 🔥 FLOATING LABEL (IMPORTANT)
                                  Positioned(
                                    left: 14,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.xs,
                                      ),
                                      color: AppColors.background,
                                      child: Text(
                                        "Location*",
                                        style: AppTextStyles.body12.copyWith(
                                          color: locationHighlight
                                              ? AppColors.primary
                                              : AppColors.white60,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              /// 🗺️ MAP WITH FIXED HEIGHT
                              if (showMap)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.smd,
                                  ),
                                  child: SizedBox(
                                    height: 280,
                                    child: ClipRRect(
                                      borderRadius: AppRadii.xxlAll,
                                      child: currentLatLng == null
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : GoogleMap(
                                              initialCameraPosition:
                                                  CameraPosition(
                                                    target: currentLatLng!,
                                                    zoom: 14,
                                                  ),

                                              myLocationEnabled: true,
                                              myLocationButtonEnabled: true,
                                              zoomControlsEnabled: true,
                                              compassEnabled: false,

                                              // 🔥 IMPORTANT FIX (touch enable)
                                              gestureRecognizers:
                                                  <
                                                    Factory<
                                                      OneSequenceGestureRecognizer
                                                    >
                                                  >{
                                                    Factory<
                                                      OneSequenceGestureRecognizer
                                                    >(
                                                      () =>
                                                          EagerGestureRecognizer(),
                                                    ),
                                                  },

                                              onMapCreated: (controller) {
                                                mapController = controller;
                                                controller.setMapStyle(
                                                  _darkMapStyle,
                                                );
                                              },

                                              markers: {
                                                Marker(
                                                  markerId: const MarkerId(
                                                    "selected",
                                                  ),
                                                  position: currentLatLng!,
                                                ),
                                              },

                                              onTap: (latLng) async {
                                                await _updateLocationFromLatLng(
                                                  latLng,
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                ),

                              SizedBox(height: 20),

                              CustomDropdown<String>(
                                label: "Working Distance*",
                                value: selectedDistance,
                                icon: SvgPicture.asset(
                                  AppAssets.dropdown,
                                  color: AppColors.white,
                                ),
                                items: distances
                                    .map(
                                      (e) => DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(
                                          e,
                                          style: AppTextStyles.systemDefault
                                              .copyWith(color: AppColors.white),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedDistance = value;
                                  });
                                },
                              ),
                              SizedBox(height: 20),

                              // _buildPasswordField(
                              //   "Create Password",
                              //   showPassword,
                              //       () => setState(() => showPassword = !showPassword),
                              //   passwordController,
                              //   _passwordFocus,
                              // ),
                              CustomTextField(
                                isVisible: showPassword,

                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showPassword = !showPassword;
                                    });
                                  },
                                  icon: SvgPicture.asset(
                                    showPassword
                                        ? AppAssets.eyeOpen
                                        : AppAssets.eyeClose,
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                                isPassword: true,
                                label: 'Create Password',
                                controller: passwordController,
                              ),

                              SizedBox(height: 20),

                              CustomTextField(
                                isVisible: showConfirmPassword,
                                isPassword: true,
                                label: 'Confirm Password',
                                controller: confirmPasswordController,

                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showConfirmPassword =
                                          !showConfirmPassword;
                                    });
                                  },
                                  icon: SvgPicture.asset(
                                    showConfirmPassword
                                        ? AppAssets.eyeOpen
                                        : AppAssets.eyeClose,
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                              ),

                              SizedBox(height: 20),

                              _profilePictureCard(),

                              SizedBox(height: 24),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(
                                      () => savePassword = !savePassword,
                                    ),
                                    child: Container(
                                      height: 18,
                                      width: 18,
                                      decoration: BoxDecoration(
                                        color: savePassword
                                            ? AppColors.primary
                                            : AppColors.transparent,
                                        borderRadius: AppRadii.r5All,
                                        border: Border.all(
                                          color: AppColors.white30,
                                        ),
                                      ),
                                      child: savePassword
                                          ? const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: AppColors.black,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: AppTextStyles.system13Tight
                                            .copyWith(color: AppColors.black),
                                        children: [
                                          TextSpan(
                                            text: "I agree to the ",
                                            style: AppTextStyles.body13
                                                .copyWith(
                                                  color: AppColors.white30,
                                                ),
                                          ),

                                          TextSpan(
                                            text:
                                                "Terms & Condition & Privacy Policy",
                                            style: AppTextStyles.body13Bold
                                                .copyWith(
                                                  color: AppColors.white,
                                                ),
                                          ),

                                          TextSpan(
                                            text: "\nset out of this site",
                                            style: AppTextStyles.body13
                                                .copyWith(
                                                  color: AppColors.white30,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 40),

                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: isLoggingIn ? null : _fetchSingup,
                                  // onPressed: isLoggingIn ? null : _fetchSingup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isFormValid
                                        ? AppColors
                                              .primary // ✅ Active color
                                        : AppColors.borderGold,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadii.lgAll,
                                    ),
                                  ),
                                  child: Text(
                                    "Next",
                                    style: AppTextStyles.displayLabel13
                                        .copyWith(
                                          color: isFormValid
                                              ? AppColors.textHeading
                                              : AppColors.surfaceMid,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// 🏷️ FLOATING CHIP (BORDER PE STUCK)
                        if (!isPreviewVisible)
                          Positioned(
                            top: -24,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.base,
                                ),
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: AppRadii.lgAll,
                                  border: Border.all(
                                    color: AppColors.white.withValues(alpha: 0.12),
                                    width: 1,
                                  ),
                                  boxShadow: AppShadows.ctaDark,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      AppAssets.User_Circle,
                                      width: 30,
                                      height: 30,
                                    ),
                                    /* Icon(Icons.person_outline,
                                          size: 16,
                                          color: AppColors.white30),*/
                                    SizedBox(width: 10),
                                    Text(
                                      "Tell Us About Yourself & Add Details",
                                      style: AppTextStyles.bodySmallMedium
                                          .copyWith(color: AppColors.disabled),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 30),
                        if (isPreviewVisible)
                          Positioned(
                            top: -40,
                            left: 20,
                            right: 20,
                            child: _userPreviewCard(),
                          ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: AppTextStyles.body15Medium.copyWith(
                          color: AppColors.white60,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          /* Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>  Login(),
                              ),
                            );*/
                          context.goNamed(RouteNames.login);
                          // context.goNamed(RouteNames.onboarding);
                        },
                        child: Text(
                          "Login",
                          style: AppTextStyles.body15Strong.copyWith(
                            color: AppColors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            if (isLoggingIn) AppLoader(),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      cursorColor: AppColors.white,

      style: AppTextStyles.systemDefault.copyWith(
        color: AppColors.white, // typed text color
      ),

      decoration: InputDecoration(
        labelText: "$title*",
        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: AppTextStyles.systemDefault.copyWith(
          color: AppColors.primary, // #1D1D1B 60% opacity
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),

        /// ⭐ 0.5px BORDER + OPACITY COLOR
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: const BorderSide(
            color: AppColors.white30, // #1D1D1B99 (60% opacity)
            width: 0.5, // 🔥 exact 0.5px
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: const BorderSide(
            color: AppColors.textfieldBorderLegacy, // #1D1D1B99 (60% opacity)
            width: 0.5, // focus border thicker
          ),
        ),

        floatingLabelStyle: AppTextStyles.systemDefault.copyWith(
          color: AppColors.white30,
        ),
      ),
    );
  }

  // Widget _workingDistanceDropdown() {
  //   return DropdownButtonFormField<String>(
  //     value: selectedDistance,
  //     dropdownColor: AppColors.surfaceCropSheet,
  //     icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.white),
  //
  //     style: const TextStyle(color: AppColors.white),
  //
  //     decoration: InputDecoration(
  //       labelText: "Working Distance*",
  //       floatingLabelBehavior: FloatingLabelBehavior.always,
  //
  //       labelStyle: TextStyle(
  //         color: selectedDistance != null
  //             ? AppColors.primary   // active
  //             : AppColors.white30,
  //       ),
  //
  //       contentPadding: const EdgeInsets.symmetric(
  //         horizontal: 20,
  //         vertical: 18,
  //       ),
  //
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: AppRadii.lgAll,
  //         borderSide: const BorderSide(
  //           color: AppColors.white30,
  //           width: 0.5,
  //         ),
  //       ),
  //
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: AppRadii.lgAll,
  //         borderSide: const BorderSide(
  //           color: AppColors.primary,
  //           width: 1,
  //         ),
  //       ),
  //     ),
  //
  //     /*  hint: const Text(
  //       "Select distance",
  //       style: TextStyle(color: AppColors.white54),
  //     ),*/
  //
  //     items: distances
  //         .map(
  //           (e) => DropdownMenuItem<String>(
  //         value: e,
  //         child: Text(
  //           e,
  //           style: const TextStyle(color: AppColors.white),
  //         ),
  //       ),
  //     )
  //         .toList(),
  //
  //     onChanged: (value) {
  //       setState(() {
  //         selectedDistance = value;
  //       });
  //     },
  //   );
  // }

  // Widget _buildPasswordField(
  //     String title,
  //     bool isVisible,
  //     VoidCallback onToggle,
  //     TextEditingController controller,
  //     FocusNode focusNode,
  //     ) {
  //   return TextField(
  //     controller: controller,
  //     focusNode: focusNode,
  //     obscureText: !isVisible,
  //     cursorColor: AppColors.primary,
  //
  //     style: const TextStyle(
  //       color: AppColors.white,
  //     ),
  //
  //     decoration: InputDecoration(
  //       labelText: "$title*",
  //       floatingLabelBehavior: FloatingLabelBehavior.always,
  //
  //       /// 🔥 LABEL COLOR CHANGE
  //       labelStyle: TextStyle(
  //         color: focusNode.hasFocus
  //             ? AppColors.primary
  //             : AppColors.white30,
  //       ),
  //
  //       contentPadding: const EdgeInsets.symmetric(
  //         horizontal: 20,
  //         vertical: 18,
  //       ),
  //
  //       /// 👁️ EYE ICON
  //       suffixIcon: IconButton(
  //         onPressed: onToggle,
  //         icon: Icon(
  //           isVisible ? Icons.visibility : Icons.visibility_off,
  //           color: focusNode.hasFocus
  //               ? AppColors.primary
  //               : AppColors.white30,
  //           size: 20,
  //         ),
  //       ),
  //
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: AppRadii.xlAll,
  //         borderSide: const BorderSide(
  //           color: AppColors.white30,
  //           width: 0.5,
  //         ),
  //       ),
  //
  //       /// 🔥 ACTIVE BORDER
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: AppRadii.lgAll,
  //         borderSide: const BorderSide(
  //           color: AppColors.primary,
  //           width: 1,
  //         ),
  //       ),
  //     ),
  //
  //     onTap: () => setState(() {}),
  //     onChanged: (_) => setState(() {}),
  //   );
  // }

  Widget _profilePictureCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        borderRadius: AppRadii.xxlAll,
        border: Border.all(color: AppColors.white60, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          Text(
            "Profile Picture",
            style: AppTextStyles.bodyLargeMedium.copyWith(
              color: AppColors.white,
            ),
          ),

          const SizedBox(height: 4),

          /// SUB TITLE
          Text(
            "Add photo to build connection and trust",
            style: AppTextStyles.body12.copyWith(color: AppColors.white30),
          ),

          const SizedBox(height: 16),

          /// IMAGE + BUTTON ROW
          Row(
            children: [
              /// 👤 PROFILE IMAGE
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.surfaceMid,
                backgroundImage: profileImage != null
                    ? FileImage(profileImage!)
                    : const AssetImage(AppAssets.imageProfilePlaceholder)
                          as ImageProvider,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: AppRadii.roundAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.smd,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadii.roundAll,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          profileImage == null
                              ? Icons
                                    .camera_alt_outlined // image nahi hai
                              : Icons.refresh, // image hai → re-upload
                          size: 18,
                          color: AppColors.black,
                        ),
                        // Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.black),
                        SizedBox(width: 8),
                        Text(
                          profileImage == null
                              ? "Upload Profile Picture"
                              : "ReUpload Profile Picture",
                          style: AppTextStyles.bodySmallMedium.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _userPreviewCard() {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    /*
  
      if (firstName.isEmpty && lastName.isEmpty && email.isEmpty && profileImage == null) {
        return const SizedBox();
      }
  */

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.smd,
            vertical: AppSpacing.smd,
          ),
          margin: const EdgeInsets.all(AppSpacing.smd),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadii.xxlAll,
            boxShadow: AppShadows.cardHeavy,
          ),
          child: Column(
            children: [
              /// 🔹 TOP ROW (Image + Name + Email)
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.border,
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : null,
                    child: profileImage == null
                        ? const Icon(
                            Icons.person,
                            size: 28,
                            color: AppColors.lavenderGrey,
                          )
                        : null,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${firstName.isEmpty ? '' : firstName} ${lastName.isEmpty ? '' : lastName}",
                          style: AppTextStyles.body15Strong.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email.isEmpty ? "Your Email" : email,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body12.copyWith(
                            color: AppColors.greyShade737,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// 🔹 VIEW DETAILS BUTTON
              Row(
                children: [
                  /// 🔹 VIEW DETAILS BUTTON
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        /*   onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: AppColors.transparent,
                              builder: (_) => ViewDetailsScreen(
                                firstName: firstNameController.text.trim(),
                                lastName: lastNameController.text.trim(),
                                email: emailController.text.trim(),
                                profileImage: profileImage,
                                location: searchController.text.trim(),
                                workingDistance: selectedDistance ?? "",
                              ),
                            );
                          },*/
                        onPressed: () {
                          print("========== VIEW DETAILS ==========");

                          print(
                            "First Name: ${firstNameController.text.trim()}",
                          );
                          print("Last Name: ${lastNameController.text.trim()}");
                          print("Email: ${emailController.text.trim()}");
                          print("Profile Image: ${profileImage?.path}");
                          print("Location: ${searchController.text.trim()}");
                          print("Working Distance: ${selectedDistance ?? ""}");

                          context.pushNamed(
                            RouteNames.viewDetails,
                            extra: {
                              "firstName": firstNameController.text.trim(),
                              "lastName": lastNameController.text.trim(),
                              "email": emailController.text.trim(),
                              "profileImage": profileImage,
                              "location": searchController.text.trim(),
                              "workingDistance": selectedDistance ?? "",
                              "primaryRole": "",
                              "experience": "",
                              "hourlyRate": "",
                              "bio": "",
                              "skills": "",
                              "equipments": "",
                              "featuredImages": <File>[],
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.hugeAll,
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "View Details",
                          style: AppTextStyles.bodySmallMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// 🔹 30% COMPLETED CONTAINER
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: AppRadii.hugeAll,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${_calculateCompletion()}% Completed",
                      style: AppTextStyles.bodySmallMedium.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CircleHolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    /// dark overlay
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.black.withValues(alpha: 0.6),
    );

    /// clear circle
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 130.0;

    canvas.drawCircle(center, radius, Paint()..blendMode = BlendMode.clear);

    canvas.restore();

    /// white border
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
