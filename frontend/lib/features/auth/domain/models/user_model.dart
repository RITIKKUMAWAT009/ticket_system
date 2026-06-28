class UserModel {
  final String id;
  final String mobileNumber;
  final String fullName;
  final String? fatherName;
  final String email;
  final String? aadhaarNumber;
  final String? passportNumber;
  final String gender;
  final String role;
  final String? profileImageUrl;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.mobileNumber,
    required this.fullName,
    this.fatherName,
    required this.email,
    this.aadhaarNumber,
    this.passportNumber,
    required this.gender,
    required this.role,
    this.profileImageUrl,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      mobileNumber: json['mobileNumber'] as String,
      fullName: json['fullName'] as String,
      fatherName: json['fatherName'] as String?,
      email: json['email'] as String,
      aadhaarNumber: json['aadhaarNumber'] as String?,
      passportNumber: json['passportNumber'] as String?,
      gender: json['gender'] ?? "",
      role: json['role'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  bool get isCitizen => role == 'CITIZEN';
  bool get isAgent => role == 'SUPPORT_AGENT';
  bool get isAdmin => role == 'ADMIN';
}

class CaptchaModel {
  final String captchaToken;
  final String captchaQuestion;

  const CaptchaModel(
      {required this.captchaToken, required this.captchaQuestion});

  factory CaptchaModel.fromJson(Map<String, dynamic> json) {
    return CaptchaModel(
      captchaToken: json['captchaToken'] as String,
      captchaQuestion: json['captchaQuestion'] as String,
    );
  }
}

class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
