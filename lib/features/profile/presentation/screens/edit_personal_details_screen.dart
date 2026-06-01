import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../service/google_config.dart';
import '../../../../utility/location_service.dart';
import '../../../../shared/widgets/custom_dropdown_field.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/top_message.dart';
import '../providers/profile_details_providers.dart';

const _distanceList = <String>[
  'Upto 5 Miles',
  'Upto 10 Miles',
  'Upto 20 Miles',
  '20-50 Miles',
];

const String _darkMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
  {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}]},
  {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#383838"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#8a8a8a"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]}
]
''';

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
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          selectedAddress =
              '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}';
        });
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }
  }

  Future<void> loadCurrentLocation() async {
    final latLng = await LocationService.getCurrentLocation(context);
    if (latLng != null) {
      setState(() {
        currentLatLng = latLng;
        showMap = true;
      });
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

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
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
                    child: SizedBox(
                      height: 250,
                      child: currentLatLng == null
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : GoogleMap(
                              style: _darkMapStyle,
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
                  CustomDropdownField(
                    label: 'Working Distance',
                    value: _distanceList.contains(workingDistance)
                        ? workingDistance
                        : null,
                    items: _distanceList,
                    onChanged: (val) {
                      if (val == null) return;
                      ref
                          .read(editPersonalNotifierProvider.notifier)
                          .setWorkingDistance(val);
                    },
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
                          extra: emailcontroller.text.trim(),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: SvgPicture.asset(
                          AppAssets.box_edit,
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
          ),
          if (state.isLoadingInitial || state.isSubmitting)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldSandPale,
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
