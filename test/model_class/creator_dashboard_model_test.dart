import 'package:beige_creative_app/model_class/creator_dashboard_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreatorDashboardModel', () {
    test('parses upcoming_meetings with participants_preview', () {
      final json = {
        "error": false,
        "message": "Dashboard details fetched successfully",
        "data": {
          "upcoming_meetings": {
            "results": [
              {
                "id": 142,
                "meeting_title": "PRIVATE Shoot - Krunal PhotoVideo Catch-up",
                "meeting_status": "pending",
                "meeting_type": "post_production",
                "meeting_platform": "custom",
                "meeting_date_time": "2026-07-31T07:30:00.000Z",
                "meeting_end_time": "2026-07-31T08:30:00.000Z",
                "meetLink": "https://meet.google.com/rwd-rykv-pqd",
                "order": {
                  "id": 4901,
                  "name": "PRIVATE Shoot - Krunal PhotoVideo"
                },
                "participants_preview": [
                  {
                    "id": 731,
                    "name": "Smeet Thakkar",
                    "email": "pranav+RPclientSmeet@revurge.com",
                    "role": "client"
                  },
                  {
                    "id": 258,
                    "name": "Beige Sales",
                    "email": "sales@beigecorporation.io",
                    "role": "sales_rep"
                  },
                  {
                    "id": 751,
                    "name": "Krunal CP Joshi",
                    "email": "pranav+krunalCP@revurge.com",
                    "role": "cp"
                  },
                  {
                    "id": 751,
                    "name": "Krunal CP Joshi",
                    "email": "pranav+krunalCP@revurge.com",
                    "role": "cp"
                  }
                ],
                "participants_count": 5
              }
            ],
            "totalResults": 1
          }
        }
      };

      final model = CreatorDashboardModel.fromJson(json);
      final meetings = model.data.upcomingMeetings;

      expect(meetings, isNotNull);
      expect(meetings!.length, 1);
      final meeting = meetings.first;
      expect(meeting.title, "PRIVATE Shoot - Krunal PhotoVideo Catch-up");
      expect(meeting.participants.length, 3);
      expect(meeting.participants[0].name, "Smeet Thakkar");
      expect(meeting.participants[0].role, "client");
      expect(meeting.participants[1].name, "Beige Sales");
      expect(meeting.participants[1].role, "sales_rep");
      expect(meeting.participants[2].name, "Krunal CP Joshi");
      expect(meeting.participants[2].role, "cp");
    });
  });
}
