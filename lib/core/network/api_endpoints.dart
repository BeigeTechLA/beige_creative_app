class ApiEndpoints {
  //---------------------------- Creative --------------------------
  static const String register_step1 = "auth/register-crew-step1";
  static const String register_roles = "auth/crew-roles";
  static const String register_Skill = "auth/skills";
  static const String register_equipment = "auth/equipment-autocomplete";
  static const String register_step2 = "auth/register-crew-step2";
  static const String register_step3 = "auth/register-crew-step3";
  static const String register_step3_file = "auth/register-crew-step3-file";
  static const String login = "auth/login";
  static const String dashboardcount = "creator/dashboard-count";
  static const String forgotpassword = "auth/forgot-password-check";
  static const String forgotpasswordverifyotp =
      "auth/forgot-password-verify-otp";
  static const String restartpassword = "auth/reset-password";

  static const String upcomingshoots = "creator/upcoming-accepted-project";
  /// Project detail by id. Caller supplies the id. (Hardcoded in
  /// upcoming_shoot_view_details.dart pre-migration.)
  static String projectDetails(int id) => "creator/project-details/$id";

  static String creatorDashboard({
    required String statsDateFilter,
    String? projectsStatus,
    required int availabilityMonth,
    required int availabilityYear,
    String? projectsDateFilter,
    String? projectsStartDate,
    String? projectsEndDate,
  }) {
    final params = <String>[
      'stats_date_filter=$statsDateFilter',
      'availability_month=$availabilityMonth',
      'availability_year=$availabilityYear',
    ];
    if (projectsStatus != null && projectsStatus.isNotEmpty) {
      params.add('projects_status=$projectsStatus');
    }
    if (projectsDateFilter != null && projectsDateFilter.isNotEmpty) {
      params.add('projects_date_filter=$projectsDateFilter');
      if (projectsDateFilter == 'custom') {
        if (projectsStartDate != null && projectsStartDate.isNotEmpty) {
          params.add('projects_start_date=$projectsStartDate');
        }
        if (projectsEndDate != null && projectsEndDate.isNotEmpty) {
          params.add('projects_end_date=$projectsEndDate');
        }
      }
    }
    return 'creator/dashboard?${params.join('&')}';
  }

  static const String creatordashboarddetails = "creator/dashboard-details";
  static String creatorShoots({
    String requestStatus = 'all',
    String shootStatus = 'completed',
  }) =>
      'creator/shoots?request_status=$requestStatus&shoot_status=$shootStatus';
  static const String createavailability = "creator/availability";
  static const String shootstatus = "creator/get-crew-stats";
  static const String add_availability = "creator/add-availability";
  static const String profiledetails = "creator/get-profile-detail";
  static String crewStats(String filter) =>
      "creator/get-crew-stats?date_filter=$filter";

  static const String editprofile = "creator/edit-profile";
  static const String acceptdeclineproject = "creator/accept-project";
  static const String addportfoliolink = "creator/profile/add-portfolio-links";
  static const String myshootcount = "creator/shoot-count";
  static String creatorShootCardDetails(String status) =>
      "creator/shoot-card-details?status=$status";

  ///My profile

  static const String upload_photo = "creator/profile/upload-profile-photot";
  /// Live profile-photo upload endpoint used by Myprofile. Backend exposes
  /// both this URL and the typo'd [upload_photo] — preserve as-is until the
  /// backend de-dupes. (Hardcoded in myprofile.dart pre-decompose.)
  static const String upload_profile_photo =
      "creator/profile/upload-profile-photo";
  /// Caller appends `/$id`. (Hardcoded in myprofile.dart pre-decompose.)
  static const String edit_portfolio_link = "creator/profile/edit-portfolio-link";
  static const String upload_Featured_Works =
      "creator/profile/files/recent_work";
  static const String upload_certifications =
      "creator/profile/files/certifications";
  static const String delete_allfiles = "creator/profile-file";
  static const String upload_resume = "creator/profile/files/resume";
  static const String upload_recent_work = "creator/profile/files/recent_work";

  static String shootCategories(String tab) =>
      "creator/shoot-categories?tab=$tab";

  static const String accountDeleted = 'auth/user/delete-account/request';
  static const String account_deleted_otp = 'auth/user/delete-account/confirm';

  // ───── Meetings (MT8) ────────────────────────────────────────────────────
  static const String meetings = 'external-meetings';
  /// Per-user list endpoint. Caller supplies the auth'd user's id.
  /// Example: `external-meetings/user/626?limit=100&page=1&sortBy=...`.
  static String meetingsByUser(String userId) =>
      'external-meetings/user/$userId';
  static String meetingById(String id) => 'external-meetings/$id';
  static String meetingParticipants(String id) =>
      'external-meetings/$id/participants';
  static String meetingRespond(String id) => 'external-meetings/$id/respond';

  // ───── File Manager (FM6) — legacy stubs ────────────────────────────────
  // Retained while the dummy repo still ships the old contract. Real
  // endpoints below (FM7 series) supersede these. Delete once
  // `FileManagerRepository` facade is removed (FM7.06+).
  static const String fileManagerRoot = 'file-manager/root';
  static String fileManagerFolder(String id) => 'file-manager/folders/$id';
  static String fileManagerFolderDelete(String id) =>
      'file-manager/folders/$id';
  static String fileManagerFileDelete(String id) => 'file-manager/files/$id';
  static String fileManagerFileDownload(String id) =>
      'file-manager/files/$id/download';
  static const String fileManagerShare = 'file-manager/share';

  // ───── File Manager (FM7 real endpoints) ────────────────────────────────
  // See `docs/feature/filemanager/FILE_MANAGER_API_PLAN.md` §5.4 for the
  // canonical list. Base path is `external-file-manager/` for everything
  // except comments (which live at top-level `comments/`).
  static const String fmWorkspaces = 'external-file-manager/workspaces';
  static String fmWorkspace(String extId) =>
      'external-file-manager/workspace/$extId';
  static String fmWorkspaceFiles(String extId) =>
      'external-file-manager/workspace/$extId/files';
  static const String fmFolder = 'external-file-manager/folder';
  static const String fmFolderDownloadUrl =
      'external-file-manager/folder-download-url';
  static const String fmUploadPolicies =
      'external-file-manager/upload-policies/batch';
  static const String fmFilesUploaded =
      'external-file-manager/files-uploaded/batch';
  static const String fmFileViewUrl = 'external-file-manager/file-view-url';
  static const String fmFileDownloadUrl =
      'external-file-manager/file-download-url';
  static const String fmDelete = 'external-file-manager/delete';
  static const String fmCopyFiles = 'external-file-manager/copy-files';
  static const String fmRevisionReview =
      'external-file-manager/revision-file/review';
  static const String fmShare = 'external-file-manager/share';
  static const String fmShareRequestOtp =
      'external-file-manager/share/request-otp';
  static const String fmShareVerifyOtp =
      'external-file-manager/share/verify-otp';
  static String fmShareContent(String token) =>
      'external-file-manager/share/$token/content';
  static String fmShareViewUrl(String token) =>
      'external-file-manager/share/$token/view-url';
  static String fmShareDownloadUrl(String token) =>
      'external-file-manager/share/$token/download-url';
  static const String comments = 'comments';
  static String commentReply(String id) => 'comments/$id/reply';
  static String commentById(String id) => 'comments/$id';
  static const String fmCommonEvents = 'external-file-manager/common-events';
  static String fmCommonEvent(String extId) =>
      'external-file-manager/common-events/$extId';
  static String fmCommonEventCreatorFolder(String extId) =>
      'external-file-manager/common-events/$extId/creator-folder';

  // ───── Messages / External Chat (M6) ─────────────────────────────────────
  static const String chatRooms = 'external-chat/rooms';
  static const String chatDirectory = 'external-chat/directory';
  static String chatMessages(String roomId) => 'external-chat/messages/$roomId';
  static String chatEditMessage(String messageId) =>
      'external-chat/messages/$messageId/edit';
  static String chatDeleteMessage(String messageId) =>
      'external-chat/messages/$messageId/delete';
  static String chatMessageReaction(String messageId) =>
      'external-chat/messages/$messageId/reaction';
  static String chatMarkRead(String roomId) =>
      'external-chat/room/$roomId/mark-read';
  static String chatRoomDetails(String roomId) =>
      'external-chat/room/$roomId/details';
  static String chatParticipants(String roomId) =>
      'external-chat/participants/$roomId';

  // ───── Affiliate ────────────────────────────────────────────────────────
  static const String affiliateDashboard = 'affiliates/dashboard';
  static const String updateReferralCode = 'affiliates/update/referral';
}
