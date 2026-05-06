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
  static const String forgotpasswordverifyotp = "auth/forgot-password-verify-otp";
  static const String restartpassword = "auth/reset-password";
  static const String upcomingshoots = "creator/upcoming-accepted-project";
  static const String creatordashboarddetails = "creator/dashboard-details";
  static const String createavailability = "creator/availability";
  static const String shootstatus= "creator/get-crew-stats";
  static const String add_availability= "/creator/add-availability";
  static const String profiledetails= "creator/get-profile-detail";
  static String crewStats(String filter) =>   "creator/get-crew-stats?date_filter=$filter";

  static const String editprofile= "creator/edit-profile";
  static const String acceptdeclineproject= "creator/accept-project";
  static const String addportfoliolink= "creator/profile/add-portfolio-links";
  static const String myshootcount= "creator/shoot-count";

  ///My profile

  static const String upload_photo = "creator/profile/upload-profile-photot";
  static const String upload_Featured_Works = "creator/profile/files/recent_work";
  static const String upload_certifications = "creator/profile/files/certifications";
  static const String delete_allfiles = "creator/profile-file";
  static const String upload_resume = "creator/profile/files/resume";
  static const String upload_recent_work = "creator/profile/files/recent_work";














































}
