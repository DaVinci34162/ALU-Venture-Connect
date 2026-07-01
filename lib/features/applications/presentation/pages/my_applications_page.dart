import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/application_bloc.dart';
import '../bloc/application_event.dart';
import '../bloc/application_state.dart';

class MyApplicationsPage extends StatelessWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = context.read<AuthBloc>().state.user!;

    return BlocProvider(
      create: (_) => sl<ApplicationBloc>()
        ..add(WatchMyApplicationsStarted(authUser.uid)),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('My Applications')),
          body: BlocBuilder<ApplicationBloc, ApplicationState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null) {
                return Center(
                  child: Text(
                    'Error: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (state.applications.isEmpty) {
                return const Center(
                  child: Text("You haven't applied to any opportunities yet."),
                );
              }

              return ListView.builder(
                itemCount: state.applications.length,
                itemBuilder: (context, index) {
                  final app = state.applications[index];
                  return ListTile(
                    title: Text(app.opportunityTitle),
                    subtitle: Text(app.startupName),
                    trailing: _StatusChip(status: app.status.name),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'pending' => Colors.orange,
      'interview' => Colors.blue,
      'accepted' => Colors.green,
      'rejected' => Colors.red,
      _ => Colors.grey,
    };

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }
}