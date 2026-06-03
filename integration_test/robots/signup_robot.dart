import 'dart:io';

import 'package:beige_creative_app/features/auth/presentation/providers/signup_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Page-object robot for the 3-step signup flow.
///
/// The screens are real. Plugin-backed picker outcomes are seeded through the
/// real SignupNotifier so the test stays hermetic under `flutter test`.
class SignupRobot {
  SignupRobot(this.tester, this.container);

  final WidgetTester tester;
  final ProviderContainer container;

  SignupNotifier get _notifier =>
      container.read(signupNotifierProvider.notifier);

  Future<void> settle() async {
    await tester.runAsync(() async {
      for (var i = 0; i < 6; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      tester.takeException();
    }
  }

  // -- Step 1 ---------------------------------------------------------------

  Future<void> expectOnStep1() async {
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Create Password'), findsOneWidget);
  }

  Future<void> enterStep1Text({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _enterTextFormField('First Name', firstName);
    await _enterTextFormField('Last Name', lastName);
    await _enterTextFormField('Email Address', email);
    await _enterTextFormField('Phone Number', phone);
    await _enterTextFormField('Create Password', password);
    await _enterTextFormField('Confirm Password', password);
  }

  Future<void> seedStep1PickerOutcomes({
    required File profileImage,
    required LatLng latLng,
    required String workingDistance,
  }) async {
    _notifier
      ..setProfileImage(profileImage)
      ..setSelectedDistance(workingDistance)
      ..setAcceptedTerms(true)
      ..setCurrentLatLng(latLng);
  }

  Future<void> tapStep1Next() async {
    await _scrollToText('Next');
    await tester.tap(find.text('Next').last);
    await settle();
  }

  // -- Step 2 ---------------------------------------------------------------

  Future<void> expectOnStep2() async {
    expect(find.text('Primary Role*'), findsOneWidget);
    expect(find.text('Year of Experience*'), findsOneWidget);
  }

  Future<void> seedStep2Selections({
    required String role,
    required String skill,
  }) async {
    _notifier
      ..toggleRole(role, selected: true)
      ..toggleSkill(skill, selected: true);
  }

  Future<void> enterStep2Text({
    required String yearsOfExperience,
    required String hourlyRate,
    required String bio,
  }) async {
    await _enterTextFormField('Year of Experience*', yearsOfExperience);
    await _enterTextFormField('Hourly Rate*', hourlyRate);
    await _enterTextFormField('Bio / About', bio);
  }

  Future<void> tapStep2Next() async {
    await _scrollToText('Next');
    await tester.tap(find.text('Next').last);
    await settle();
  }

  // -- Step 3 ---------------------------------------------------------------

  Future<void> expectOnStep3() async {
    expect(find.text('Add Social Links'), findsOneWidget);
    expect(find.text('Create Profile'), findsOneWidget);
  }

  Future<void> seedStep3PickerOutcomes({
    required List<Map<String, dynamic>> socialLinks,
    required List<Map<String, dynamic>> portfolioLinks,
    required List<List<File>> featuredProjects,
    required List<String> featuredProjectTitles,
    required List<File> certificates,
    required File resume,
    required File portfolio,
  }) async {
    _notifier
      ..setSocialLinks(socialLinks)
      ..setPortfolioLinks(portfolioLinks)
      ..setFeaturedProjects(featuredProjects, featuredProjectTitles)
      ..setResumeFile(resume)
      ..setPortfolioFile(portfolio);
    for (final certificate in certificates) {
      _notifier.addCertificate(certificate);
    }
  }

  Future<void> tapCreateProfile() async {
    await _scrollToText('Create Profile');
    await tester.tap(find.text('Create Profile'));
    await settle();
  }

  Future<void> expectOnLoginStub() async {
    expect(find.text('login-stub'), findsOneWidget);
  }

  // -- Low-level helpers ----------------------------------------------------

  Future<void> _enterTextFormField(String label, String value) async {
    final field = find.ancestor(
      of: find.text(label),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(field.first, value);
    await tester.pump();
    tester.takeException();
  }

  Future<void> _scrollToText(String text) async {
    final target = find.text(text).last;
    if (tester.any(target) && tester.getRect(target).overlaps(_screenRect)) {
      return;
    }
    await tester.scrollUntilVisible(
      target,
      -320,
      scrollable: find.byType(Scrollable).first,
    );
    tester.takeException();
  }

  Rect get _screenRect => Rect.fromLTWH(
    0,
    0,
    tester.view.physicalSize.width / tester.view.devicePixelRatio,
    tester.view.physicalSize.height / tester.view.devicePixelRatio,
  );
}
