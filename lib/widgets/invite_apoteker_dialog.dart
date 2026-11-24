import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/admin_exception.dart';
import '../providers/user_admin_provider.dart';
import '../utils/validators.dart';

/// Dialog untuk membuat undangan Apoteker berdasarkan email.
class InviteApotekerDialog extends ConsumerStatefulWidget {
  const InviteApotekerDialog({super.key});

  @override
  ConsumerState<InviteApotekerDialog> createState() =>
      _InviteApotekerDialogState();
}

class _InviteApotekerDialogState extends ConsumerState<InviteApotekerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref
          .read(userAdminControllerProvider)
          .inviteApoteker(_emailController.text);
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Undangan Apoteker dibuat.')),
      );
    } on AdminActionException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Undang Apoteker'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orang ini harus login dengan Google memakai email tersebut '
              'untuk pertama kalinya agar otomatis menjadi Apoteker.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              enabled: !_saving,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: Validators.email,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Email Google Apoteker',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Buat undangan'),
        ),
      ],
    );
  }
}