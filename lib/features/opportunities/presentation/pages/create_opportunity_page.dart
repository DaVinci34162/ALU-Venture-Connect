import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../startup_profile/presentation/bloc/startup_bloc.dart';
import '../../../startup_profile/presentation/bloc/startup_event.dart';
import '../../../startup_profile/presentation/bloc/startup_state.dart';
import '../../domain/entities/opportunity.dart';
import '../bloc/opportunity_bloc.dart';
import '../bloc/opportunity_event.dart';
import '../bloc/opportunity_state.dart';

class CreateOpportunityPage extends StatefulWidget {
  const CreateOpportunityPage({super.key});

  @override
  State<CreateOpportunityPage> createState() => _CreateOpportunityPageState();
}

class _CreateOpportunityPageState extends State<CreateOpportunityPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _roleTypeController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _justSubmitted = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _roleTypeController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.read<AuthBloc>().state.user!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<StartupBloc>()
            ..add(WatchMyStartupStarted(authUser.uid)),
        ),
        BlocProvider(
          create: (_) => sl<OpportunityBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Post an Opportunity')),
          body: BlocBuilder<StartupBloc, StartupState>(
            builder: (context, startupState) {
              if (startupState.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final startup = startupState.myStartup;
              if (startup == null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Create your startup profile before posting.'),
                  ),
                );
              }

              if (!startup.verified) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Your startup is pending verification. You cannot post yet.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return BlocConsumer<OpportunityBloc, OpportunityState>(
                listener: (context, state) {
                  if (_justSubmitted &&
                      !state.isSubmitting &&
                      state.submitError == null) {
                    Navigator.of(context).pop();
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
                builder: (context, oppState) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: ListView(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration:
                          const InputDecoration(labelText: 'Title'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _descController,
                          decoration:
                          const InputDecoration(labelText: 'Description'),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _roleTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Role type (e.g. Flutter Developer)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _tagsController,
                          decoration: const InputDecoration(
                            labelText:
                            'Tags (comma-separated, e.g. Flutter, Remote)',
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (oppState.isSubmitting)
                          const Center(child: CircularProgressIndicator())
                        else
                          ElevatedButton(
                            onPressed: () => _onSubmit(
                              context,
                              startup.id,
                              startup.name,
                            ),
                            child: const Text('Post opportunity'),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _onSubmit(
      BuildContext context, String startupId, String startupName) {
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final opportunity = Opportunity(
      id: '',
      startupId: startupId,
      startupName: startupName,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      roleType: _roleTypeController.text.trim(),
      tags: tags,
      status: OpportunityStatus.open,
      createdAt: DateTime.now(),
    );

    _justSubmitted = true;
    context
        .read<OpportunityBloc>()
        .add(OpportunityCreateSubmitted(opportunity));
  }
}