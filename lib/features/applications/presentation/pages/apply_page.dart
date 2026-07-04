import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../opportunities/domain/entities/opportunity.dart';
import '../../domain/entities/application.dart';
import '../bloc/application_bloc.dart';
import '../bloc/application_event.dart';
import '../bloc/application_state.dart';

class ApplyPage extends StatelessWidget {
  final Opportunity opportunity;
  const ApplyPage({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    // Read the signed-in user so the applicant name comes from the account.
    final user = context.read<AuthBloc>().state.user!;
    return BlocProvider(
      create: (_) => sl<ApplicationBloc>(),
      child: _ApplyView(opportunity: opportunity, user: user),
    );
  }
}

class _ApplyView extends StatefulWidget {
  final Opportunity opportunity;
  final AppUser user;
  const _ApplyView({required this.opportunity, required this.user});

  @override
  State<_ApplyView> createState() => _ApplyViewState();
}

class _ApplyViewState extends State<_ApplyView> {
  final _formKey = GlobalKey<FormState>();
  final _roleController = TextEditingController();
  final _coverController = TextEditingController();
  final _linkController = TextEditingController();

  // True only after THIS page fires a submit, so the listener knows to
  // close the form when the bloc finishes.
  bool _submitting = false;

  @override
  void dispose() {
    _roleController.dispose();
    _coverController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final application = Application(
      id: '',
      opportunityId: widget.opportunity.id,
      opportunityTitle: widget.opportunity.title,
      startupName: widget.opportunity.startupName,
      studentId: widget.user.uid,
      // Name comes from the account, not a typed field — it can't be faked
      // and always matches the real applicant.
      applicantName: widget.user.name,
      applicantRole: _roleController.text.trim(),
      coverMessage: _coverController.text.trim(),
      portfolioLink: _linkController.text.trim(),
      status: ApplicationStatus.pending,
      submittedAt: DateTime.now(),
    );

    setState(() => _submitting = true);
    context.read<ApplicationBloc>().add(ApplicationSubmitted(application));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Apply',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocConsumer<ApplicationBloc, ApplicationState>(
        listener: (context, state) {
          if (state.submitError != null) {
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.submitError!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (_submitting && !state.isSubmitting) {
            // Submission finished cleanly — close the form. The detail
            // page's stream will show the "Application submitted" state.
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Applying-to summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Applying to',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.opportunity.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          widget.opportunity.startupName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Applicant name (read-only, from account)
                  _Label('Your name'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      widget.user.name,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _Label('Your role / skills'),
                  _field(
                    controller: _roleController,
                    hint: 'e.g. 2nd-year SE student, Flutter & Firebase',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please add your role or skills'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _Label('Why are you a good fit?'),
                  _field(
                    controller: _coverController,
                    hint: 'A short message to the startup...',
                    maxLines: 5,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please write a short message'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _Label('Portfolio / CV link'),
                  _field(
                    controller: _linkController,
                    hint: 'https://...',
                    keyboardType: TextInputType.url,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please add a link';
                      }
                      if (!v.trim().startsWith('http')) {
                        return 'Enter a valid URL (starting with http)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                      state.isSubmitting ? null : () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: state.isSubmitting
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text(
                        'Submit Application',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
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

  Widget _field({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}