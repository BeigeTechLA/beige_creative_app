import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../routes/profile_args.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../service/google_config.dart';
import '../../../../utility/location_exception.dart';
import '../../../../utility/location_service.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/custom_multi_selectfield.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/location_permission_dialog.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../../../shared/widgets/loading.dart';
import '../providers/profile_details_providers.dart';

const _distanceList = <String>[
  'Upto 5 Miles',
  'Upto 10 Miles',
  'Upto 20 Miles',
  '20-50 Miles',
];

class EditPersonalDetailsScreen extends ConsumerStatefulWidget {
  const EditPersonalDetailsScreen({super.key});

  @override
  ConsumerState<EditPersonalDetailsScreen> createState() =>
      _EditPersonalDetailsScreenState();
}

class _EditPersonalDetailsScreenState
    extends ConsumerState<EditPersonalDetailsScreen> {
  final FocusNode _locationFocus = FocusNode();
  final FocusNode locationFocusNode = FocusNode();
  GoogleMapController? mapController;
  LatLng? currentLatLng;
  bool showMap = false;
  String selectedAddress = 'Search or select location';
  Set<Marker> markers = {};

  final firstnamecontroller = TextEditingController();
  final lastnamecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final phonecontroller = TextEditingController();
  final locationController = TextEditingController();
  final experienceController = TextEditingController();
  final rateController = TextEditingController();
  final bioController = TextEditingController();
  final ageController = TextEditingController();

  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    _locationFocus.addListener(() {
      if (_locationFocus.hasFocus) setState(() => showMap = true);
    });
    loadCurrentLocation();
  }

  @override
  void dispose() {
    firstnamecontroller.dispose();
    lastnamecontroller.dispose();
    emailcontroller.dispose();
    phonecontroller.dispose();
    locationController.dispose();
    experienceController.dispose();
    rateController.dispose();
    bioController.dispose();
    ageController.dispose();
    _locationFocus.dispose();
    locationFocusNode.dispose();
    super.dispose();
  }

  void _updateMarker(LatLng latLng) {
    setState(() {
      currentLatLng = latLng;
      markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      };
    });
  }

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    final address = await LocationService.getAddressFromLatLng(latLng);
    if (!mounted || address.isEmpty) return;
    setState(() => selectedAddress = address);
  }

  Future<void> loadCurrentLocation() async {
    try {
      final latLng = await LocationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        currentLatLng = latLng;
        showMap = true;
      });
    } on LocationException catch (e) {
      if (!mounted) return;
      final retry = await showLocationPermissionDialog(context, e.status);
      if (retry && e.status == LocationStatus.denied && mounted) {
        await loadCurrentLocation();
      }
    }
  }

  void _hydrateOnce(EditPersonalState state) {
    if (_initialised || state.initial == null) return;
    final data = state.initial!;
    firstnamecontroller.text = data.firstName;
    lastnamecontroller.text = data.lastName;
    emailcontroller.text = data.email;
    phonecontroller.text = data.phoneNumber;
    locationController.text = data.location;
    experienceController.text = data.yearsOfExperience.toString();
    rateController.text = data.hourlyRate.toString();
    bioController.text = data.bio;
    _initialised = true;
  }

  Future<void> _save() async {
    final ok = await ref.read(editPersonalNotifierProvider.notifier).submit(
          firstName: firstnamecontroller.text,
          lastName: lastnamecontroller.text,
          email: emailcontroller.text,
          phone: phonecontroller.text,
          location: locationController.text,
          experience: experienceController.text,
          hourlyRate: rateController.text,
          bio: bioController.text,
          age: ageController.text,
        );
    if (!mounted) return;
    if (ok) {
      TopMessage.show(context, 'Profile Updated Successfully');
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EditPersonalState>(editPersonalNotifierProvider, (prev, next) {
      _hydrateOnce(next);
      final v = next.validationMessage;
      if (v != null && v != prev?.validationMessage) {
        TopMessage.show(context, v);
      }
      final e = next.errorMessage;
      if (e != null && e != prev?.errorMessage) {
        TopMessage.show(context, e);
      }
    });

    final state = ref.watch(editPersonalNotifierProvider);
    _hydrateOnce(state);
    final workingDistance = state.workingDistance;

    return AppScaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(true),
                        child: SvgPicture.asset(
                          AppAssets.back,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Edit Personal Details',
                        style: AppTextStyles.headingOutfitLg,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'First name*',
                    controller: firstnamecontroller,
                  ),
                  const SizedBox(height: 22),
                  CustomTextField(
                    label: 'Last name*',
                    controller: lastnamecontroller,
                  ),
                  const SizedBox(height: 22),
                  CustomTextField(
                    label: 'Email Address*',
                    controller: emailcontroller,
                  ),
                  const SizedBox(height: 22),
                  CustomTextField(
                    label: 'Contact Number*',
                    controller: phonecontroller,
                  ),
                  const SizedBox(height: 22),
                  _LocationField(
                    controller: locationController,
                    focusNode: locationFocusNode,
                    onSelected: (latLng, description) {
                      _updateMarker(latLng);
                      setState(() => selectedAddress = description);
                      locationController.text = description;
                      locationController.selection =
                          TextSelection.fromPosition(
                        TextPosition(offset: locationController.text.length),
                      );
                      locationFocusNode.unfocus();
                      mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(latLng, 14),
                      );
                    },
                  ),
                  AppSpacing.verticalXl,
                  ClipRRect(
                    borderRadius: AppRadii.xxlAll,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 200,
                        maxHeight: MediaQuery.of(context).size.height * 0.35,
                      ),
                      child: currentLatLng == null
                          ? const Center(
                              child: AppCircularLoader(),
                            )
                          : GoogleMap(
                              style: GoogleConfig.darkMapStyle,
                              initialCameraPosition: CameraPosition(
                                target: currentLatLng!,
                                zoom: 14,
                              ),
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              zoomControlsEnabled: true,
                              compassEnabled: true,
                              markers: markers,
                              gestureRecognizers: <Factory<
                                  OneSequenceGestureRecognizer>>{
                                Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer(),
                                ),
                              },
                              onMapCreated: (controller) {
                                mapController = controller;
                                if (currentLatLng != null) {
                                  mapController!.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                      currentLatLng!,
                                      14,
                                    ),
                                  );
                                }
                              },
                              onTap: (latLng) async {
                                _updateMarker(latLng);
                                await getAddressFromLatLng(latLng);
                                locationController.text = selectedAddress;
                                mapController?.animateCamera(
                                  CameraUpdate.newLatLngZoom(latLng, 14),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SizedBox(height: 22),
                  CustomMultiSelectField(
                    label: 'Working Distance',
                    value: workingDistance,
                    hasValue: workingDistance.isNotEmpty,
                    onTap: () async => _openWorkingDistanceBottomSheet(),
                  ),
                  const SizedBox(height: 22),
                  CustomTextField(
                    isPassword: true,
                    label: 'Change Password*',
                    controller: TextEditingController(text: '********'),
                    readOnly: true,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        context.pushNamed(
                          Routes.changePassword.name,
                          extra: ChangePasswordArgs(
                            email: emailcontroller.text.trim(),
                          ).toExtra(),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: SvgPicture.asset(
                          AppAssets.boxEdit,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white30,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (state.isLoadingInitial || state.isSubmitting)
            const AppLoadingOverlay(dimOpacity: 0.4),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldSandPale,
              foregroundColor: const Color(0xFF1D1D1B),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.xlAll,
              ),
            ),
            onPressed: state.isSubmitting ? null : _save,
            child: const Text('Save', style: AppTextStyles.buttonMedium),
          ),
        ),
      ),
    );
  }

  void _openWorkingDistanceBottomSheet() {
    FocusScope.of(context).unfocus();
    final workingDistance = ref.read(editPersonalNotifierProvider).workingDistance;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.topHuge),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.base,
            AppSpacing.base,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white24,
                  borderRadius: AppRadii.xsAll,
                ),
              ),
              const Text(
                'Select Working Distance',
                style: AppTextStyles.bodyLargeMedium,
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: _distanceList.map((distance) {
                    final isSelected = workingDistance == distance;
                    return ListTile(
                      title: Text(
                        distance,
                        style: AppTextStyles.body14Medium.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.white,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        ref
                            .read(editPersonalNotifierProvider.notifier)
                            .setWorkingDistance(distance);
                        sheetCtx.pop();
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LocationField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(LatLng latLng, String description) onSelected;

  const _LocationField({
    required this.controller,
    required this.focusNode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([focusNode, controller]),
      builder: (context, _) {
        final highlight = focusNode.hasFocus || controller.text.isNotEmpty;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconTheme(
              data: const IconThemeData(
                color: AppColors.white30,
                size: 20,
              ),
              child: GooglePlaceAutoCompleteTextField(
                boxDecoration: BoxDecoration(
                  color: AppColors.transparent,
                  borderRadius: AppRadii.lgAll,
                  border: Border.all(
                    color: highlight
                        ? AppColors.borderGold
                        : AppColors.white30,
                    width: 0.5,
                  ),
                ),
                textEditingController: controller,
                focusNode: focusNode,
                googleAPIKey: GoogleConfig.placesApiKey,
                debounceTime: 600,
                isLatLngRequired: true,
                textStyle:
                    AppTextStyles.body15.copyWith(color: AppColors.white),
                inputDecoration: const InputDecoration(
                  filled: true,
                  fillColor: AppColors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: AppSpacing.sm),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.white,
                    ),
                  ),
                ),
                getPlaceDetailWithLatLng: (prediction) async {
                  final latLng = LatLng(
                    double.parse(prediction.lat!),
                    double.parse(prediction.lng!),
                  );
                  onSelected(latLng, prediction.description ?? '');
                },
                itemClick: (prediction) {
                  controller.text = prediction.description ?? '';
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                },
                isCrossBtnShown: true,
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              top: -8,
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxs,
                ),
                child: Text(
                  'Location*',
                  style: AppTextStyles.inherit14.copyWith(
                    color: highlight
                        ? AppColors.primary
                        : AppColors.white60,
                    fontFamily: AppTextStyles.fontFamilyBody,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
