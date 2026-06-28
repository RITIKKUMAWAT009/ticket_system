import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/providers.dart';
import '../widgets/auth_page_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _mobileController = TextEditingController();
  final _captchaController = TextEditingController();
  String? _captchaToken;
  String? _captchaQuestion;
  bool _loading = false;
  bool _captchaLoading = true;
  String? _connectionError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCaptcha());
  }

  Future<void> _loadCaptcha() async {
    setState(() {
      _captchaLoading = true;
      _connectionError = null;
    });

    try {
      final captcha = await ref.read(authRepositoryProvider).getCaptcha();
      if (!mounted) return;
      setState(() {
        _captchaToken = captcha.captchaToken;
        _captchaQuestion = captcha.captchaQuestion;
        _captchaLoading = false;
        _connectionError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _captchaLoading = false;
        _captchaToken = null;
        _captchaQuestion = null;
        _connectionError = e.toString().replaceFirst('ApiException: ', '');
      });
    }
  }

  Future<void> _sendOtp() async {
    if (_mobileController.text.length != 10) {
      setState(() => _formError = 'Enter a valid 10-digit mobile number');
      return;
    }
    if (_captchaToken == null) {
      setState(() => _formError = 'Captcha not loaded. Check server connection.');
      return;
    }
    if (_captchaController.text.isEmpty) {
      setState(() => _formError = 'Please solve the captcha');
      return;
    }

    setState(() {
      _loading = true;
      _formError = null;
    });

    try {
      await ref.read(authRepositoryProvider).sendOtp(
            _mobileController.text,
            _captchaToken!,
            _captchaController.text,
          );
      if (mounted) {
        context.push('/otp', extra: _mobileController.text);
      }
    } catch (e) {
      setState(() {
        _formError = e.toString().replaceFirst('ApiException: ', '');
      });
      _loadCaptcha();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(
      title: 'Login',
      subtitle: 'Enter your mobile number to receive an OTP',
      errorMessage: _connectionError ?? _formError,
      onRetry: _connectionError != null ? _loadCaptcha : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _mobileController,
            decoration: const InputDecoration(
              labelText: 'Mobile Number',
              prefixIcon: Icon(Icons.phone_android_outlined),
              prefixText: '+91 ',
              hintText: '10 digit number',
            ),
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) {
              if (_formError != null) setState(() => _formError = null);
            },
          ),
          const SizedBox(height: 20),
          CaptchaField(
            question: _captchaQuestion,
            controller: _captchaController,
            onRefresh: _loadCaptcha,
            loading: _captchaLoading,
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: (_loading || _captchaLoading || _connectionError != null)
                  ? null
                  : _sendOtp,
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Send OTP'),
            ),
          ),
        ],
      ),
      footer: TextButton(
        onPressed: () => context.push('/register'),
        child: const Text(
          'New user? Register here',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _captchaController.dispose();
    super.dispose();
  }
}
