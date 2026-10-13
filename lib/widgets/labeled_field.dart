import 'package:flutter/material.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

class LabeledField extends StatefulWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.fieldKey,
    required this.validator,
    this.icon,
    this.password = false,
    this.keyboardType,
    this.autofillHints,
  });
  final String label, hint;
  final TextEditingController controller;
  final ValueKey<String> fieldKey;
  final FormFieldValidator<String> validator;
  final IconData? icon;
  final bool password;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  @override
  State<LabeledField> createState() => _LabeledFieldState();
}

class _LabeledFieldState extends State<LabeledField> {
  bool _visible = false;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FieldLabel(widget.label),
      TextFormField(
        key: widget.fieldKey,
        controller: widget.controller,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        textInputAction: TextInputAction.next,
        obscureText: widget.password && !_visible,
        enableSuggestions: !widget.password,
        autocorrect: !widget.password,
        autofillHints: widget.autofillHints,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: widget.icon == null ? null : Icon(widget.icon, size: 21),
          suffixIcon: !widget.password
              ? null
              : IconButton(
                  key: Key('${widget.fieldKey.value}-visibility'),
                  tooltip: _visible ? 'Hide password' : 'Show password',
                  onPressed: () => setState(() => _visible = !_visible),
                  icon: Icon(
                    _visible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
        ),
      ),
    ],
  );
}
