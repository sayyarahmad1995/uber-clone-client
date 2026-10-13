import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import '../validation.dart';
import '../widgets/auth_shell.dart';
import '../widgets/country_phone_field.dart';
import '../widgets/labeled_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameAnchor = GlobalKey(),
      _phoneAnchor = GlobalKey(),
      _emailAnchor = GlobalKey();
  final _passwordAnchor = GlobalKey(),
      _confirmationAnchor = GlobalKey(),
      _termsAnchor = GlobalKey();
  final _name = TextEditingController(),
      _phone = TextEditingController(),
      _email = TextEditingController();
  final _password = TextEditingController(),
      _confirmation = TextEditingController();
  late Country _country;
  bool _termsAccepted = false, _submitted = false;
  String? _phoneError;
  @override
  void initState() {
    super.initState();
    _country = initialCountry(
      WidgetsBinding.instance.platformDispatcher.locale,
    );
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _phone,
      _email,
      _password,
      _confirmation,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState!.validate();
    final normalized = internationalPhone(_phone.text, _country.countryCode);
    setState(() {
      _submitted = true;
      _phoneError = normalized == null
          ? 'Enter a valid phone number for the selected country.'
          : null;
    });
    if (!valid || normalized == null || !_termsAccepted) {
      final firstError = validateName(_name.text) != null
          ? _nameAnchor
          : normalized == null
          ? _phoneAnchor
          : validateEmail(_email.text) != null
          ? _emailAnchor
          : validatePassword(_password.text) != null
          ? _passwordAnchor
          : validateConfirmation(_confirmation.text, _password.text) != null
          ? _confirmationAnchor
          : _termsAnchor;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final target = firstError.currentContext;
        if (target != null) {
          Scrollable.ensureVisible(
            target,
            alignment: .1,
            duration: const Duration(milliseconds: 220),
          );
        }
      });
      return;
    }
    showDemoNotice(
      context,
      'Registration demo',
      'Your form is valid.\n\nPhone: $normalized\nCountry: ${_country.countryCode}'
          '\n\nNo account was created and no SMS was sent.',
    );
  }

  @override
  Widget build(BuildContext context) => AuthShell(
    title: 'Create Your Account',
    subtitle: 'Join HiGO to book rides or drive and earn.',
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledField(
            label: 'Full Name',
            key: _nameAnchor,
            hint: 'Enter your full name',
            controller: _name,
            fieldKey: const ValueKey('full-name'),
            validator: validateName,
            icon: Icons.person_outline,
            autofillHints: const [AutofillHints.name],
          ),
          const SizedBox(height: 18),
          const FieldLabel('Phone Number'),
          CountryPhoneField(
            key: _phoneAnchor,
            controller: _phone,
            country: _country,
            errorText: _phoneError,
            onCountryChanged: (country) => setState(() {
              _country = country;
              _phoneError = null;
            }),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Email Address',
            key: _emailAnchor,
            hint: 'Enter your email address',
            controller: _email,
            fieldKey: const ValueKey('email'),
            validator: validateEmail,
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Password',
            key: _passwordAnchor,
            hint: 'Enter your password',
            controller: _password,
            fieldKey: const ValueKey('password'),
            validator: validatePassword,
            icon: Icons.lock_outline,
            password: true,
            autofillHints: const [AutofillHints.newPassword],
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Confirm Password',
            key: _confirmationAnchor,
            hint: 'Confirm your password',
            controller: _confirmation,
            fieldKey: const ValueKey('confirm-password'),
            validator: (value) => validateConfirmation(value, _password.text),
            icon: Icons.lock_outline,
            password: true,
          ),
          const SizedBox(height: 18),
          Row(
            key: _termsAnchor,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 26,
                height: 32,
                child: Checkbox(
                  key: const Key('terms-checkbox'),
                  semanticLabel:
                      'Accept HiGO Terms of Service and acknowledge Privacy Policy',
                  value: _termsAccepted,
                  onChanged: (value) =>
                      setState(() => _termsAccepted = value ?? false),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      "I agree to HiGO's ",
                      style: TextStyle(fontSize: 11, color: Color(0xFF858B98)),
                    ),
                    _legalLink('Terms of Service'),
                    const Text(
                      ' and acknowledge the ',
                      style: TextStyle(fontSize: 11, color: Color(0xFF858B98)),
                    ),
                    _legalLink('Privacy Policy'),
                    const Text('.', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          if (_submitted && !_termsAccepted)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Please accept the terms to continue.',
                style: TextStyle(fontSize: 12, color: Color(0xFFB3261E)),
              ),
            ),
          const SizedBox(height: 20),
          FilledButton(
            key: const Key('submit-register'),
            onPressed: _submit,
            child: const Text('Create Account'),
          ),
          const SizedBox(height: 12),
          const AuthCrossLink(
            prompt: 'Already have an account?',
            link: 'Log In',
            destination: '/login',
            linkKey: Key('to-login'),
          ),
        ],
      ),
    ),
  );
  Widget _legalLink(String title) => InkWell(
    onTap: () => showDemoNotice(
      context,
      title,
      '$title content is not configured in this local demo.',
    ),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
    ),
  );
}
