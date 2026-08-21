import 'package:beige_creative_app/features/shoots/presentation/providers/shoots_providers.dart';
import 'package:beige_creative_app/model_class/shoots_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Shoots API Parsing & Tab Routing', () {
    final apiResponseJson = {
      "error": false,
      "message": "Dashboard details fetched successfully",
      "data": {
        "request": [],
        "shoots": [
          {
            "project_id": 4727,
            "project_name": "CORPORATE Shoot - Krunal",
            "event_date": "2026-06-22",
            "start_time": "09:00:00",
            "end_time": "13:00:00",
            "event_location": "New York, New York, United States",
            "budget": null,
            "is_completed": false,
            "content_type": "videographer,photographer",
            "shoot_type": "Corporate Event",
            "shoot_type_image_url": "shoot-types/corporate-event.jpg",
            "cp_profiles": [
              {
                "crew_member_id": 539,
                "name": "Krunal CP Joshi",
                "profile_image_url": "profile_photo_30_1785929290978.png",
                "acceptance_status": "accepted"
              }
            ],
            "status": "Completed"
          },
          {
            "project_id": 4899,
            "project_name": "CORPORATE Shoot - Krunal",
            "event_date": "2026-07-10",
            "start_time": "09:00:00",
            "end_time": "17:00:00",
            "event_location": "New York, New York, United States",
            "budget": null,
            "is_completed": false,
            "content_type": "photographer",
            "shoot_type": "Corporate Event",
            "shoot_type_image_url": "shoot-types/corporate-event.jpg",
            "cp_profiles": [
              {
                "crew_member_id": 539,
                "name": "Krunal CP Joshi",
                "profile_image_url": "profile_photo_30_1785929290978.png",
                "acceptance_status": "accepted"
              }
            ],
            "status": "Completed"
          }
        ]
      }
    };

    test('ShootsData.fromJson parses requests and shoots correctly', () {
      final model = ShootsModel.fromJson(apiResponseJson);
      expect(model.error, false);
      expect(model.data.requests, isEmpty);
      expect(model.data.shoots.length, 2);

      final firstShoot = model.data.shoots.first;
      expect(firstShoot.id, 4727);
      expect(firstShoot.projectId, 4727);
      expect(firstShoot.crewMemberId, 539);
      expect(firstShoot.projectName, "CORPORATE Shoot - Krunal");
      expect(firstShoot.status, "Completed");
      expect(firstShoot.cpProfiles.length, 1);
      expect(firstShoot.cpProfiles.first.id, 539);
    });

    test('ShootsListNotifier filter routes tab 0 to requests and tab 1 to shoots', () {
      final shootsData = ShootsModel.fromJson(apiResponseJson).data;
      final notifier = ShootsListNotifier();

      // Tab 0 (Request) should use data.requests (which is empty)
      final requestTabShoots = notifier.filterForTesting(
        shootsData,
        query: '',
        tabIndex: 0,
        statusFilter: 'All Status',
      );
      expect(requestTabShoots, isEmpty);

      // Tab 1 (Shoots) should use data.shoots (which contains 2 items)
      final shootsTabShoots = notifier.filterForTesting(
        shootsData,
        query: '',
        tabIndex: 1,
        statusFilter: 'All Status',
      );
      expect(shootsTabShoots.length, 2);
      expect(shootsTabShoots.first.projectId, 4727);
    });
  });
}
