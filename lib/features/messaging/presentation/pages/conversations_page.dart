import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../applications/domain/entities/application.dart';
import '../../../applications/presentation/bloc/application_bloc.dart';
import '../../../applications/presentation/bloc/application_event.dart';
import '../../../applications/presentation/bloc/application_state.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/watch_last_message.dart';
import 'chat_page.dart';

/// Lists every conversation the logged-in user is part of.
///
/// Conversations hang off applications, so:
///  - a STUDENT sees one row per application they submitted
///    (other party = the startup)
///  - a STARTUP ADMIN sees one row per application submitted to
///    their startup (other party = the applicant)
class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user!;
    final isStartupAdmin = user.role == UserRole.startupAdmin;

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
          'Messages',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: isStartupAdmin
          ? _StartupConversations(user: user)
          : _StudentConversations(user: user),
    );
  }
}

/// Student side: conversations come straight from my own applications.
class _StudentConversations extends StatelessWidget {
  final AppUser user;
  const _StudentConversations({required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ApplicationBloc>()
        ..add(WatchMyApplicationsStarted(user.uid)),
      child: const _ConversationList(otherPartyIsStartup: true),
    );
  }
}

/// Startup-admin side: applications carry the owner's uid directly,
/// so we can query by it without resolving the startup first.
class _StartupConversations extends StatelessWidget {
  final AppUser user;
  const _StartupConversations({required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ApplicationBloc>()
        ..add(WatchStartupApplicationsStarted(user.uid)),
      child: const _ConversationList(otherPartyIsStartup: false),
    );
  }
}

class _ConversationList extends StatelessWidget {
  /// true when the viewer is a student (other party = startup),
  /// false when the viewer is a startup admin (other party = applicant).
  final bool otherPartyIsStartup;
  const _ConversationList({required this.otherPartyIsStartup});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApplicationBloc, ApplicationState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          return _EmptyState(
            title: 'Could not load conversations.',
            subtitle: state.error!,
          );
        }
        if (state.applications.isEmpty) {
          return _EmptyState(
            title: 'No conversations yet.',
            subtitle: otherPartyIsStartup
                ? 'Apply to an opportunity to start chatting with a startup.'
                : 'Conversations appear here when students apply to your opportunities.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.applications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final app = state.applications[index];
            final otherPartyName = otherPartyIsStartup
                ? app.startupName
                : (app.applicantName.isNotEmpty ? app.applicantName : 'Applicant');
            return _ConversationTile(
              application: app,
              otherPartyName: otherPartyName,
            );
          },
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Application application;
  final String otherPartyName;

  const _ConversationTile({
    required this.application,
    required this.otherPartyName,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatPage(
              application: application,
              otherPartyName: otherPartyName,
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    otherPartyName.isNotEmpty
                        ? otherPartyName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            otherPartyName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        _LastMessageTime(applicationId: application.id),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      application.opportunityTitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _LastMessagePreview(applicationId: application.id),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Live preview of the newest message in this conversation.
class _LastMessagePreview extends StatelessWidget {
  final String applicationId;
  const _LastMessagePreview({required this.applicationId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Message?>(
      stream: sl<WatchLastMessage>()(applicationId),
      builder: (context, snapshot) {
        final msg = snapshot.data;
        final text = msg == null
            ? 'No messages yet — say hello!'
            : '${msg.senderName}: ${msg.text}';
        return Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: msg == null ? AppColors.textHint : AppColors.textSecondary,
            fontStyle: msg == null ? FontStyle.italic : FontStyle.normal,
          ),
        );
      },
    );
  }
}

class _LastMessageTime extends StatelessWidget {
  final String applicationId;
  const _LastMessageTime({required this.applicationId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Message?>(
      stream: sl<WatchLastMessage>()(applicationId),
      builder: (context, snapshot) {
        final msg = snapshot.data;
        if (msg == null) return const SizedBox.shrink();
        return Text(
          _format(msg.sentAt),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textHint,
          ),
        );
      },
    );
  }

  String _format(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (isToday) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    return '${dt.day}/${dt.month}';
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: AppColors.textHint.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}