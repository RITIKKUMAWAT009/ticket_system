import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/screens/admin_screens.dart';
import '../../features/agent/presentation/screens/agent_tickets_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/registration_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/tickets/presentation/screens/citizen_dashboard_screen.dart';
import '../../features/tickets/presentation/screens/create_ticket_screen.dart';
import '../../features/tickets/presentation/screens/my_tickets_screen.dart';
import '../../features/tickets/presentation/screens/ticket_detail_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(mobileNumber: state.extra as String),
      ),
      GoRoute(path: '/register', builder: (_, __) => const RegistrationScreen()),

      // Citizen routes
      GoRoute(path: '/dashboard', builder: (_, __) => const CitizenDashboardScreen()),
      GoRoute(path: '/tickets', builder: (_, __) => const MyTicketsScreen()),
      GoRoute(path: '/tickets/create', builder: (_, __) => const CreateTicketScreen()),
      GoRoute(
        path: '/tickets/:id',
        builder: (_, state) => TicketDetailScreen(ticketId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),

      // Agent routes
      GoRoute(path: '/agent/tickets', builder: (_, __) => const AgentTicketsScreen()),

      // Admin routes
      GoRoute(path: '/admin/dashboard', builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/districts', builder: (_, __) => const DistrictManagementScreen()),
      GoRoute(path: '/admin/tehsils', builder: (_, __) => const TehsilManagementScreen()),
      GoRoute(path: '/admin/projects', builder: (_, __) => const ProjectManagementScreen()),
      GoRoute(path: '/admin/assign', builder: (_, __) => const TicketAssignmentScreen()),
      GoRoute(path: '/admin/reports', builder: (_, __) => const ReportsScreen()),
    ],
  );
}
