import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/startup_bloc.dart';
import '../bloc/startup_event.dart';
import '../bloc/startup_state.dart';

class StartupProfilePage extends StatefulWidget {
  const StartupProfilePage({super.key});

  @override
  State<StartupProfilePage> createState() => _StartupProfilePageState();
}

class _StartupProfilePageState extends State<StartupProfilePage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthBloc>().state.user!.uid;

    return BlocProvider(
      create: (context) => sl<StartupBloc>()..add(WatchMyStartupStarted(uid)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Startup Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: () {
                context.read<AuthBloc>().add(const SignOutRequested());
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: BlocBuilder<StartupBloc, StartupState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Already has a startup — show its status instead of a form.
            if (state.myStartup != null) {
              final startup = state.myStartup!;
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(startup.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(startup.description),
                    const SizedBox(height: 16),
                    Chip(
                      label: Text(startup.verified ? 'Verified' : 'Pending verification'),
                      backgroundColor: startup.verified ? Colors.green[100] : Colors.orange[100],
                    ),
                    if (!startup.verified)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'An ALU admin needs to verify your startup before you can post opportunities.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              );
            }

            // No startup yet — show the creation form.
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Startup name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(state.error!, style: const TextStyle(color: Colors.red)),
                    ),
                  if (state.isSubmitting)
                    const CircularProgressIndicator()
                  else
                    Builder(
                      builder: (context) {
                        return ElevatedButton(
                          onPressed: () {
                            context.read<StartupBloc>().add(
                                  CreateStartupRequested(
                                    name: _nameController.text.trim(),
                                    description: _descController.text.trim(),
                                    createdBy: uid,
                                  ),
                                );
                          },
                          child: const Text('Create startup profile'),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}