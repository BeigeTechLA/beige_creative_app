import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/colors.dart';

class ViewDetailsScreen extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String location;
  final File? profileImage;
  final String workingDistance;

  final String primaryRole;
  final String experience;
  final String hourlyRate;
  final String bio;
  final String skills;
  final String equipments;
  final List<File> featuredImages;

  const ViewDetailsScreen({
    super.key,
    this.firstName = "",
    this.lastName = "",
    this.email = "",
    this.location = "",
    this.profileImage,
    this.workingDistance = "",
    this.primaryRole = "",
    this.experience = "",
    this.hourlyRate = "",
    this.bio = "",
    this.skills = "",
    this.equipments = "",
    this.featuredImages = const [],
  });
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        decoration: TextDecoration.none,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.90,
        decoration: const BoxDecoration(
          
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
      
            /// 🔹 DRAG HANDLE
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
      
            const SizedBox(height: 20),
      
            /// 🔹 HEADER
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Profile Details",
                    style: TextStyle(
                      fontFamily: "Unbounded",
                      fontSize: 14,
                      color: AppColors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.close, color: AppColors.white),
                  ),
                ],
              ),
            ),
      
            const SizedBox(height: 15),
            Divider(color: AppColors.dividerDark),
            const SizedBox(height: 20),
      
            /// 🔥 SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
      
                      /// 🔥 PROFILE CARD
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color:AppColors.surfaceMid,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.white.withOpacity(0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
      
                            /// 🔹 IMAGE + NAME
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppColors.border,
                                  backgroundImage:
                                  profileImage != null
                                      ? FileImage(profileImage!)
                                      : null,
                                  child: profileImage == null
                                      ? const Icon(Icons.person,
                                      size: 30,
                                      color: AppColors.lavenderGrey)
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    "$firstName $lastName",
                                    style: const TextStyle(
                                      fontFamily: "Outfit",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
      
                            const SizedBox(height: 16),
      
                            _infoText(email),
                            _infoText(location),
                            _infoText(workingDistance),
      
                            const SizedBox(height: 20),
      
                            /// 🔹 PROFESSIONAL DETAILS
                            _sectionTitle("Professional Details"),
      
                            _infoRow("Primary Role", primaryRole),
                            _infoRow("Experience", experience.isEmpty ? "" : "$experience Years"),
                            _infoRow("Hourly Rate", hourlyRate.isEmpty ? "" : "₹ $hourlyRate"),
      
                            const SizedBox(height: 20),
      
                            /// 🔹 BIO
                            if (bio.isNotEmpty) ...[
                              _sectionTitle("Bio"),
                              const SizedBox(height: 6),
                              Text(
                                bio,
                                style: const TextStyle(
                                  fontFamily: "Outfit",
                                  fontSize: 13,
                                  color: AppColors.white24,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
      
                            /// 🔹 SKILLS
                            if (skills.isNotEmpty) ...[
                              _sectionTitle("Skills"),
                              const SizedBox(height: 6),
                              Text(
                                skills,
                                style: const TextStyle(
                                  fontFamily: "Outfit",
                                  fontSize: 13,
                                  color: AppColors.white30,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
      
                            /// 🔹 EQUIPMENTS
                            if (equipments.isNotEmpty) ...[
                              _sectionTitle("Equipments"),
                              const SizedBox(height: 6),
                              Text(
                                equipments,
                                style: const TextStyle(
                                  fontFamily: "Outfit",
                                  fontSize: 13,
                                  color: AppColors.white30,
                                ),
                              ),
                            ],
                            if (featuredImages.isNotEmpty) ...[
                              _sectionTitle("Featured Work"),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: featuredImages.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 140,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.file(
                                          featuredImages[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: "Outfit",
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    if (value.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontFamily: "Outfit",
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: "Outfit",
                fontSize: 13,
                color: AppColors.white30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoText(String value) {
    if (value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        value,
        style: const TextStyle(
          fontFamily: "Outfit",
          fontSize: 13,
          color: AppColors.white30,
        ),
      ),
    );
  }
}