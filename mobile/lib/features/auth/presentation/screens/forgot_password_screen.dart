import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/nordic_button.dart';
import '../../../../shared/widgets/nordic_card.dart';
import '../../../../shared/widgets/nordic_text_field.dart';
import '../../data/auth_repository.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _message = null;
    });

    final res = await ref.read(authRepositoryProvider).forgotPassword(email: email);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.success) {
          _message = res.data ?? 'Password reset link sent to your email.';
        } else {
          _error = res.error ?? 'Could not dispatch reset email.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Recover Account", style: NordicTypography.h1),
              const SizedBox(height: 6),
              Text(
                "Enter your registered email. We'll send instructions to reset your password.",
                style: NordicTypography.bodySmall,
              ),
              const SizedBox(height: 24),

              if (_message != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NordicColors.scoreHighBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: NordicColors.scoreHigh.withOpacity(0.3)),
                  ),
                  child: Text(
                    _message!,
                    style: const TextStyle(fontSize: 12, color: NordicColors.scoreHigh, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NordicColors.scoreLowBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: NordicColors.scoreLow.withOpacity(0.3)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(fontSize: 12, color: NordicColors.scoreLow, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              NordicCard(
                child: Column(
                  children: [
                    NordicTextField(
                      label: "Email Address",
                      hint: "candidate@example.com",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20, color: NordicColors.navy),
                    ),
                    const SizedBox(height: 20),
                    NordicButton(
                      label: "Send Reset Link",
                      variant: NordicButtonVariant.primary,
                      fullWidth: true,
                      isLoading: _isLoading,
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
