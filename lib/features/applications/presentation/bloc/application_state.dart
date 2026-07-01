import 'package:equatable/equatable.dart';
import '../../domain/entities/application.dart';

class ApplicationState extends Equatable {
  final List<Application> applications;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? submitError;

  const ApplicationState({
    this.applications = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.submitError,
  });

  ApplicationState copyWith({
    List<Application>? applications,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? submitError,
    bool clearSubmitError = false,
  }) {
    return ApplicationState(
      applications: applications ?? this.applications,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }

  @override
  List<Object?> get props =>
      [applications, isLoading, isSubmitting, error, submitError];
}