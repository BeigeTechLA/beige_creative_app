class ApiEndpoints {
  //---------------------------- Creative --------------------------
  static const String register_step1 = "auth/register-crew-step1";
  static const String register_roles = "auth/crew-roles";
  static const String register_Skill = "auth/skills";
  static const String register_equipment = "auth/equipment-autocomplete";
  static const String register_step2 = "auth/register-crew-step2";
  static const String register_step3 = "auth/register-crew-step3";
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
  static const String creatordashboarddetails = "creator/dashboard-details";
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

  // ───── Messages / External Chat (M6) ─────────────────────────────────────
  static const String chatRooms = 'external-chat/rooms';
  static const String chatDirectory = 'external-chat/directory';
  static String chatMessages(String roomId) => 'external-chat/messages/$roomId';
  static String chatEditMessage(String messageId) =>
      'external-chat/messages/$messageId/edit';
  static String chatDeleteMessage(String messageId) =>
      'external-chat/messages/$messageId/delete';
  static String chatMarkRead(String roomId) =>
      'external-chat/room/$roomId/mark-read';
  static String chatRoomDetails(String roomId) =>
      'external-chat/room/$roomId/details';
  static String chatParticipants(String roomId) =>
      'external-chat/participants/$roomId';
}
