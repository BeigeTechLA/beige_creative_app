import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_category.dart';
import '../../domain/models/meeting_participant.dart';
import '../../domain/models/meeting_platform.dart';
import '../../domain/models/meeting_status.dart';

/// In-memory seed data for the meetings UI phases. All timestamps are
/// relative to "now" at call time so the list always has fresh upcoming
/// rows while the app is being used.
List<Meeting> buildDummyMeetings() {
  final now = DateTime.now();
  DateTime at(int dayOffset, int hour, [int minute = 0]) {
    final base = DateTime(now.year, now.month, now.day, hour, minute);
    return base.add(Duration(days: dayOffset));
  }

  const sarah = MeetingParticipant(
    id: 'p1',
    name: 'Sarah Chen',
    avatarUrl: null,
  );
  const marcus = MeetingParticipant(
    id: 'p2',
    name: 'Marcus Williams',
    avatarUrl: null,
  );
  const ava = MeetingParticipant(id: 'p3', name: 'Ava Patel', avatarUrl: null);
  const liam = MeetingParticipant(id: 'p4', name: 'Liam Rivera', avatarUrl: null);

  return [
    Meeting(
      id: 'm1',
      title: 'Pre-Production Kickoff',
      description:
          'Align on creative direction, crew assignment, and location lock for the winter campaign shoot.',
      project: 'Winter Fashion Campaign',
      platform: MeetingPlatform.meet,
      startAt: at(1, 10, 0),
      endAt: at(1, 11, 0),
      link: 'https://meet.google.com/abc-defg-hij',
      reminderMinutes: 15,
      status: MeetingStatus.upcoming,
      category: MeetingCategory.commercial,
      agenda: [
        'Concept review',
        'Crew assignment',
        'Location lock',
        'Equipment list',
      ],
      participants: [sarah, marcus],
    ),
    Meeting(
      id: 'm2',
      title: 'Editorial Cover Story Sync',
      description: 'Final layout decisions and approval on cover shortlist.',
      project: 'March Editorial Issue',
      platform: MeetingPlatform.zoom,
      startAt: at(2, 14, 30),
      endAt: at(2, 15, 30),
      link: 'https://zoom.us/j/1234567890',
      reminderMinutes: 30,
      status: MeetingStatus.upcoming,
      category: MeetingCategory.editorial,
      agenda: ['Cover shortlist', 'Photo approvals', 'Print deadline'],
      participants: [sarah, ava, liam],
    ),
    Meeting(
      id: 'm3',
      title: 'Brand Workshop Recap',
      description: 'Recap and next steps from corporate brand workshop.',
      project: 'Acme Corp Rebrand',
      platform: MeetingPlatform.teams,
      startAt: at(3, 9, 0),
      endAt: at(3, 10, 0),
      link: 'https://teams.microsoft.com/l/meetup-join/abc',
      reminderMinutes: 10,
      status: MeetingStatus.upcoming,
      category: MeetingCategory.corporate,
      agenda: ['Workshop recap', 'Stakeholder feedback', 'Phase 2 scope'],
      participants: [marcus, liam],
    ),
    Meeting(
      id: 'm4',
      title: 'Podcast Guest Briefing',
      description: 'Brief upcoming guests on run-of-show.',
      project: 'The Long Take Podcast',
      platform: MeetingPlatform.meet,
      startAt: at(4, 16, 0),
      endAt: at(4, 16, 45),
      link: 'https://meet.google.com/xyz-abcd-efg',
      reminderMinutes: 15,
      status: MeetingStatus.upcoming,
      category: MeetingCategory.podcast,
      agenda: ['Run of show', 'Tech check', 'Pre-roll script'],
      participants: [ava],
    ),
    Meeting(
      id: 'm5',
      title: 'Vendor Walkthrough',
      description: 'On-site vendor walkthrough debrief.',
      project: 'Riviera Wedding',
      platform: MeetingPlatform.zoom,
      startAt: at(-3, 11, 0),
      endAt: at(-3, 12, 0),
      link: 'https://zoom.us/j/9876543210',
      reminderMinutes: 30,
      status: MeetingStatus.completed,
      category: MeetingCategory.privateEvents,
      agenda: ['Floor plan', 'Vendor list', 'Insurance'],
      participants: [sarah, liam],
    ),
    Meeting(
      id: 'm6',
      title: 'Social Cutdowns Review',
      description: 'Review cut-downs for IG / TikTok delivery.',
      project: 'SS26 Activation',
      platform: MeetingPlatform.teams,
      startAt: at(-5, 13, 0),
      endAt: at(-5, 13, 30),
      link: 'https://teams.microsoft.com/l/meetup-join/social',
      reminderMinutes: 10,
      status: MeetingStatus.completed,
      category: MeetingCategory.socialContent,
      agenda: ['Cut review', 'Caption pass', 'Delivery schedule'],
      participants: [marcus, ava],
    ),
    Meeting(
      id: 'm7',
      title: 'Music Video Pre-Light',
      description: 'Pre-light walkthrough and shot list lock.',
      project: 'Indie Artist MV',
      platform: MeetingPlatform.meet,
      startAt: at(-7, 18, 0),
      endAt: at(-7, 19, 0),
      link: 'https://meet.google.com/mv-prelight',
      reminderMinutes: 15,
      status: MeetingStatus.completed,
      category: MeetingCategory.musicVideos,
      agenda: ['Shot list', 'Lighting plot', 'Talent call sheet'],
      participants: [sarah, marcus, liam],
    ),
    Meeting(
      id: 'm8',
      title: 'Color Grade Approval',
      description: 'Final color grade approval session with client.',
      project: 'Winter Fashion Campaign',
      platform: MeetingPlatform.zoom,
      startAt: at(-10, 15, 0),
      endAt: at(-10, 16, 0),
      link: 'https://zoom.us/j/colorgrade',
      reminderMinutes: 30,
      status: MeetingStatus.completed,
      category: MeetingCategory.commercial,
      agenda: ['Grade review', 'Client notes', 'Final delivery'],
      participants: [sarah, ava],
    ),
  ];
}
