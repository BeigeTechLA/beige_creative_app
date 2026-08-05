/// Centralized asset path constants for the Beige app.
///
/// All asset references must use this file. Never hardcode asset
/// path strings in widgets.
class AppAssets {
  AppAssets._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DIRECTORIES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String _svg = 'assets/svg';
  static const String _images = 'assets/images';
  static const String _lottie = 'assets/lottie';
  static const String _active = 'assets/active';
  static const String _inactive = 'assets/inactive';
  static const String _icon = 'assets/icon';
  static const String _shootSvg = 'assets/svg/shoots';
  static const String _messageSvg = 'assets/svg/message';
  static const String _meetingSvg = 'assets/svg/meeting';
  static const String _onboarding = 'assets/onboarding';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SVG — Message
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String icGroupChat = '$_messageSvg/ic_group_chat.svg';
  static const String msgEmptyState = '$_messageSvg/msg_empty_state_svg.svg';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SVG — Meeting
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String icMeetingDatetime =
      '$_meetingSvg/ic_meeting_datetime.svg';
  static const String icMeetingLink = '$_meetingSvg/ic_meeting_link.svg';
  static const String icRelatedShoot = '$_meetingSvg/ic_related_shoot.svg';
  static const String icGoogleMeet = '$_meetingSvg/ic_google_meet.svg';
  static const String meetingEmptyState =
      '$_meetingSvg/meeting_empty_state.svg';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Active Icons (Bottom Nav / Drawer)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String activeDashboard = '$_active/dashboard_active.svg';
  static const String activeShoots = '$_active/shoots_active.svg';
  static const String activeFileManager = '$_active/file_manager_active.svg';
  static const String activeMessages = '$_active/messages_active.svg';
  static const String activeMeetings = '$_active/meetings_active.svg';
  static const String activeManageAvailability =
      '$_active/manage_availability_active.svg';
  static const String activeAffiliate = '$_active/affiliate_active.svg';
  static const String activePayouts = '$_active/payouts_active.svg';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Inactive Icons
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String inactiveDashboard = '$_inactive/dashboard_inactive.svg';
  static const String inactiveShoots = '$_inactive/shoots_inactive.svg';
  static const String inactiveFileManager =
      '$_inactive/file_manager_inactive.svg';
  static const String inactiveMessages = '$_inactive/messages_inactive.svg';
  static const String inactiveMeetings = '$_inactive/meetings_inactive.svg';
  static const String inactiveManageAvailability =
      '$_inactive/manage_availability_inactive.svg';
  static const String inactiveAffiliate = '$_inactive/affiliate_inactive.svg';
  static const String inactivePayouts = '$_inactive/payouts_inactive.svg';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Common Images
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String groupLogo = '$_images/group_logo.png';
  static const String rectangle = '$_images/rectangle.png';
  static const String noData = '$_images/no_data.png';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SVG — Navigation & Actions
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String back = '$_svg/back.svg';
  static const String menu = '$_svg/menu.svg';
  static const String goto = '$_svg/goto.svg';
  static const String location = '$_svg/location.svg';
  static const String calendar = '$_svg/calendar.svg';
  static const String myCalendar = '$_svg/my_calendar.svg';
  static const String icAddDate = '$_icon/ic_add_date.svg';
  static const String editCircle = '$_svg/edit_circle.svg';
  static const String iconFilter = '$_svg/icon_filter.svg';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SVG — Social
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String facebook = '$_svg/facebook.svg';
  static const String tiktok = '$_svg/tiktok.svg';
  static const String insta = '$_svg/insta.svg';
  static const String behance = '$_svg/behance.svg';
  static const String vimeo = '$_svg/v.svg';
  static const String youtube = '$_svg/you_tube.svg';
  static const String googleDrive = '$_svg/googledrive.svg';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SVG — Icons & UI Elements
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String ball = '$_svg/ball.svg';
  static const String pencil = '$_svg/Pencil.svg';
  static const String delete = '$_svg/delete.svg';
  static const String notificationBell = '$_svg/notificationbell.svg';
  static const String dollar = '$_svg/dollar.svg';
  static const String medal = '$_svg/medal.svg';
  static const String map = '$_svg/map.svg';
  static const String userId = '$_svg/userid.svg';
  static const String certificates = '$_svg/certificates.svg';
  static const String resume = '$_svg/resume.svg';
  static const String appPreference = '$_svg/appperference.svg';
  static const String notificationSetting = '$_svg/notificationsetting.svg';
  static const String appVersion = '$_svg/appversion.svg';
  static const String moon = '$_svg/moon.svg';
  static const String time = '$_svg/time.svg';
  static const String myProfileEdit = '$_svg/myprofile_edit.svg';
  static const String imageZoom = '$_svg/Image_zoom.svg';
  static const String rectangleProfile = '$_svg/rectangle_profile.svg';
  static const String circleArrow = '$_svg/circle_arrow.svg';
  static const String moreVert = '$_svg/more_vert.svg';
  static const String infoFilled = '$_svg/Info.svg';
  static const String profileTerms = '$_svg/terms_conditions.svg';
  static const String profilePrivacy = '$_svg/privacy_policy.svg';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SVG — User & Profile
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String userCircle = '$_svg/user_circle.svg';
  static const String personIcon = '$_svg/person_icons.svg';
  static const String phoneCalling = '$_svg/Phone_Calling.svg';
  static const String mailIcon = '$_svg/mail_icon.svg';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SVG — Eye / Password
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String eyeOpen = '$_svg/eyes1.svg';
  static const String eyeClose = '$_svg/eyes2.svg';
  static const String icFolder = '$_svg/ic_folder.svg';
  static const String icLink = '$_svg/ic_link.svg';
  static const String icUnlink = '$_svg/ic_unlink.svg';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SVG — Upload
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String scanner = '$_svg/scanner.svg';
  static const String document = '$_svg/document_attachment.svg';
  static const String gallery = '$_svg/gallery.svg';
  static const String boxEdit = '$_svg/box_edit.svg';
  static const String upload = '$_svg/upload.svg';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SVG — Misc Icons
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String dropdown = '$_svg/dropdown.svg';
  static const String bookVideo = '$_svg/book_video.svg';
  static const String info = '$_svg/infosvg.svg';
  static const String hourglassTime = '$_svg/hourglass_time.svg';
  static const String searchIcon = '$_svg/search_icon.svg';
  static const String imageHolder = '$_svg/image_holder.svg';
  static const String list = '$_svg/list.svg';
  static const String grid = '$_svg/grid.svg';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SVG — Shoots
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String clockIcon = '$_shootSvg/ic_clock.svg';
  static const String declinedIcon = '$_shootSvg/declined_icon.svg';
  static const String photoIcon = '$_shootSvg/photo_icon.svg';
  static const String videoIcon = '$_shootSvg/ic_video.svg';
  static const String calendarIcon = '$_shootSvg/ic_calendar.svg';
  static const String icDoller = '$_shootSvg/ic_doller.svg';
  static const String icClockCircle = '$_shootSvg/ic_clock_circle.svg';
  static const String icShootDate = '$_shootSvg/ic_shoot_date.svg';
  static const String icShootLocation = '$_shootSvg/ic_shoot_location.svg';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Onboarding
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String onboardingHero = '$_onboarding/onboding_image.png';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Lottie
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String lottieSuccess = '$_lottie/success_animation.json';
  static const String lottieSplash = '$_lottie/Component10.json';
  static const String lottieLoader = '$_lottie/loader.json';
  static const String lottieCircleLoader = '$_lottie/circleLoader.json';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // FONT FAMILIES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const String fontUnbounded = 'Unbounded';
  static const String fontOutfit = 'Outfit';
}
