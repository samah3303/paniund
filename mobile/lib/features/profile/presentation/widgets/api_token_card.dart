import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/nordic_card.dart';

class ApiTokenCard extends StatelessWidget {
  final String? apiToken;
  final bool isRegenerating;
  final VoidCallback onRegenerate;

  const ApiTokenCard({
    super.key,
    required this.apiToken,
    required this.isRegenerating,
    required this.onRegenerate,
  });

  Future<void> _copy(BuildContext context) async {
    if (apiToken == null || apiToken!.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: apiToken!));
    HapticFeedback.lightImpact();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("API token copied to clipboard!"),
          backgroundColor: NordicColors.navy,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmRegenerate(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Regenerate API Token"),
        content: const Text(
          "Any existing browser extensions or scripts configured with this token will lose access until updated. Continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NordicColors.scoreLow,
              foregroundColor: NordicColors.textInverse,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onRegenerate();
            },
            child: const Text("Regenerate"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = apiToken ?? "pnd_••••••••••••••••••••••••••••••••";

    return NordicCard(
      leftAccentColor: NordicColors.navy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.vpn_key_outlined, size: 18, color: NordicColors.navy),
                  const SizedBox(width: 8),
                  Text("Extension & CLI Token", style: NordicTypography.h3),
                ],
              ),
              if (isRegenerating)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: NordicColors.navy),
                )
              else
                IconButton(
                  icon: const Icon(Icons.sync_rounded, size: 20, color: NordicColors.textMuted),
                  tooltip: "Regenerate Token",
                  onPressed: () => _confirmRegenerate(context),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Use this API token to authenticate browser extensions and command-line scripts.",
            style: NordicTypography.bodySmall,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: NordicColors.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    token,
                    style: GoogleFonts.jetbrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: NordicColors.navyDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _copy(context),
                  child: const Icon(Icons.copy_rounded, size: 18, color: NordicColors.navy),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
