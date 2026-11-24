import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/auth_exception.dart';
import '../models/auth_state.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/password_field.dart';
import 'package:go_router/go_router.dart';
import '../navigation/route_paths.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Menjalankan aksi login dengan penanganan loading dan error yang sama.
  Future<void> _run(Future<void> Function() action) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await action();
      // Sukses: AuthState menjadi Authenticated dan layar diganti.
    } on SignInCancelledException {
      // Dibatalkan pengguna: tidak perlu menampilkan error.
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Terjadi kesalahan tak terduga.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitEmail() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return Future<void>.value();
    }
    return _run(
      () => ref.read(authProvider.notifier).signInWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          ),
    );
  }

  Future<void> _submitGoogle() {
    return _run(() => ref.read(authProvider.notifier).signInWithGoogle());
  }

  void _openRegister() => context.go(RoutePaths.register);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final infoMessage =
        authState is AuthUnauthenticated ? authState.message : null;

    return Scaffold(
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
                    Image.asset(
                        "assets/images/halobat_logo.png",
                      height: 80,
                      width: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'HalObat',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Masuk untuk melanjutkan',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    if (infoMessage != null && _errorMessage == null) ...[
                      _MessageBox(
                        message: infoMessage,
                        color: theme.colorScheme.secondaryContainer,
                        onColor: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_errorMessage != null) ...[
                      _MessageBox(
                        message: _errorMessage!,
                        color: theme.colorScheme.errorContainer,
                        onColor: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(height: 16),
                    ],
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
                      validator: Validators.loginPassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submitEmail(),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submitEmail,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('atau'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _submitGoogle,
                      icon: const Icon(Icons.account_circle_outlined),
                      label: const Text('Masuk dengan Google'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum punya akun?'),
                        TextButton(
                          onPressed: _isSubmitting ? null : _openRegister,
                          child: const Text('Daftar'),
                        ),
                      ],
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

class _MessageBox extends StatelessWidget {
  const _MessageBox({
    required this.message,
    required this.color,
    required this.onColor,
  });

  final String message;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: TextStyle(color: onColor)),
    );
  }
}