import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/nordic_button.dart';
import '../../../../shared/widgets/nordic_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../resume/presentation/controllers/resume_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/account_info_tile.dart';
import '../widgets/api_token_card.dart';
import '../widgets/target_roles_editor.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to end your mobile session?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NordicColors.navy,
              foregroundColor: NordicColors.textInverse,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authControllerProvider.notifier).logout();
            },
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final resumeState = ref.watch(resumeControllerProvider);

    final user = authState.user;
    final profile = profileState.profile ?? resumeState.profile;
    final atsScore = resumeState.audit?.overallScore ?? profile?.atsScore;

    return Scaffold(
      backgroundColor: NordicColors.canvasLight,
      appBar: AppBar(
        title: const Text("Candidate Profile & Settings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Profile",
            onPressed: () {
              ref.read(profileControllerProvider.notifier).load();
              ref.read(resumeControllerProvider.notifier).loadProfile();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Account Info Tile
            AccountInfoTile(
              name: user?.name ?? profile?.name ?? "Candidate",
              email: user?.email ?? profile?.email ?? "",
              atsScore: atsScore,
            ),
            const SizedBox(height: 16),

            // 2. Target Roles Editor
            TargetRolesEditor(
              initialRoles: profile?.targetRoles ?? [],
              onSave: (roles) {
                ref.read(profileControllerProvider.notifier).updateRoles(roles);
              },
            ),
            const SizedBox(height: 16),

            // 3. API Token Card
            ApiTokenCard(
              apiToken: profileState.apiToken,
              isRegenerating: profileState.isRegeneratingToken,
              onRegenerate: () {
                ref.read(profileControllerProvider.notifier).regenerateToken();
              },
            ),
            const SizedBox(height: 16),

            // 4. Resume Management
            Text("Resume & ATS Settings", style: NordicTypography.h3),
            const SizedBox(height: 8),
            NordicCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.analytics_outlined, color: NordicColors.navy),
                    title: const Text("ATS Audit & Score Breakdown"),
                    subtitle: Text(
                      profile?.resumeFileName != null ? profile!.resumeFileName! : "Upload to calculate score",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(RouteNames.resumeAudit),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.cloud_upload_outlined, color: NordicColors.navy),
                    title: const Text("Upload Updated Resume"),
                    subtitle: const Text("PDF, DOCX, DOC, TXT (Max 10MB)", style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(RouteNames.resumeUpload),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5. Sign Out Button
            NordicButton(
              label: "Sign Out",
              icon: const Icon(Icons.logout_rounded, size: 18),
              variant: NordicButtonVariant.outline,
              fullWidth: true,
              onPressed: () => _confirmLogout(context, ref),
            ),
            const SizedBox(height: 20),

            // App Footer
            Center(
              child: Text(
                "paniund Mobile • v1.0.0+1 • Nordic Yellow Design System",
                style: GoogleFonts.jetbrainsMono(
                  fontSize: 10,
                  color: NordicColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
