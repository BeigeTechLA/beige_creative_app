import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../routes/signup_args.dart';
import '../../../../app/shadows.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/utils/validators.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/loading.dart';
import '../../../../shared/widgets/common_uploader.dart';
import '../../../../shared/widgets/location_permission_dialog.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../../../utility/location_exception.dart';
import '../../../../utility/location_service.dart';
import '../providers/signup_notifier.dart';
import '../providers/signup_state.dart';
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
  bool _isHydratingLoginData = false;

  bool get isFormValid =>
      passwordController.text.isNotEmpty &&
      confirmPasswordController.text.isNotEmpty &&
      ref.read(signupNotifierProvider).acceptedTerms;

  bool get isPreviewVisible {
    final state = ref.read(signupNotifierProvider);
    return firstNameController.text.trim().isNotEmpty ||
        lastNameController.text.trim().isNotEmpty ||
        emailController.text.trim().isNotEmpty ||
        state.profileImage != null ||
        state.remoteProfileImageUrl.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    void onFieldChanged() {
      if (_isHydratingLoginData) return;
      // Fires `signup_started` once per flow. Notifier ignores duplicates
      // via the `signupStartedEmitted` flag, cleared on `reset()`.
      ref.read(signupNotifierProvider.notifier).markSignupStarted();
      setState(() {});
    }

    firstNameController.addListener(onFieldChanged);
    lastNameController.addListener(onFieldChanged);
    emailController.addListener(onFieldChanged);
    passwordController.addListener(onFieldChanged);
    confirmPasswordController.addListener(onFieldChanged);
    _locationFocus.addListener(() {
      ref
          .read(signupNotifierProvider.notifier)
          .setLocationFocused(_locationFocus.hasFocus);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(signupNotifierProvider.notifier).reset();
      _loadProfileDetails();
    });
  }

  Future<void> _loadProfileDetails() async {
    final notifier = ref.read(signupNotifierProvider.notifier);
    await notifier.loadStep1Prefill();
    if (!mounted) return;
    final prefill = ref.read(signupNotifierProvider);
    _isHydratingLoginData = true;
    firstNameController.text = prefill.firstName;
    lastNameController.text = prefill.lastName;
    emailController.text = prefill.email;
    phoneController.text = prefill.phone;
    searchController.text = prefill.location;
    _isHydratingLoginData = false;
    setState(() {});
    if (prefill.currentLatLng == null) await _getCurrentLocation();
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
    final cropped = await context.pushNamed<File?>(
      Routes.cropImage.name,
      extra: file,
    );
    if (cropped != null && mounted) {
      ref.read(signupNotifierProvider.notifier).setProfileImage(cropped);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final latLng = await LocationService.getCurrentLocation();
      if (!mounted) return;
      ref.read(signupNotifierProvider.notifier).setCurrentLatLng(latLng);
    } on LocationException catch (e) {
      if (!mounted) return;
      final retry = await showLocationPermissionDialog(context, e.status);
      if (retry && e.status == LocationStatus.denied && mounted) {
        await _getCurrentLocation();
      }
    }
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
          if (p.name != null && !isPlusCode(p.name!)) p.name!,
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
    final ok = await ref
        .read(signupNotifierProvider.notifier)
        .submitStep1(
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
      Routes.signupStep2.name,
      extra: SignUpStep2Args(
        crewMemberId: state.crewMemberId,
        profileImage: state.profileImage,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
        location: state.location,
        workingDistance: state.workingDistance,
        step1Progress: state.step1Progress,
      ).toExtra(),
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

    return AppScaffold(
      body: Stack(
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
                        child: AbsorbPointer(
                          absorbing: state.isLoadingStep1Prefill,
                          child: SignUp1Form(
                            firstNameController: firstNameController,
                            lastNameController: lastNameController,
                            emailController: emailController,
                            phoneController: phoneController,
                            searchController: searchController,
                            passwordController: passwordController,
                            confirmPasswordController:
                                confirmPasswordController,
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
                            remoteProfileImageUrl: state.remoteProfileImageUrl,
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
                                  color: AppColors.white.withValues(
                                    alpha: 0.12,
                                  ),
                                  width: 1,
                                ),
                                boxShadow: AppShadows.ctaDark,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    AppAssets.userCircle,
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
                            remoteProfileImageUrl: state.remoteProfileImageUrl,
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
                if (state.step1PrefillError != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      AppSpacing.base,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      decoration: BoxDecoration(
                        color: AppColors.errorSurface,
                        borderRadius: AppRadii.lgAll,
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              state.step1PrefillError!,
                              style: AppTextStyles.bodySmallMedium.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          TextButton(
                            onPressed: state.isLoadingStep1Prefill
                                ? null
                                : _loadProfileDetails,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!ref.watch(authStateProvider))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.body15Medium.copyWith(
                          color: AppColors.white60,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await ref
                              .read(signupNotifierProvider.notifier)
                              .cancelSignup();
                          if (context.mounted) {
                            context.goNamed(Routes.login.name);
                          }
                        },
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
          if (state.isSubmittingStep1 || state.isLoadingStep1Prefill)
            const AppLoader(),
        ],
      ),
    );
  }
}
