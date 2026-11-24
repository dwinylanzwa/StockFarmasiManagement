import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../errors/auth_exception.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/password_field.dart';
import 'package:go_router/go_router.dart';
import '../navigation/route_paths.dart';

/// Registrasi mandiri. SENGAJA tidak ada pilihan role: semua akun yang
/// dibuat di sini berstatus Pengguna.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).register(
            nama: _namaController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil. Silakan login.'),
        ),
      );
      // SEMENTARA: di Tahap 1D diganti context.go('/login').
      // Navigator.of(context).pop();
        context.go(RoutePaths.login);
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e, st) {
      debugPrint('[Register] error: $e\n$st');
      if (mounted) {
        setState(() => _errorMessage = 'Terjadi kesalahan tak terduga.');
      }
    }finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
           appBar: AppBar(
        title: const Text('Daftar Akun'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RoutePaths.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _namaController,
                      enabled: !_isSubmitting,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: Validators.nama,
                      decoration: const InputDecoration(
                        labelText: 'Nama lengkap',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: Validators.email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _passwordController,
                      label: 'Password',
                      enabled: !_isSubmitting,
                      validator: Validators.newPassword,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Minimal 8 karakter, mengandung huruf dan angka.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _confirmController,
                      label: 'Konfirmasi password',
                      enabled: !_isSubmitting,
                      validator: Validators.confirmPassword(
                        () => _passwordController.text,
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Daftar'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => context.go(RoutePaths.login),
                      child: const Text('Sudah punya akun? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}