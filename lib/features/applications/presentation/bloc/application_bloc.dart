import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/apply_to_opportunity.dart';
import '../../domain/usecases/watch_my_applications.dart';
import 'application_event.dart';
import 'application_state.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final ApplyToOpportunity applyToOpportunity;
  final WatchMyApplications watchMyApplications;

  StreamSubscription? _applicationSubscription;

  ApplicationBloc({
    required this.applyToOpportunity,
    required this.watchMyApplications,
  }) : super(const ApplicationState()) {
    on<WatchMyApplicationsStarted>(_onWatchStarted);
    on<ApplicationSubmitted>(_onApplicationSubmitted);
    on<ApplicationErrorOccurred>(_onError);
  }

  void _onWatchStarted(
      WatchMyApplicationsStarted event, Emitter<ApplicationState> emit) {
    emit(state.copyWith(isLoading: true));
    _applicationSubscription?.cancel();
    _applicationSubscription = watchMyApplications(event.studentId).listen(
          (applications) {
        emit(state.copyWith(
          applications: applications,
          isLoading: false,
        ));
      },
      onError: (error) => add(ApplicationErrorOccurred(error.toString())),
    );
  }

  Future<void> _onApplicationSubmitted(
      ApplicationSubmitted event, Emitter<ApplicationState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearSubmitError: true));
    try {
      await applyToOpportunity(event.application);
      emit(state.copyWith(isSubmitting: false));
    } catch (e) {
      debugPrint('ApplicationBloc: submit error: $e');
      emit(state.copyWith(isSubmitting: false, submitError: e.toString()));
    }
  }

  void _onError(
      ApplicationErrorOccurred event, Emitter<ApplicationState> emit) {
    emit(state.copyWith(isLoading: false, error: event.message));
  }

  @override
  Future<void> close() {
    _applicationSubscription?.cancel();
    return super.close();
  }
}