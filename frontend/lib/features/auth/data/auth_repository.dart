import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../domain/models/user_model.dart';

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  Future<CaptchaModel> getCaptcha() async {
    final response = await _client.get<Map<String, dynamic>>(ApiConstants.authCaptcha);
    return CaptchaModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.authRegister,
      data: data,
    );
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendOtp(String mobile, String token, String answer) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.authSendOtp,
      data: {
        'mobileNumber': mobile,
        'captchaToken': token,
        'captchaAnswer': answer,
      },
    );
    return response['data'] as Map<String, dynamic>;
  }

  Future<AuthResponse> verifyOtp(String mobile, String otp) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.authVerifyOtp,
      data: {'mobileNumber': mobile, 'otp': otp},
    );
    final data = response['data'] as Map<String, dynamic>;
    final auth = AuthResponse.fromJson(data);
    await _client.saveTokens(auth.accessToken, auth.refreshToken);
    return auth;
  }

  Future<UserModel> getMe() async {
    final response = await _client.get<Map<String, dynamic>>(ApiConstants.authMe);
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _client.clearTokens();
  }

  Future<bool> isLoggedIn() => _client.hasToken();
}
