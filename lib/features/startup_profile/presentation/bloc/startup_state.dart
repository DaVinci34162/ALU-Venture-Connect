import 'package:equatable/equatable.dart';
import '../../domain/entities/startup.dart';

class StartupState extends Equatable {
  final Startup? myStartup;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const StartupState({
    this.myStartup,
    this.isLoading = true,
    this.isSubmitting = false,
    this.error,
  });

  StartupState copyWith({
    Startup? myStartup,
    bool clearStartup = false,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return StartupState(
      myStartup: clearStartup ? null : (myStartup ?? this.myStartup),
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  @override
  List<Object?> get props => [myStartup, isLoading, isSubmitting, error];
}