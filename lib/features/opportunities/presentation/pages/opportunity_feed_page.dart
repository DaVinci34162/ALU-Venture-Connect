import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../startup_profile/presentation/pages/startup_profile_page.dart';
import '../../../applications/presentation/pages/my_applications_page.dart';
import '../../../applications/presentation/pages/opportunity_detail_page.dart';
import 'create_opportunity_page.dart';
import '../bloc/opportunity_bloc.dart';
import '../bloc/opportunity_event.dart';
import '../bloc/opportunity_state.dart';

class OpportunityFeedPage extends StatelessWidget {
  const OpportunityFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OpportunityBloc>()..add(const WatchOpportunitiesStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Opportunities'),
          actions: [
            Builder(
              builder: (context) {
                final user = context.watch<AuthBloc>().state.user;

                if (user?.role == UserRole.student) {
                  return IconButton(
                    icon: const Icon(Icons.assignment),
                    tooltip: 'My Applications',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MyApplicationsPage(),
                        ),
                      );
                    },
                  );
                }

                if (user?.role == UserRole.startupAdmin) {
                  return IconButton(
                    icon: const Icon(Icons.business),
                    tooltip: 'My Startup',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const StartupProfilePage(),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: () {
                context.read<AuthBloc>().add(const SignOutRequested());
              },
            ),
          ],
        ),
        body: BlocBuilder<OpportunityBloc, OpportunityState>(
          builder: (context, state) {
            if (state.isLoadingFeed && state.opportunities.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading opportunities feed...'),
                  ],
                ),
              );
            }
            if (state.feedError != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.feedError}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<OpportunityBloc>().add(
                              const WatchOpportunitiesStarted());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state.opportunities.isEmpty) {
              return const Center(child: Text('No open opportunities yet.'));
            }
            return ListView.builder(
              itemCount: state.opportunities.length,
              itemBuilder: (context, index) {
                final opportunity = state.opportunities[index];
                return ListTile(
                  title: Text(opportunity.title),
                  subtitle: Text(
                      '${opportunity.startupName} · ${opportunity.roleType}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OpportunityDetailPage(
                          opportunity: opportunity,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final user = context.watch<AuthBloc>().state.user;
            if (user?.role != UserRole.startupAdmin) {
              return const SizedBox.shrink();
            }
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateOpportunityPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}