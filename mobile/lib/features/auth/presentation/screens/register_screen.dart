import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/nordic_button.dart';
import '../../../../shared/widgets/nordic_card.dart';
import '../../../../shared/widgets/nordic_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref.read(authControllerProvider.notifier).clearError();
    final success = await ref.read(authControllerProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );

    if (success && mounted) {
      context.go(RouteNames.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: NordicColors.canvasLight,
      appBar: AppBar(
        title: const Text("Create Account"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Join paniund", style: NordicTypography.h1),
                const SizedBox(height: 6),
                Text(
                  "Optimize your resume and organize job applications with Nordic clarity.",
                  style: NordicTypography.bodySmall,
                ),
                const SizedBox(height: 24),

                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: NordicColors.scoreLowBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: NordicColors.scoreLow.withOpacity(0.4)),
                    ),
                    child: Text(
                      authState.errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: NordicColors.scoreLow,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                NordicCard(
                  child: Column(
                    children: [
                      NordicTextField(
                        label: "Full Name",
                        hint: "Astrid Lindgren",
                        controller: _nameController,
                        prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: NordicColors.navy),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return "Name is required";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      NordicTextField(
                        label: "Email Address",
                        hint: "candidate@example.com",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, size: 20, color: NordicColors.navy),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return "Email is required";
                          if (!val.contains("@")) return "Enter a valid email address";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      NordicTextField(
                        label: "Password",
                        hint: "At least 8 characters",
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: NordicColors.navy),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 20,
                            color: NordicColors.textMuted,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Password is required";
                          if (val.length < 8) return "Password must be at least 8 characters";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      NordicTextField(
                        label: "Confirm Password",
                        hint: "Repeat password",
                        controller: _confirmPasswordController,
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20, color: NordicColors.navy),
                        validator: (val) {
                          if (val != _passwordController.text) return "Passwords do not match";
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      NordicButton(
                        label: "Create Candidate Account",
                        variant: NordicButtonVariant.primary,
                        fullWidth: true,
                        isLoading: authState.isLoading,
                        onPressed: _handleRegister,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: NordicTypography.bodySmall,
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: NordicColors.navy,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
