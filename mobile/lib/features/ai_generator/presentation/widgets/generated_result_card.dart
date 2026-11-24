import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/nordic_card.dart';
import 'copy_and_share_bar.dart';

class GeneratedResultCard extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback? onRegenerate;

  const GeneratedResultCard({
    super.key,
    required this.title,
    required this.content,
    this.onRegenerate,
  });

  int get wordCount => content.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CopyAndShareBar(
          content: content,
          subject: title,
          onRegenerate: onRegenerate,
        ),
        const SizedBox(height: 12),
        NordicCard(
          leftAccentColor: NordicColors.yellow,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Generated Narrative", style: NordicTypography.h3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: NordicColors.yellowLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "$wordCount words",
                      style: GoogleFonts.jetbrainsMono(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: NordicColors.navyDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              SelectableText(
                content,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  height: 1.6,
                  color: NordicColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
