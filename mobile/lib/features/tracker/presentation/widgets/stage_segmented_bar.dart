import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/nordic_colors.dart';

class StageSegmentedBar extends StatelessWidget {
  final int selectedIndex;
  final List<String> stageLabels;
  final List<int> counts;
  final ValueChanged<int> onStageSelected;

  const StageSegmentedBar({
    super.key,
    required this.selectedIndex,
    required this.stageLabels,
    required this.counts,
    required this.onStageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stageLabels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          final count = counts[index];

          return GestureDetector(
            onTap: () => onStageSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? NordicColors.navy : NordicColors.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? NordicColors.navy : NordicColors.borderLight,
                  width: 1,
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
                  Text(
                    stageLabels[index],
                    style: GoogleFonts.notoSans(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? NordicColors.textInverse : NordicColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? NordicColors.yellow
                          : NordicColors.canvasLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "$count",
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? NordicColors.textDark : NordicColors.textMuted,
                      ),
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
