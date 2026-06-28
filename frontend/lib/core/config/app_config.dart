import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiBaseUrl {
    return "https://ticket-system-fg7y.onrender.com/api";
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kIsWeb) {
      final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
      return '${Uri.base.scheme}://$host:3000/api';
    }

    return 'http://localhost:3000/api';
  }

  static const String appName = 'Ticket Management System';
}
