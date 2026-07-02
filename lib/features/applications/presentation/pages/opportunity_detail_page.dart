import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../opportunities/domain/entities/opportunity.dart';
import '../bloc/application_bloc.dart';
import '../bloc/application_event.dart';
import '../bloc/application_state.dart';
import '../../domain/entities/application.dart';

class OpportunityDetailPage extends StatefulWidget {
  final Opportunity opportunity;
  const OpportunityDetailPage({super.key, required this.opportunity});

  @override
  State<OpportunityDetailPage> createState() => _OpportunityDetailPageState();
}

class _OpportunityDetailPageState extends State<OpportunityDetailPage> {
  bool _applied = false;

  @override
  Widget build(BuildContext context) {
    final authUser = context.read<AuthBloc>().state.user!;
    final isStudent = authUser.role == UserRole.student;

    return BlocProvider(
      create: (_) => sl<ApplicationBloc>(),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
          body: BlocConsumer<ApplicationBloc, ApplicationState>(
            listener: (context, state) {
              if (state.submitError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.submitError!),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
              if (!state.isSubmitting && state.submitError == null && _applied) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Application submitted successfully!'),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  // ── Hero header ──
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    backgroundColor: AppColors.primary,
                    iconTheme:
                    const IconThemeData(color: Colors.white),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.cardGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              20, 80, 20, 20),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Startup badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: 0.2),
                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.opportunity.startupName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.opportunity.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.opportunity.roleType,
                                style: TextStyle(
                                  color: Colors.white
                                      .withValues(alpha: 0.85),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Content ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tags
                          if (widget.opportunity.tags.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.opportunity.tags
                                  .map((tag) => Container(
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                  BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                                  .toList(),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // About section
                          _SectionHeader(title: 'About this role'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFE5E7EB)),
                            ),
                            child: Text(
                              widget.opportunity.description.isEmpty
                                  ? 'No description provided.'
                                  : widget.opportunity.description,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Details section
                          _SectionHeader(title: 'Details'),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFE5E7EB)),
                            ),
                            child: Column(
                              children: [
                                _DetailRow(
                                  icon: Icons.business_outlined,
                                  label: 'Startup',
                                  value:
                                  widget.opportunity.startupName,
                                ),
                                const Divider(height: 1,
                                    indent: 56),
                                _DetailRow(
                                  icon: Icons.work_outline,
                                  label: 'Role Type',
                                  value: widget.opportunity.roleType,
                                ),
                                const Divider(height: 1,
                                    indent: 56),
                                _DetailRow(
                                  icon: Icons.circle,
                                  label: 'Status',
                                  value: widget.opportunity.status
                                      .name ==
                                      'open'
                                      ? 'Open for applications'
                                      : 'Closed',
                                  valueColor:
                                  widget.opportunity.status.name ==
                                      'open'
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Apply section
                          if (isStudent) ...[
                            if (_applied)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.success
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                  BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.success
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: AppColors.success),
                                    SizedBox(width: 8),
                                    Text(
                                      'Application submitted!',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              state.isSubmitting
                                  ? const Center(
                                  child:
                                  CircularProgressIndicator())
                                  : SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _onApply(context, authUser),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Apply Now',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],

                          if (!isStudent)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0xFFE5E7EB)),
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.info_outline,
                                      color: AppColors.textHint,
                                      size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Only students can apply.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onApply(BuildContext context, AppUser authUser) {
    setState(() => _applied = true);

    final application = Application(
      id: '',
      opportunityId: widget.opportunity.id,
      opportunityTitle: widget.opportunity.title,
      startupName: widget.opportunity.startupName,
      studentId: authUser.uid,
      status: ApplicationStatus.pending,
      submittedAt: DateTime.now(),
    );

    context
        .read<ApplicationBloc>()
        .add(ApplicationSubmitted(application));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}