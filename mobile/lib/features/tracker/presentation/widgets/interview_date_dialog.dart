import 'package:flutter/material.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../shared/widgets/nordic_button.dart';

class InterviewDateDialog {
  static Future<DateTime?> pick(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now.add(const Duration(days: 2)),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: NordicColors.navy,
              onPrimary: NordicColors.textInverse,
              surface: NordicColors.surfaceWhite,
              onSurface: NordicColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !context.mounted) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialDate != null
          ? TimeOfDay.fromDateTime(initialDate)
          : const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: NordicColors.navy,
              onPrimary: NordicColors.textInverse,
              surface: NordicColors.surfaceWhite,
              onSurface: NordicColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) {
      return DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        10,
        0,
      );
    }

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }
}
