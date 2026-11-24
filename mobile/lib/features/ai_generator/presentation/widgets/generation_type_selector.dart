import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../data/models/generation_request_model.dart';

class GenerationTypeSelector extends StatelessWidget {
  final GenerationType selectedType;
  final ValueChanged<GenerationType> onSelect;

  const GenerationTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelect,
  });

  static const List<({GenerationType type, String label, IconData icon})> types = [
    (type: GenerationType.coverLetter, label: "Cover Letter", icon: Icons.description_outlined),
    (type: GenerationType.bulletUpgrade, label: "Bullet Rewriter", icon: Icons.auto_fix_high_rounded),
    (type: GenerationType.linkedinOutreach, label: "LinkedIn", icon: Icons.person_add_alt_1_outlined),
    (type: GenerationType.followupEmail, label: "Follow-Up", icon: Icons.mark_email_read_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = types[index];
          final isSelected = selectedType == item.type;

          return GestureDetector(
            onTap: () => onSelect(item.type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? NordicColors.navy : NordicColors.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? NordicColors.navy : NordicColors.borderLight,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: NordicColors.navy.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 15,
                    color: isSelected ? NordicColors.yellow : NordicColors.navy,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.label,
                    style: GoogleFonts.notoSans(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? NordicColors.textInverse : NordicColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
