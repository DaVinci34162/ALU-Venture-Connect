import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/application_bloc.dart';
import '../bloc/application_event.dart';
import '../bloc/application_state.dart';
import '../../domain/entities/application.dart';

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.read<AuthBloc>().state.user!;

    return BlocProvider(
      create: (_) => sl<ApplicationBloc>()
        ..add(WatchMyApplicationsStarted(authUser.uid)),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            title: const Text('My Applications'),
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'Interview'),
                Tab(text: 'Accepted'),
              ],
            ),
          ),
          body: BlocBuilder<ApplicationBloc, ApplicationState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.error}',
                        style:
                        const TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final all = state.applications;
              final pending = all
                  .where((a) => a.status == ApplicationStatus.pending)
                  .toList();
              final interview = all
                  .where((a) => a.status == ApplicationStatus.interview)
                  .toList();
              final accepted = all
                  .where((a) => a.status == ApplicationStatus.accepted)
                  .toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _ApplicationList(applications: all),
                  _ApplicationList(applications: pending),
                  _ApplicationList(applications: interview),
                  _ApplicationList(applications: accepted),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ApplicationList extends StatelessWidget {
  final List<Application> applications;
  const _ApplicationList({required this.applications});

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColors.textHint.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No applications here yet.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explore opportunities and apply.',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final app = applications[index];
        return _ApplicationCard(application: app);
      },
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final Application application;
  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(application.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.work_outline,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.opportunityTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    application.startupName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Applied ${_formatDate(application.submittedAt)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusConfig['color'].withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusConfig['color'].withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                statusConfig['label'],
                style: TextStyle(
                  color: statusConfig['color'],
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(ApplicationStatus status) {
    return switch (status) {
      ApplicationStatus.pending => {
        'color': AppColors.warning,
        'label': 'Pending',
      },
      ApplicationStatus.interview => {
        'color': AppColors.info,
        'label': 'Interview',
      },
      ApplicationStatus.accepted => {
        'color': AppColors.success,
        'label': 'Accepted',
      },
      ApplicationStatus.rejected => {
        'color': AppColors.error,
        'label': 'Rejected',
      },
    };
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}