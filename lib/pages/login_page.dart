import 'package:flutter/material.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '../validation.dart';
import '../widgets/auth_shell.dart';
import '../widgets/labeled_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController(),
      _password = TextEditingController();
  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validateIdentifier(String? value) {
    final input = value?.trim() ?? '';
    if (validateEmail(input) == null) return null;
    if (input.startsWith('+')) {
      try {
        if (PhoneNumber.parse(input).isValid()) return null;
      } on Exception {
        /* invalid */
      }
    }
    return 'Enter a valid email address or phone with country code.';
  }

  @override
  Widget build(BuildContext context) => AuthShell(
    title: 'Welcome Back',
    subtitle: 'Log in to book rides or drive and earn.',
    headerHeight: 362,
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledField(
            label: 'Phone Number or Email',
            hint: 'Enter your phone number or email',
            controller: _identifier,
            fieldKey: const ValueKey('email'),
            validator: _validateIdentifier,
            icon: Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username],
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _password,
            fieldKey: const ValueKey('password'),
            validator: validatePassword,
            icon: Icons.lock_outline,
            password: true,
            autofillHints: const [AutofillHints.password],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => showDemoNotice(
                context,
                'Password reset',
                'Password reset is not connected in this local demo.',
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('submit-login'),
            onPressed: () {
              FocusScope.of(context).unfocus();
              if (_formKey.currentState!.validate()) {
                showDemoNotice(
                  context,
                  'Login demo',
                  'Your form is valid. No authentication request was sent.',
                );
              }
            },
            child: const Text('Log In'),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(fontSize: 11, color: Color(0xFF858B98)),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: () => showDemoNotice(
              context,
              'Phone verification',
              'OTP verification is not connected in this local demo. No SMS was sent.',
            ),
            icon: const Icon(Icons.phone_android_outlined, size: 20),
            label: const Text('Continue with Phone (OTP)'),
          ),
          const SizedBox(height: 12),
          const AuthCrossLink(
            prompt: "Don't have an account?",
            link: 'Sign Up',
            destination: '/register',
            linkKey: Key('to-register'),
          ),
        ],
      ),
    ),
  );
}
