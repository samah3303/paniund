import 'package:flutter/material.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/nordic_button.dart';
import '../../../../shared/widgets/nordic_text_field.dart';

class AddApplicationModal extends StatefulWidget {
  final Future<bool> Function({
    required String title,
    required String company,
    String? location,
    String? salary,
    String? sourceUrl,
    String status,
  }) onAdd;

  const AddApplicationModal({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddApplicationModal> createState() => _AddApplicationModalState();
}

class _AddApplicationModalState extends State<AddApplicationModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _urlController = TextEditingController();

  String _selectedStage = "applied";
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await widget.onAdd(
      title: _titleController.text.trim(),
      company: _companyController.text.trim(),
      location: _locationController.text.trim(),
      salary: _salaryController.text.trim(),
      sourceUrl: _urlController.text.trim(),
      status: _selectedStage,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      } else {
        setState(() => _error = "Failed to save application. Please try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: NordicColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: NordicColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text("Track New Opportunity", style: NordicTypography.h2),
                const SizedBox(height: 4),
                Text(
                  "Log a new role in your job search CRM.",
                  style: NordicTypography.bodySmall,
                ),
                const SizedBox(height: 18),

                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: NordicColors.scoreLowBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(fontSize: 12, color: NordicColors.scoreLow),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                NordicTextField(
                  label: "Job Title *",
                  hint: "e.g. Senior Mobile Engineer",
                  controller: _titleController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return "Title is required";
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                NordicTextField(
                  label: "Company *",
                  hint: "e.g. Spotify",
                  controller: _companyController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return "Company is required";
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: NordicTextField(
                        label: "Location",
                        hint: "e.g. Remote / Stockholm",
                        controller: _locationController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NordicTextField(
                        label: "Salary",
                        hint: "e.g. \$130k - \$150k",
                        controller: _salaryController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                NordicTextField(
                  label: "Listing URL",
                  hint: "https://linkedin.com/jobs/...",
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 14),

                // Target stage dropdown
                Text(
                  "Initial Stage",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: NordicColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedStage,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: NordicColors.borderLight),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "wishlist", child: Text("Wishlist / Saved")),
                    DropdownMenuItem(value: "applied", child: Text("Applied")),
                    DropdownMenuItem(value: "phone_screen", child: Text("Screening")),
                    DropdownMenuItem(value: "interview", child: Text("Interviewing")),
                    DropdownMenuItem(value: "offer", child: Text("Offer")),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStage = val);
                  },
                ),
                const SizedBox(height: 22),

                NordicButton(
                  label: "Add to Pipeline",
                  variant: NordicButtonVariant.primary,
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
