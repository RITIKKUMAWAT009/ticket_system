class ApiConstants {
  static const authCaptcha = '/auth/captcha';
  static const authRegister = '/auth/register';
  static const authSendOtp = '/auth/send-otp';
  static const authVerifyOtp = '/auth/verify-otp';
  static const authRefresh = '/auth/refresh';
  static const authMe = '/auth/me';

  static const districts = '/districts';
  static String districtTehsils(String id) => '/districts/$id/tehsils';
  static String tehsilProjects(String id) => '/tehsils/$id/projects';

  static const tickets = '/tickets';
  static String ticketById(String id) => '/tickets/$id';
  static String ticketStatus(String id) => '/tickets/$id/status';
  static String ticketAssign(String id) => '/tickets/$id/assign';
  static String ticketComments(String id) => '/tickets/$id/comments';
  static const ticketAnalytics = '/tickets/analytics';

  static const notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const notificationsReadAll = '/notifications/read-all';
  static const deviceToken = '/notifications/device-token';

  static const tehsils = '/tehsils';
  static const projects = '/projects';
}
