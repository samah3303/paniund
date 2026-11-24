import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/nordic_colors.dart';

class CopyAndShareBar extends StatelessWidget {
  final String content;
  final String subject;
  final VoidCallback? onRegenerate;

  const CopyAndShareBar({
    super.key,
    required this.content,
    required this.subject,
    this.onRegenerate,
  });

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: content));
    HapticFeedback.lightImpact();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Copied to clipboard!"),
          backgroundColor: NordicColors.navy,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _share() async {
    HapticFeedback.lightImpact();
    await Share.share(content, subject: subject);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: NordicColors.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: NordicColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: NordicColors.navy),
            onPressed: () => _copy(context),
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text("Copy Text"),
          ),
          Container(width: 1, height: 24, color: NordicColors.borderLight),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: NordicColors.navy),
            onPressed: _share,
            icon: const Icon(Icons.share_outlined, size: 18),
            label: const Text("Share"),
          ),
          if (onRegenerate != null) ...[
            Container(width: 1, height: 24, color: NordicColors.borderLight),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: NordicColors.textMuted),
              onPressed: onRegenerate,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Retry"),
            ),
          ],
        ],
      ),
    );
  }
}
