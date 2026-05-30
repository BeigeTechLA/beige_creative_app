import 'package:flutter/foundation.dart';

import '../../../../model_class/create_dashboard_details_model.dart';
import '../../../../model_class/myprofile_model.dart' as profile;
import '../../../../model_class/upcoming_shoots_model.dart';

/// Combined immutable state for the Home dashboard.
///
/// Each section can show partial data if one fetcher fails — the notifier
/// populates fields independently via `_safe*` wrappers around `Future.wait`.
@immutable
class HomeState {
  // ── Dashboard counts ──
  final int completedShoots;
  final int upcomingShoots;
  final int pendingRequests;

  // ── Upcoming shoots carousel ──
  final List<upcomingdatum> upcomingShootsList;

  // ── Pending requests (dashboard-details filtered to 'pending') ──
  final List<PendingRequestCard> pendingRequestCards;

  // ── Crew stats (shoot status panel) ──
  final int successfulShoots;
  final int pendingShootsCount;
  final int rejectedShoots;
  final int shootRequests;
  final int photographyShoots;
  final int videographyShoots;

  // ── Shoot categories panel ──
  final int categoryPhotoTotal;
  final int categoryVideoTotal;
  final int acceptPhotographyShoots;
  final int acceptVideographyShoots;
  final int rejectedPhoto;
  final int rejectedVideo;
  final int requestPhoto;
  final int requestVideo;

  // ── Availability calendar ──
  final Map<DateTime, String> events;

  // ── Profile ──
  final profile.Data? profileData;

  // ── Lifecycle ──
  final bool isLoading;
  final String? errorMessage;

  // ── UI-local state driven by notifier ──
  final String selectedRange;
  final int selectedTab;
  final int selectedDashboardIndex;
  final String selectedEvent;
  final DateTime focusedDay;

  HomeState({
    this.completedShoots = 0,
    this.upcomingShoots = 0,
    this.pendingRequests = 0,
    this.upcomingShootsList = const [],
    this.pendingRequestCards = const [],
    this.successfulShoots = 0,
    this.pendingShootsCount = 0,
    this.rejectedShoots = 0,
    this.shootRequests = 0,
    this.photographyShoots = 0,
    this.videographyShoots = 0,
    this.categoryPhotoTotal = 0,
    this.categoryVideoTotal = 0,
    this.acceptPhotographyShoots = 0,
    this.acceptVideographyShoots = 0,
    this.rejectedPhoto = 0,
    this.rejectedVideo = 0,
    this.requestPhoto = 0,
    this.requestVideo = 0,
    this.events = const {},
    this.profileData,
    this.isLoading = false,
    this.errorMessage,
    this.selectedRange = 'Month',
    this.selectedTab = 0,
    this.selectedDashboardIndex = 0,
    this.selectedEvent = 'All Events',
    DateTime? focusedDay,
  }) : focusedDay = focusedDay ?? DateTime.now();

  HomeState copyWith({
    int? completedShoots,
    int? upcomingShoots,
    int? pendingRequests,
    List<upcomingdatum>? upcomingShootsList,
    List<PendingRequestCard>? pendingRequestCards,
    int? successfulShoots,
    int? pendingShootsCount,
    int? rejectedShoots,
    int? shootRequests,
    int? photographyShoots,
    int? videographyShoots,
    int? categoryPhotoTotal,
    int? categoryVideoTotal,
    int? acceptPhotographyShoots,
    int? acceptVideographyShoots,
    int? rejectedPhoto,
    int? rejectedVideo,
    int? requestPhoto,
    int? requestVideo,
    Map<DateTime, String>? events,
    profile.Data? profileData,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? selectedRange,
    int? selectedTab,
    int? selectedDashboardIndex,
    String? selectedEvent,
    DateTime? focusedDay,
  }) {
    return HomeState(
      completedShoots: completedShoots ?? this.completedShoots,
      upcomingShoots: upcomingShoots ?? this.upcomingShoots,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      upcomingShootsList: upcomingShootsList ?? this.upcomingShootsList,
      pendingRequestCards: pendingRequestCards ?? this.pendingRequestCards,
      successfulShoots: successfulShoots ?? this.successfulShoots,
      pendingShootsCount: pendingShootsCount ?? this.pendingShootsCount,
      rejectedShoots: rejectedShoots ?? this.rejectedShoots,
      shootRequests: shootRequests ?? this.shootRequests,
      photographyShoots: photographyShoots ?? this.photographyShoots,
      videographyShoots: videographyShoots ?? this.videographyShoots,
      categoryPhotoTotal: categoryPhotoTotal ?? this.categoryPhotoTotal,
      categoryVideoTotal: categoryVideoTotal ?? this.categoryVideoTotal,
      acceptPhotographyShoots:
          acceptPhotographyShoots ?? this.acceptPhotographyShoots,
      acceptVideographyShoots:
          acceptVideographyShoots ?? this.acceptVideographyShoots,
      rejectedPhoto: rejectedPhoto ?? this.rejectedPhoto,
      rejectedVideo: rejectedVideo ?? this.rejectedVideo,
      requestPhoto: requestPhoto ?? this.requestPhoto,
      requestVideo: requestVideo ?? this.requestVideo,
      events: events ?? this.events,
      profileData: profileData ?? this.profileData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedRange: selectedRange ?? this.selectedRange,
      selectedTab: selectedTab ?? this.selectedTab,
      selectedDashboardIndex:
          selectedDashboardIndex ?? this.selectedDashboardIndex,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      focusedDay: focusedDay ?? this.focusedDay,
    );
  }
}
