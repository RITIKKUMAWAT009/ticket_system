import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/models/user_model.dart';
import '../../features/tickets/data/ticket_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

final ticketRepositoryProvider = Provider<TicketRepository>(
  (ref) => TicketRepository(ref.watch(apiClientProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.watch(apiClientProvider)),
);

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState());

  final AuthRepository _repo;

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final loggedIn = await _repo.isLoggedIn();
      if (loggedIn) {
        final user = await _repo.getMe();
        state = AuthState(user: user, isLoading: false);
      } else {
        state = const AuthState(isLoading: false);
      }
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
    }
  }

  Future<AuthResponse> verifyOtp(String mobile, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final auth = await _repo.verifyOtp(mobile, otp);
      state = AuthState(user: auth.user, isLoading: false);
      return auth;
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);

final districtsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(ticketRepositoryProvider).getDistricts();
});

final ticketsProvider = FutureProvider.family<List<dynamic>, String?>((ref, status) async {
  return ref.watch(ticketRepositoryProvider).getTickets(status: status);
});

final ticketDetailProvider = FutureProvider.family<dynamic, String>((ref, id) async {
  return ref.watch(ticketRepositoryProvider).getTicket(id);
});

final notificationsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(notificationRepositoryProvider).getNotifications();
});

final analyticsProvider = FutureProvider<dynamic>((ref) async {
  return ref.watch(ticketRepositoryProvider).getAnalytics();
});

final captchaProvider = FutureProvider<CaptchaModel>((ref) async {
  return ref.watch(authRepositoryProvider).getCaptcha();
});
