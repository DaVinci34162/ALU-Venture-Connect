import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../opportunities/domain/entities/opportunity.dart';
import '../bloc/application_bloc.dart';
import '../bloc/application_event.dart';
import '../bloc/application_state.dart';
import '../../domain/entities/application.dart';

class OpportunityDetailPage extends StatelessWidget {
  final Opportunity opportunity;
  const OpportunityDetailPage({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final authUser = context.read<AuthBloc>().state.user!;
    final isStudent = authUser.role == UserRole.student;

    return BlocProvider(
      create: (_) => sl<ApplicationBloc>(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(opportunity.title)),
          body: BlocConsumer<ApplicationBloc, ApplicationState>(
            listener: (context, state) {
              if (!state.isSubmitting && state.submitError == null &&
                  context.read<ApplicationBloc>().state.isSubmitting == false) {
                // Show success only when we just submitted
              }
              if (state.submitError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.submitError!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      opportunity.startupName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.deepPurple),
                    ),
                    const SizedBox(height: 4),
                    Text('Role: ${opportunity.roleType}'),
                    const SizedBox(height: 16),
                    Text(opportunity.description),
                    const SizedBox(height: 16),
                    if (opportunity.tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: opportunity.tags
                            .map((tag) => Chip(label: Text(tag)))
                            .toList(),
                      ),
                    const SizedBox(height: 32),
                    if (isStudent)
                      state.isSubmitting
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _onApply(context, authUser),
                          child: const Text('Apply'),
                        ),
                      ),
                    if (!isStudent)
                      const Text(
                        'Only students can apply to opportunities.',
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onApply(BuildContext context, AppUser authUser) {
    final application = Application(
      id: '',
      opportunityId: opportunity.id,
      opportunityTitle: opportunity.title,
      startupName: opportunity.startupName,
      studentId: authUser.uid,
      status: ApplicationStatus.pending,
      submittedAt: DateTime.now(),
    );

    context
        .read<ApplicationBloc>()
        .add(ApplicationSubmitted(application));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application submitted!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}