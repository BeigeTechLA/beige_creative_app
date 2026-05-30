import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:beige_creative_app/features/profile/presentation/widgets/profile_section_list.dart';
import 'package:beige_creative_app/features/profile/presentation/widgets/profile_stats_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUpAll(() => Env.init(Environment.dev));

  group('Myprofile decompose characterization', () {
    testWidgets('ProfileStatsPanel renders 3 stat cards + skill chips',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileStatsPanel(
              hourlyRateLabel: r'$50',
              experienceLabel: '04 yrs',
              radiusLabel: 'Upto 10 Miles',
              skills: ['Editing', 'Color', 'Audio'],
            ),
          ),
        ),
      );
      expect(find.text(r'$50'), findsOneWidget);
      expect(find.text('04 yrs'), findsOneWidget);
      expect(find.text('Upto 10 Miles'), findsOneWidget);
      expect(find.text('Per Hour'), findsOneWidget);
      expect(find.text('Experience'), findsOneWidget);
      expect(find.text('Radius'), findsOneWidget);
      // First 2 skills labelled, remainder collapsed.
      expect(find.text('Skill 1'), findsOneWidget);
      expect(find.text('Skill 2'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('ProfileStatsPanel skill chips omit "+N" when ≤ 2 skills',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileStatsPanel(
              hourlyRateLabel: r'$0',
              experienceLabel: '00 yrs',
              radiusLabel: '',
              skills: ['Only One'],
            ),
          ),
        ),
      );
      expect(find.text('Skill 1'), findsOneWidget);
      expect(find.text('Skill 2'), findsNothing);
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('ProfileSectionList renders the 3 menu sections',
        (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(
              body: SingleChildScrollView(child: ProfileSectionList()),
            ),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('My Account'), findsOneWidget);
      expect(find.text('Portfolio & Credentials'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Profile Details'), findsOneWidget);
      expect(find.text('Featured Works'), findsOneWidget);
      expect(find.text('App Preferences'), findsOneWidget);
    });

    testWidgets('ProfileHeader renders title + avatar fallback',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => Scaffold(
                  body: ProfileHeader(
                    localImage: null,
                    profileImageUrl: '',
                    onEditTap: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });
}
