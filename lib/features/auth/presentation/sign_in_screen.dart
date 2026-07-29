import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _registering = false;
  bool _remember = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final repository = ref.read(authRepositoryProvider);
    await ref
        .read(authControllerProvider.notifier)
        .run(
          () => _registering
              ? repository.register(_email.text.trim(), _password.text)
              : repository.signInWithEmail(_email.text.trim(), _password.text),
          remember: _remember,
        );
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (state.hasError) _showError(state.error!);
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }

  Future<void> _resetPassword() async {
    await ref
        .read(authControllerProvider.notifier)
        .run(
          () => ref
              .read(authRepositoryProvider)
              .sendPasswordReset(_email.text.trim()),
        );
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      _showError(state.error!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('If the address exists, a reset email has been sent.'),
        ),
      );
    }
  }

  Future<void> _googleSignIn() async {
    await ref
        .read(authControllerProvider.notifier)
        .run(() => ref.read(authRepositoryProvider).signInWithGoogle());
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (state.hasError) _showError(state.error!);
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider).isLoading;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: 56,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _registering ? 'Create your account' : 'Welcome back',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'CampusConnect brings your community together.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Campus email',
                        ),
                        validator: (value) =>
                            value != null && value.contains('@')
                            ? null
                            : 'Enter a valid email address',
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        validator: (value) => value != null && value.length >= 6
                            ? null
                            : 'Use at least 6 characters',
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _remember,
                            onChanged: (value) =>
                                setState(() => _remember = value ?? false),
                          ),
                          const Text('Remember me'),
                          const Spacer(),
                          TextButton(
                            onPressed: loading ? null : _resetPassword,
                            child: const Text('Forgot password?'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: loading ? null : _submit,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _registering ? 'Create account' : 'Sign in',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: loading ? null : _googleSignIn,
                        icon: const Icon(Icons.g_mobiledata),
                        label: const Text('Continue with Google'),
                      ),
                      TextButton(
                        onPressed: loading
                            ? null
                            : () =>
                                  setState(() => _registering = !_registering),
                        child: Text(
                          _registering
                              ? 'Already have an account? Sign in'
                              : 'New here? Create an account',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
