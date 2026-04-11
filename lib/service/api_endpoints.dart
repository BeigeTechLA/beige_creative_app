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
  static const String profiledetails= "auth/profile";
  // static const String shootstatusmonth= "creator/get-crew-stats?date_filter=this_month";
  // static const String shootstatusweek= "creator/get-crew-stats?date_filter=this_week";
  // static const String shootstatusyear= "creator/get-crew-stats?date_filter=this_year";
  static String crewStats(String filter) =>
      "creator/get-crew-stats?date_filter=$filter";





































}
