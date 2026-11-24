import 'package:flutter/material.dart';

/// Field password dengan tombol tampilkan/sembunyikan.
class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.controller,
    required this.label,
    required this.validator,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.autofillHints,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final bool enabled;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscure,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofillHints: widget.autofillHints,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Tampilkan password' : 'Sembunyikan password',
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}