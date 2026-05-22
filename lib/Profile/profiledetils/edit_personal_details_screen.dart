  import 'package:beige_creative_app/service/api_endpoints.dart';
  import 'package:beige_creative_app/service/api_service.dart';
  import 'package:beige_creative_app/utility/imges_icons.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/gestures.dart';
  import 'package:flutter/material.dart';

  import 'package:flutter_svg/svg.dart';
  import 'package:geocoding/geocoding.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:go_router/go_router.dart';
  import 'package:google_maps_flutter/google_maps_flutter.dart';
  import 'package:google_places_flutter/google_places_flutter.dart';

  import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import '../../model_class/edit_profile_model.dart';
  import '../../app/route_names.dart';
  import '../../service/google_config.dart';
  import '../../utility/colorcode.dart';
  import '../../utility/location_service.dart';
  import '../../widgets/custom_dropdown_field.dart';
  import '../../widgets/custom_text_field.dart';

  class

   EditPersonalDetailsScreen extends StatefulWidget {
    const EditPersonalDetailsScreen({super.key});

    @override
    State<EditPersonalDetailsScreen> createState() => _EditPersonalDetailsScreenState();
  }

  class _EditPersonalDetailsScreenState extends State<EditPersonalDetailsScreen> {
    bool _isPlusCode(String value) {
      return RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$').hasMatch(value);
    }

    final FocusNode _locationFocus = FocusNode();
    GoogleMapController? mapController;
    LatLng? currentLatLng;
    bool showMap = false;
    String selectedAddress = "Search or select location";
    bool isMapOpen = false;          // 👈 map show / hide

    List<String> distanceList = [
      "Upto 5 Miles",
      "Upto 10 Miles",
      "Upto 20 Miles",
      "20-50 Miles", // 👈 ADD THIS
    ];

    final FocusNode locationFocusNode = FocusNode();
    Set<Marker> markers = {};
    final TextEditingController firstnamecontroller =  TextEditingController();
    final TextEditingController lastnamecontroller =  TextEditingController();
    final TextEditingController emailcontroller =  TextEditingController();
    final TextEditingController phonecontroller =  TextEditingController();
    TextEditingController locationController = TextEditingController();

    final TextEditingController changepasswordcontroller =  TextEditingController();
    final TextEditingController experienceController =  TextEditingController();
    final TextEditingController rateController =TextEditingController();
    final TextEditingController bioController  =TextEditingController();
    final TextEditingController ageController = TextEditingController(); // Added age controller
    String selectedSkill = "";
    EditProfileModel?  mylist;

    @override
    void initState() {
      super.initState();
      editpersonaldetails();

      _locationFocus.addListener(() {
        if (_locationFocus.hasFocus) {
          setState(() {
            showMap = true;
          });
        }
      });

      loadCurrentLocation(); //
    }


    void _updateMarker(LatLng latLng) {
      setState(() {
        currentLatLng = latLng;
        markers = {
          Marker(
            markerId: const MarkerId("selected_location"),
            position: latLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        };
      });
    }

    Future<void> searchLocation(String query) async {
      try {
        List<Location> locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
          final loc = locations.first;
          final latLng = LatLng(loc.latitude, loc.longitude);
          _updateMarker(latLng);
          mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
          await getAddressFromLatLng(latLng);
        }
      } catch (e) {
        if (!mounted) return;
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
          setState(() {
            selectedAddress =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";
          });
        }
      } catch (e) {
        debugPrint("Reverse geocode error: $e");
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

    Future<void> editpersonaldetails() async {
      try {
        final apiResponse =
        await ApiService().postData(ApiEndpoints.editprofile, {});

        final response = EditProfileResponse.fromJson(apiResponse);

        final data = response.data;

        setState(() {
          mylist = data;

          firstnamecontroller.text = data.firstName;
          lastnamecontroller.text = data.lastName;
          emailcontroller.text = data.email;
          phonecontroller.text = data.phoneNumber;
          locationController.text = data.location;

          experienceController.text =
              data.yearsOfExperience.toString();
          rateController.text = data.hourlyRate.toString();
          bioController.text = data.bio;
         //

          selectedSkill = data.workingDistance;
        });
      } catch (e) {
        print("ERROR: $e");
      }
    }

    Future<void> updateProfile() async {
      try {
        print("🚀 updateProfile START");

        /// ✅ VALIDATION
        if (firstnamecontroller.text.trim().isEmpty ||
            lastnamecontroller.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Enter full name")),
          );
          return;
        }

        if (emailcontroller.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Enter email")),
          );
          return;
        }


        if (locationController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Select location")),
          );
          return;
        }

        /// ✅ LOADING (optional but recommended)
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        /// ✅ BODY
        final body = {
          "first_name": firstnamecontroller.text.trim(),
          "last_name": lastnamecontroller.text.trim(),
          "email": emailcontroller.text.trim(),
          "phone_number": phonecontroller.text.trim(),
          "location": locationController.text.trim(),
          "working_distance": selectedSkill.isEmpty ? "" : selectedSkill,
          "years_of_experience": experienceController.text.trim(),
          "hourly_rate": rateController.text.trim(),
          "bio": bioController.text.trim(),
          "age": ageController.text.trim(), // Added age to body
        };

        print("📤 BODY: $body");

        /// ✅ API CALL
        final response = await ApiService().postData(
          ApiEndpoints.editprofile,
          body,
        );

        print("📥 RESPONSE: $response");

        /// ✅ LOADING CLOSE
        context.pop();

        /// ✅ RESPONSE HANDLE
        if (response != null && response["error"] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Updated Successfully")),
          );

          context.pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response?["message"] ?? "Something went wrong")),
          );
        }
      } catch (e) {
        context.pop(); // 🔥 IMPORTANT (loader close)

        print("❌ UPDATE ERROR: $e");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
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

      super.dispose();
    }
    @override
    Widget build(BuildContext context) {
      const String darkMapStyle = '''
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

      return Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(

                  children: [

                    /// 🔙 BACK + TITLE
                    Row(
                      children: [
                        InkWell(
                          onTap: () => context.pop(true),
                          child: SvgPicture.asset(
                            AppImages.back,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height:12),
                    Row(
                      children: [
                        Text(
                          "Edit Personal Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: ColorCode.white,
                          ),
                        ),
                      ],
                    ),


                    const SizedBox(height: 30),


                    SizedBox(height:12),
                    /// 📅 YEAR OF EXPERIENCE
                    CustomTextField(
                      label: "First name*",
                      controller: firstnamecontroller,
                    ),

                    SizedBox(height:22),

                    /// 💰 HOURLY RATE
                    CustomTextField(
                      label: "Last name*",
                      controller: lastnamecontroller,
                      // keyboardType: TextInputType.number,
                    ),

                    SizedBox(height:22),


                    /// 📝 BIO
                    CustomTextField(
                      label: "Email Address*",
                      controller: emailcontroller,

                    ),
                    SizedBox(height:22),
                    CustomTextField(
                      label: "Contact Number*",
                      controller:phonecontroller,

                    ),
                    SizedBox(height:22),
                    // CustomTextField(
                    //   label: "Location*",
                    //   controller: locationcontroller,
                    //
                    // ),

                    AnimatedBuilder(
                      animation: Listenable.merge([
                        locationFocusNode,
                        locationController,
                      ]),
                      builder: (context, _) {
                        final bool locationHighlight =
                            locationFocusNode.hasFocus ||
                                locationController.text.isNotEmpty;

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconTheme(
                              data: const IconThemeData(
                                color: ColorCode.white30,
                                size: 20,
                              ),
                              child: GooglePlaceAutoCompleteTextField(
                                boxDecoration: BoxDecoration(
                                  color: ColorCode.transparent,
                                  borderRadius: AppRadii.lgAll,
                                  border: Border.all(
                                    color: locationHighlight
                                        ? ColorCode.kGoldBorder50
                                        : ColorCode.white30,
                                    width: 0.5,
                                  ),
                                ),
                                textEditingController: locationController,
                                focusNode: locationFocusNode,
                                googleAPIKey: GoogleConfig.placesApiKey,
                                debounceTime: 600,
                                isLatLngRequired: true,
                                textStyle: const TextStyle(
                                  color: ColorCode.white,
                                  fontFamily: AppTextStyles.fontFamilyBody,
                                  fontSize: 15,
                                ),
                                inputDecoration: const InputDecoration(
                                  filled: true,
                                  fillColor: ColorCode.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.lg,
                                  ),
                                  suffixIcon: Padding(
                                    padding: EdgeInsets.only(
                                      right: AppSpacing.sm,
                                    ),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      color: ColorCode.white,
                                    ),
                                  ),
                                ),
                                getPlaceDetailWithLatLng: (prediction) async {
                                  final latLng = LatLng(
                                    double.parse(prediction.lat!),
                                    double.parse(prediction.lng!),
                                  );
                                  _updateMarker(latLng);
                                  setState(() {
                                    selectedAddress =
                                        prediction.description ?? "";
                                  });
                                  locationController.text = selectedAddress;
                                  locationController.selection =
                                      TextSelection.fromPosition(
                                        TextPosition(
                                          offset: locationController.text.length,
                                        ),
                                      );
                                  locationFocusNode.unfocus();
                                  mapController?.animateCamera(
                                    CameraUpdate.newLatLngZoom(latLng, 14),
                                  );
                                },
                                itemClick: (prediction) {
                                  locationController.text =
                                      prediction.description ?? "";
                                  locationController.selection =
                                      TextSelection.fromPosition(
                                        TextPosition(
                                          offset: locationController.text.length,
                                        ),
                                      );
                                },
                                isCrossBtnShown: true,
                              ),
                            ),
                            Positioned(
                              left: AppSpacing.md,
                              top: -8,
                              child: Container(
                                color: ColorCode.backgroundColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xxs,
                                ),
                                child: Text(
                                  "Location*",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: locationHighlight
                                        ? ColorCode.primary
                                        : ColorCode.white60,
                                     fontFamily: AppTextStyles.fontFamilyBody,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    AppSpacing.verticalXl,
                    ClipRRect(
                      borderRadius: AppRadii.xxlAll,
                      child: SizedBox(
                        height: 250,
                        child: currentLatLng == null
                            ? const Center(child: CircularProgressIndicator())
                            : GoogleMap(
                          style: darkMapStyle,
                          initialCameraPosition: CameraPosition(
                            target: currentLatLng!,
                            zoom: 14,
                          ),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: true,
                          compassEnabled: true,
                          markers: markers,
                          gestureRecognizers:
                          <Factory<OneSequenceGestureRecognizer>>{
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




                    SizedBox(height: 20),

                 /*   /// 🗺️ MAP WITH FIXED HEIGHT
                    if (showMap)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          height: 280,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: currentLatLng == null
                                ? const Center(child: CircularProgressIndicator())
                                :GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: currentLatLng!,
                                zoom: 14,
                              ),

                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              zoomControlsEnabled: true,
                              compassEnabled: false,

                              // 🔥 IMPORTANT FIX (touch enable)
                              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                                Factory<OneSequenceGestureRecognizer>(
                                      () => EagerGestureRecognizer(),
                                ),
                              },

                              onMapCreated: (controller) {
                                mapController = controller;
                                controller.setMapStyle(darkMapStyle);
                              },

                              markers: {
                                Marker(
                                  markerId: const MarkerId("selected"),
                                  position: currentLatLng!,
                                ),
                              },

                                onTap: (latLng) async {
                                  final result = await LocationService.updateLocation(latLng);

                                  setState(() {
                                    currentLatLng = result["latLng"];
                                    locationController.text = result["address"];
                                  });

                              },
                            ),

                          ),
                        ),
                      ),*/

                    SizedBox(height:22),

                    /// 🎨 SKILLS
                    CustomDropdownField(
                      label: "Working Distance",
                      value: distanceList.contains(selectedSkill) ? selectedSkill : null,
                      items: distanceList,
                      onChanged: (val) {
                        setState(() {
                          selectedSkill = val!;
                        });
                      },
                    ),

                    const SizedBox(height: 22),
                    CustomTextField(
                      isPassword: true,
                      label: "Change Password*",

                      controller: TextEditingController(text: "********"),
                      readOnly: true,

                      suffixIcon: GestureDetector(
                        onTap: () {

                          context.pushNamed(
                            RouteNames.changePassword,
                            extra: emailcontroller.text.trim(),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                           AppImages.box_edit,

                            colorFilter: const ColorFilter.mode(
                              ColorCode.kWhiteOpacity70,
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

          ],

        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6C3A3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),//
                ),
              ),
              onPressed: () {
                print("🔥 SAVE CLICKED");
                updateProfile();
              },
              child: const Text(
                "Save",
                style: TextStyle(
                  color: ColorCode.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }