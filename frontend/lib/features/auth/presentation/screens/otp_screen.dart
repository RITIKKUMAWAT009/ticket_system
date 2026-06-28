import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/responsive.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.mobileNumber});

  final String mobileNumber;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _verify() async {
    if (_otpController.text.length != 6) {
      setState(() => _error = 'Enter 6-digit OTP');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = await ref
          .read(authProvider.notifier)
          .verifyOtp(widget.mobileNumber, _otpController.text);

      if (!mounted) return;

      if (auth.user.isAdmin) {
        context.go('/admin/dashboard');
      } else if (auth.user.isAgent) {
        context.go('/agent/tickets');
      } else {
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: ResponsiveLayout(
        child: Padding(
          padding: Responsive.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.sms, size: 64, color: Color(0xFF1565C0)),
              const SizedBox(height: 16),
              Text(
                'OTP sent to +91 ${widget.mobileNumber}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  hintText: '6 digit OTP',
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _verify,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
