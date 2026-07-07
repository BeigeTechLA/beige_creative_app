import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../../../../service/google_config.dart';
import '../../../../shared/widgets/custom_dropdown.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading.dart';
import 'signup1_profile_card.dart';

const List<String> _distances = [
  "Upto 50 Miles",
  "Upto 75 miles",
  "Upto 100 miles",
  "I’m open to traveling",
];

class SignUp1Form extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController searchController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode locationFocus;
  final bool locationHighlight;
  final bool showMap;
  final LatLng? currentLatLng;
  final String? selectedDistance;
  final bool savePassword;
  final bool showPassword;
  final bool showConfirmPassword;
  final bool isLoggingIn;
  final bool isFormValid;
  final File? profileImage;

  final void Function(GoogleMapController controller) onMapCreated;
  final Future<void> Function(LatLng latLng) onMapTap;
  final Future<void> Function(LatLng latLng) onPlacePicked;
  final void Function(Prediction prediction) onSearchItemClick;
  final ValueChanged<String?> onDistanceChanged;
  final VoidCallback onToggleSavePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onPickImage;
  final VoidCallback onNext;

  const SignUp1Form({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.searchController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.locationFocus,
    required this.locationHighlight,
    required this.showMap,
    required this.currentLatLng,
    required this.selectedDistance,
    required this.savePassword,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.isLoggingIn,
    required this.isFormValid,
    required this.profileImage,
    required this.onMapCreated,
    required this.onMapTap,
    required this.onPlacePicked,
    required this.onSearchItemClick,
    required this.onDistanceChanged,
    required this.onToggleSavePassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onPickImage,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: "First Name",
          controller: firstNameController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: "Last Name",
          controller: lastNameController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: "Email Address",
          controller: emailController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: "Phone Number",
          controller: phoneController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        const SizedBox(height: 20),
        _LocationField(
          searchController: searchController,
          locationFocus: locationFocus,
          locationHighlight: locationHighlight,
          onPlacePicked: onPlacePicked,
          onSearchItemClick: onSearchItemClick,
        ),
        if (showMap)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.smd),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 200,
                maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              child: ClipRRect(
                borderRadius: AppRadii.xxlAll,
                child: currentLatLng == null
                    ? const Center(child: AppCircularLoader())
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: currentLatLng!,
                          zoom: 14,
                        ),
                        style: GoogleConfig.darkMapStyle,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        compassEnabled: false,
                        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        },
                        onMapCreated: onMapCreated,
                        markers: {
                          Marker(
                            markerId: const MarkerId("selected"),
                            position: currentLatLng!,
                          ),
                        },
                        onTap: onMapTap,
                      ),
              ),
            ),
          ),
        const SizedBox(height: 20),
        CustomDropdown<String>(
          label: "Working Distance*",
          value: selectedDistance,
          icon: SvgPicture.asset(
            AppAssets.dropdown,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
          items: _distances
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    style: AppTextStyles.inherit
                        .copyWith(color: AppColors.white),
                  ),
                ),
              )
              .toList(),
          onChanged: onDistanceChanged,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          isVisible: showPassword,
          isPassword: true,
          label: 'Create Password',
          controller: passwordController,
          suffixIcon: IconButton(
            onPressed: onTogglePassword,
            icon: SvgPicture.asset(
              showPassword ? AppAssets.eyeOpen : AppAssets.eyeClose,
              height: 24,
              width: 24,
            ),
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          isVisible: showConfirmPassword,
          isPassword: true,
          label: 'Confirm Password',
          controller: confirmPasswordController,
          suffixIcon: IconButton(
            onPressed: onToggleConfirmPassword,
            icon: SvgPicture.asset(
              showConfirmPassword ? AppAssets.eyeOpen : AppAssets.eyeClose,
              height: 24,
              width: 24,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SignUp1ProfileCard(
          profileImage: profileImage,
          onPickImage: onPickImage,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onToggleSavePassword,
              child: Container(
                height: 18,
                width: 18,
                decoration: BoxDecoration(
                  color: savePassword
                      ? AppColors.primary
                      : AppColors.transparent,
                  borderRadius: AppRadii.signupChipAll,
                  border: Border.all(color: AppColors.white30),
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
                  style: AppTextStyles.inherit13Tight
                      .copyWith(color: AppColors.black),
                  children: [
                    TextSpan(
                      text: "I agree to the ",
                      style: AppTextStyles.body13
                          .copyWith(color: AppColors.white30),
                    ),
                    TextSpan(
                      text: "Terms & Condition & Privacy Policy",
                      style: AppTextStyles.body13Bold
                          .copyWith(color: AppColors.white),
                    ),
                    TextSpan(
                      text: "\nset out of this site",
                      style: AppTextStyles.body13
                          .copyWith(color: AppColors.white30),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: isLoggingIn ? null : onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isFormValid ? AppColors.primary : AppColors.borderGold,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.lgAll,
              ),
            ),
            child: Text(
              "Next",
              style: AppTextStyles.displayLabel13.copyWith(
                color: isFormValid
                    ? AppColors.textHeading
                    : AppColors.surfaceMid,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationField extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode locationFocus;
  final bool locationHighlight;
  final Future<void> Function(LatLng latLng) onPlacePicked;
  final void Function(Prediction prediction) onSearchItemClick;

  const _LocationField({
    required this.searchController,
    required this.locationFocus,
    required this.locationHighlight,
    required this.onPlacePicked,
    required this.onSearchItemClick,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: AppSpacing.smd),
          decoration: BoxDecoration(
            borderRadius: AppRadii.lgAll,
            border: Border.all(
              color: locationHighlight
                  ? AppColors.borderGold
                  : AppColors.white30,
              width: 0.5,
            ),
          ),
          child: GooglePlaceAutoCompleteTextField(
            textEditingController: searchController,
            focusNode: locationFocus,
            googleAPIKey: GoogleConfig.placesApiKey,
            debounceTime: 600,
            isLatLngRequired: true,
            textStyle:
                AppTextStyles.inherit14.copyWith(color: AppColors.white),
            inputDecoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: AppTextStyles.inherit
                  .copyWith(color: AppColors.white30),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.base,
              ),
            ),
            getPlaceDetailWithLatLng: (prediction) async {
              final latLng = LatLng(
                double.parse(prediction.lat!),
                double.parse(prediction.lng!),
              );
              locationFocus.unfocus();
              await onPlacePicked(latLng);
            },
            itemClick: onSearchItemClick,
          ),
        ),
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
    );
  }
}
