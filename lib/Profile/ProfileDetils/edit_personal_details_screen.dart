import 'package:beige_creative_app/service/api_endpoints.dart';
import 'package:beige_creative_app/service/api_service.dart';
import 'package:beige_creative_app/utility/imges_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

import '../../Model_Class/EditProfileModel.dart';
import '../../service/google_config.dart';
import '../../utility/ColorCode.dart';
import '../../widgets/Custom_dropdown_field.dart';
import '../../widgets/custom_text_field.dart';
import '../ChangePassword/change_password_screen.dart';

class EditPersonalDetailsScreen extends StatefulWidget {
  const EditPersonalDetailsScreen({super.key});

  @override
  State<EditPersonalDetailsScreen> createState() => _EditPersonalDetailsScreenState();
}

class _EditPersonalDetailsScreenState extends State<EditPersonalDetailsScreen> {
  bool _isPlusCode(String value) {
    return RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$').hasMatch(value);
  }

  Future<void> _updateLocationFromLatLng(LatLng latLng) async {
    setState(() {
      currentLatLng = latLng;
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 14),
    );

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
  ];


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
  }


  EditProfileModel?  mylist;



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
        searchController.text = data.location;

        experienceController.text =
            data.yearsOfExperience.toString();
        rateController.text = data.hourlyRate.toString();
        bioController.text = data.bio;

        selectedSkill = data.workingDistance;
      });
    } catch (e) {
      print("ERROR: $e");
    }
  }
  final TextEditingController firstnamecontroller =  TextEditingController();
  final TextEditingController lastnamecontroller =  TextEditingController();
  final TextEditingController emailcontroller =  TextEditingController();
  final TextEditingController phonecontroller =  TextEditingController();
  TextEditingController searchController = TextEditingController();
  final TextEditingController changepasswordcontroller =  TextEditingController(text: '123456');




  final TextEditingController experienceController =  TextEditingController();

  final TextEditingController rateController =TextEditingController();

  final TextEditingController bioController  =TextEditingController();
  String selectedSkill = "";
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(

            children: [

              /// 🔙 BACK + TITLE
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
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
                      color: Colors.white,
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 30),


              SizedBox(height:12),
              /// 📅 YEAR OF EXPERIENCE
              CustomTextField(
                label: "First Name*",
                controller: firstnamecontroller,
              ),

              SizedBox(height:22),

              /// 💰 HOURLY RATE
              CustomTextField(
                label: "Last Name*",
                controller: lastnamecontroller,
                keyboardType: TextInputType.number,
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

              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ColorCode.kWhiteOpacity70,
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
                    color: ColorCode.white,
                    fontFamily: "Outfit",
                    fontSize: 14,
                  ),

                  inputDecoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Search or select location",
                    hintStyle: TextStyle(
                      color: ColorCode.kWhiteOpacity70,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: ColorCode.kWhiteOpacity70,
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




              SizedBox(height: 20),

              /// 🗺️ MAP WITH FIXED HEIGHT
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
                          controller.setMapStyle(_darkMapStyle);
                        },

                        markers: {
                          Marker(
                            markerId: const MarkerId("selected"),
                            position: currentLatLng!,
                          ),
                        },

                        onTap: (latLng) async {
                          await _updateLocationFromLatLng(latLng);
                        },
                      ),

                    ),
                  ),
                ),

              SizedBox(height:22),

              /// 🎨 SKILLS
              CustomDropdownField(
                label: "Working Distance",
                value: selectedSkill.isEmpty ? null : selectedSkill,
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
                controller: changepasswordcontroller,
                  suffixIcon: GestureDetector(
                        onTap: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>ChangePasswordScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            "assets/svg/newnew.svg",

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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD6C3A3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {},
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}