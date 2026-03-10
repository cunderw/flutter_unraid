import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/auth/auth_cubit.dart';
import 'package:flutter_unraid/blocs/auth/auth_state.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/ui/widgets/inputs/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;

  @override
  void dispose() {
    _serverUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        _serverUrlController.text.trim(),
        _apiKeyController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Title
                  Icon(
                    Icons.dns_rounded,
                    size: 72,
                    color: AppColors.unraidOrange,
                  ),
                  AppSpacing.verticalLg,
                  Text(
                    'Funraid',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  AppSpacing.verticalSm,
                  Text(
                    'Connect to your Unraid server',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.verticalXxxxl,

                  // Server URL
                  AppTextField(
                    controller: _serverUrlController,
                    labelText: 'Server Address',
                    hintText: 'https://your-unraid-server',
                    prefixIcon: const Icon(Icons.link),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Server address is required';
                      }
                      final uri = Uri.tryParse(value.trim());
                      if (uri == null || !uri.hasScheme) {
                        return 'Enter a valid URL (e.g. https://192.168.1.100)';
                      }
                      return null;
                    },
                  ),
                  AppSpacing.verticalLg,

                  // API Key
                  AppTextField(
                    controller: _apiKeyController,
                    labelText: 'API Key',
                    hintText: 'Enter your API key',
                    prefixIcon: const Icon(Icons.key),
                    obscureText: _obscureApiKey,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureApiKey
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscureApiKey = !_obscureApiKey),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'API key is required';
                      }
                      return null;
                    },
                  ),
                  AppSpacing.verticalSm,
                  Text(
                    'Find your API key in Unraid Settings → Management Access → API.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.verticalXxxl,

                  // Login Button / State
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      // Navigation is handled by the parent App widget
                    },
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Connect'),
                            ),
                          ),
                          if (state is AuthError) ...[
                            AppSpacing.verticalLg,
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.stopped.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.stopped.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.stopped,
                                    size: 20,
                                  ),
                                  AppSpacing.horizontalSm,
                                  Expanded(
                                    child: Text(
                                      state.message,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppColors.stopped),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
