import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/shadows.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../../../../shared/widgets/app_loader.dart' show AppLoader;
import '../../../../shared/widgets/common_uploader.dart';
import '../../../../shared/widgets/top_message.dart';
import '../providers/signup_notifier.dart';
import '../providers/signup_state.dart';
import '../widgets/signup1_crop_sheet.dart';
import '../widgets/signup1_form.dart';
import '../widgets/signup1_header.dart';
import '../widgets/signup1_preview_card.dart';

class SignUp1Screen extends ConsumerStatefulWidget {
  const SignUp1Screen({super.key});

  @override
  ConsumerState<SignUp1Screen> createState() => SignUp1ScreenState();
}

class SignUp1ScreenState extends ConsumerState<SignUp1Screen> {
  final FocusNode _locationFocus = FocusNode();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  GoogleMapController? mapController;
  bool showPassword = false;
  bool showConfirmPassword = false;

  bool _isPlusCode(String value) =>
      RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$').hasMatch(value);

  bool get isFormValid =>
      passwordController.text.isNotEmpty &&
      confirmPasswordController.text.isNotEmpty &&
      ref.read(signupNotifierProvider).acceptedTerms;

  bool get isPreviewVisible {
    final state = ref.read(signupNotifierProvider);
    return firstNameController.text.trim().isNotEmpty ||
        lastNameController.text.trim().isNotEmpty ||
        emailController.text.trim().isNotEmpty ||
        state.profileImage != null;
  }

  @override
  void initState() {
    super.initState();
    firstNameController.addListener(() => setState(() {}));
    lastNameController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    confirmPasswordController.addListener(() => setState(() {}));
    _locationFocus.addListener(() {
      ref
          .read(signupNotifierProvider.notifier)
          .setLocationFocused(_locationFocus.hasFocus);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(signupNotifierProvider.notifier).reset();
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _locationFocus.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    searchController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await CommonUploader.pickFromGallery();
    if (file == null || !mounted) return;
    final cropped =
        await showSignUp1CropSheet(context: context, imageFile: file);
    if (cropped != null && mounted) {
      ref.read(signupNotifierProvider.notifier).setProfileImage(cropped);
    }
  }

  Future<void> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission permanently denied. Enable from settings.',
          ),
        ),
      );
      await Geolocator.openAppSettings();
      return;
    }
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (!mounted) return;
    ref
        .read(signupNotifierProvider.notifier)
        .setCurrentLatLng(LatLng(position.latitude, position.longitude));
  }

  Future<void> _updateLocationFromLatLng(LatLng latLng) async {
    ref.read(signupNotifierProvider.notifier).setCurrentLatLng(latLng);
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.name != null && !_isPlusCode(p.name!)) p.name!,
          if (p.subLocality != null) p.subLocality!,
          if (p.locality != null) p.locality!,
          if (p.administrativeArea != null) p.administrativeArea!,
        ];
        if (!mounted) return;
        final address = parts.join(', ');
        ref.read(signupNotifierProvider.notifier).updateAddress(address);
        searchController.text = address;
        searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: searchController.text.length),
        );
      }
    } catch (_) {
      // Reverse-geocode is best-effort.
    }
  }

  Future<void> _submit() async {
    final ok = await ref.read(signupNotifierProvider.notifier).submitStep1(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          phone: phoneController.text,
          password: passwordController.text,
          confirmPassword: confirmPasswordController.text,
          location: searchController.text,
        );
    if (!ok || !mounted) return;
    final state = ref.read(signupNotifierProvider);
    context.goNamed(
      RouteNames.signupStep2,
      extra: {
        'crewMemberId': state.crewMemberId,
        'profileImage': state.profileImage,
        'email': state.email,
        'firstName': state.firstName,
        'lastName': state.lastName,
        'location': state.location,
        'workingDistance': state.workingDistance,
        'step1Progress': state.step1Progress,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupNotifierProvider);

    ref.listen<SignupState>(signupNotifierProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        TopMessage.show(context, next.errorMessage!);
      }
    });

    final isLocationFilled = searchController.text.isNotEmpty;
    final locationHighlight = state.isLocationFocused || isLocationFilled;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SignUp1Header(),
                  const SizedBox(height: 25),
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
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
                          child: SignUp1Form(
                            firstNameController: firstNameController,
                            lastNameController: lastNameController,
                            emailController: emailController,
                            phoneController: phoneController,
                            searchController: searchController,
                            passwordController: passwordController,
                            confirmPasswordController: confirmPasswordController,
                            locationFocus: _locationFocus,
                            locationHighlight: locationHighlight,
                            showMap: state.showMap,
                            currentLatLng: state.currentLatLng,
                            selectedDistance: state.selectedDistance,
                            savePassword: state.acceptedTerms,
                            showPassword: showPassword,
                            showConfirmPassword: showConfirmPassword,
                            isLoggingIn: state.isSubmittingStep1,
                            isFormValid: isFormValid,
                            profileImage: state.profileImage,
                            onMapCreated: (controller) =>
                                mapController = controller,
                            onMapTap: _updateLocationFromLatLng,
                            onPlacePicked: _updateLocationFromLatLng,
                            onSearchItemClick: (prediction) {
                              searchController.text =
                                  prediction.description ?? '';
                            },
                            onDistanceChanged: (value) => ref
                                .read(signupNotifierProvider.notifier)
                                .setSelectedDistance(value),
                            onToggleSavePassword: () => ref
                                .read(signupNotifierProvider.notifier)
                                .setAcceptedTerms(!state.acceptedTerms),
                            onTogglePassword: () =>
                                setState(() => showPassword = !showPassword),
                            onToggleConfirmPassword: () => setState(
                              () => showConfirmPassword = !showConfirmPassword,
                            ),
                            onPickImage: _pickImage,
                            onNext: _submit,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                                    color:
                                        AppColors.white.withValues(alpha: 0.12),
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
                                    const SizedBox(width: 10),
                                    Text(
                                      'Tell Us About Yourself & Add Details',
                                      style: AppTextStyles.bodySmallMedium
                                          .copyWith(color: AppColors.disabled),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 30),
                        if (isPreviewVisible)
                          Positioned(
                            top: -40,
                            left: 20,
                            right: 20,
                            child: SignUp1PreviewCard(
                              firstName: firstNameController.text.trim(),
                              lastName: lastNameController.text.trim(),
                              email: emailController.text.trim(),
                              profileImage: state.profileImage,
                              location: searchController.text.trim(),
                              workingDistance: state.selectedDistance ?? '',
                              completionPercent: ref
                                  .read(signupNotifierProvider.notifier)
                                  .calculateStep1Progress(
                                    firstName: firstNameController.text,
                                    lastName: lastNameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                    confirmPassword:
                                        confirmPasswordController.text,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.body15Medium
                            .copyWith(color: AppColors.white60),
                      ),
                      InkWell(
                        onTap: () => context.goNamed(RouteNames.login),
                        child: Text(
                          'Login',
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
            if (state.isSubmittingStep1) const AppLoader(),
          ],
        ),
      ),
    );
  }
}
