import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../startup_profile/presentation/pages/startup_profile_page.dart';
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
                final authState = context.watch<AuthBloc>().state;
                if (authState.user?.role != UserRole.startupAdmin) {
                  return const SizedBox.shrink();
                }
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
              },
            ),
          ],
        ),
        body: BlocBuilder<OpportunityBloc, OpportunityState>(
          builder: (context, state) {
            if (state.isLoadingFeed && state.opportunities.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.feedError != null) {
              return Center(child: Text('Something went wrong: ${state.feedError}'));
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
                  subtitle: Text('${opportunity.startupName} · ${opportunity.roleType}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}