import 'package:equatable/equatable.dart';
import '../../domain/entities/application.dart';

abstract class ApplicationEvent extends Equatable {
  const ApplicationEvent();

  @override
  List<Object?> get props => [];
}

class WatchMyApplicationsStarted extends ApplicationEvent {
  final String studentId;
  const WatchMyApplicationsStarted(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

/// Startup-admin side: watch every application submitted to my startup,
/// identified by the admin's own uid (denormalized on each application).
class WatchStartupApplicationsStarted extends ApplicationEvent {
  final String ownerUid;
  const WatchStartupApplicationsStarted(this.ownerUid);

  @override
  List<Object?> get props => [ownerUid];
}

class ApplicationSubmitted extends ApplicationEvent {
  final Application application;
  const ApplicationSubmitted(this.application);

  @override
  List<Object?> get props => [application];
}

class ApplicationErrorOccurred extends ApplicationEvent {
  final String message;
  const ApplicationErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}