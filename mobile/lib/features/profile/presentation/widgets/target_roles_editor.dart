import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/nordic_card.dart';

class TargetRolesEditor extends StatefulWidget {
  final List<String> initialRoles;
  final ValueChanged<List<String>> onSave;

  const TargetRolesEditor({
    super.key,
    required this.initialRoles,
    required this.onSave,
  });

  @override
  State<TargetRolesEditor> createState() => _TargetRolesEditorState();
}

class _TargetRolesEditorState extends State<TargetRolesEditor> {
  late List<String> _roles;
  final _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _roles = List.from(widget.initialRoles);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addRole() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty && !_roles.contains(text)) {
      setState(() {
        _roles.add(text);
        _inputController.clear();
      });
      widget.onSave(_roles);
    }
  }

  void _removeRole(String role) {
    setState(() {
      _roles.remove(role);
    });
    widget.onSave(_roles);
  }

  @override
  Widget build(BuildContext context) {
    return NordicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, size: 18, color: NordicColors.navy),
              const SizedBox(width: 8),
              Text("Target Roles & Specializations", style: NordicTypography.h3),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Roles you are actively targeting. Used for algorithmic job matching and ATS scoring.",
            style: NordicTypography.bodySmall,
          ),
          const SizedBox(height: 12),

          if (_roles.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _roles.map((role) {
                return Chip(
                  backgroundColor: NordicColors.yellowLight,
                  side: BorderSide(color: NordicColors.yellowHover.withOpacity(0.5)),
                  label: Text(
                    role,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: NordicColors.navyDark,
                    ),
                  ),
                  deleteIcon: const Icon(Icons.close_rounded, size: 14, color: NordicColors.navyDark),
                  onDeleted: () => _removeRole(role),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _inputController,
                    onSubmitted: (_) => _addRole(),
                    decoration: InputDecoration(
                      hintText: "Add role (e.g. Flutter Architect)",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: NordicColors.navy,
                  foregroundColor: NordicColors.textInverse,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _addRole,
                icon: const Icon(Icons.add_rounded, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
