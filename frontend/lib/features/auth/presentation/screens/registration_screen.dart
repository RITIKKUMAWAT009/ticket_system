import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/providers.dart';
import '../widgets/auth_page_layout.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _registrationType = 'INDIAN';
  final _mobileController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _passportController = TextEditingController();
  final _emailController = TextEditingController();
  final _captchaController = TextEditingController();
  String _gender = 'MALE';
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
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _captchaLoading = false;
        _connectionError = e.toString().replaceFirst('ApiException: ', '');
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_captchaToken == null) {
      setState(() => _formError = 'Captcha not loaded. Check server connection.');
      return;
    }

    setState(() {
      _loading = true;
      _formError = null;
    });

    try {
      final data = <String, dynamic>{
        'registrationType': _registrationType,
        'mobileNumber': _mobileController.text,
        'fullName': _fullNameController.text,
        'fatherName': _fatherNameController.text,
        'email': _emailController.text,
        'gender': _gender,
        'captchaToken': _captchaToken,
        'captchaAnswer': _captchaController.text,
      };

      if (_registrationType == 'INDIAN') {
        data['aadhaarNumber'] = _aadhaarController.text;
      } else {
        data['passportNumber'] = _passportController.text;
      }

      await ref.read(authRepositoryProvider).register(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please login.')),
        );
        context.go('/login');
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
      title: 'Register',
      subtitle: 'Create your citizen account',
      errorMessage: _connectionError ?? _formError,
      onRetry: _connectionError != null ? _loadCaptcha : null,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'INDIAN', label: Text('Indian')),
                ButtonSegment(value: 'NRI', label: Text('NRI')),
              ],
              selected: {_registrationType},
              onSelectionChanged: (s) => setState(() => _registrationType = s.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _mobileController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixIcon: Icon(Icons.phone_android_outlined),
                prefixText: '+91 ',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => v == null || v.length != 10 ? 'Enter valid 10-digit mobile' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => v == null || v.length < 2 ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fatherNameController,
              decoration: const InputDecoration(
                labelText: "Father's Name",
                prefixIcon: Icon(Icons.family_restroom_outlined),
              ),
              validator: (v) => v == null || v.length < 2 ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            if (_registrationType == 'INDIAN')
              TextFormField(
                controller: _aadhaarController,
                decoration: const InputDecoration(
                  labelText: 'Aadhaar Number',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                keyboardType: TextInputType.number,
                maxLength: 12,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v == null || v.length != 12 ? 'Must be 12 digits' : null,
              )
            else
              TextFormField(
                controller: _passportController,
                decoration: const InputDecoration(
                  labelText: 'Passport Number',
                  prefixIcon: Icon(Icons.card_travel_outlined),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.wc_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'MALE', child: Text('Male')),
                DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                DropdownMenuItem(value: 'OTHER', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => _gender = v!),
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
                    : _register,
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Register'),
              ),
            ),
          ],
        ),
      ),
      footer: TextButton(
        onPressed: () => context.go('/login'),
        child: const Text(
          'Already registered? Login',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _fullNameController.dispose();
    _fatherNameController.dispose();
    _aadhaarController.dispose();
    _passportController.dispose();
    _emailController.dispose();
    _captchaController.dispose();
    super.dispose();
  }
}
