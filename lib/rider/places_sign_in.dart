import 'package:flutter/material.dart';
import 'places_api.dart';

class PlacesSignInDialog extends StatefulWidget {
  const PlacesSignInDialog({super.key, required this.api});
  final HiGoApi api;
  @override
  State<PlacesSignInDialog> createState() => _PlacesSignInDialogState();
}

class _PlacesSignInDialogState extends State<PlacesSignInDialog> {
  final _identifier = TextEditingController(),
      _password = TextEditingController();
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_identifier.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Enter your account and password.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.api.signIn(_identifier.text, _password.text);
      if (mounted) Navigator.pop(context, true);
    } on PlacesFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Sign in to HiGO'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Use your development account to search live places. Your session lasts until this app is closed or refreshed.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _identifier,
            enabled: !_busy,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email or phone'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            enabled: !_busy,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            onSubmitted: (_) {
              if (!_busy) _submit();
            },
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _busy ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _busy ? null : _submit,
        child: Text(_busy ? 'Signing in…' : 'Sign in'),
      ),
    ],
  );
}
