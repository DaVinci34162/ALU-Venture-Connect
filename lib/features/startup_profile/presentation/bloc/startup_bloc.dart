import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/startup.dart';
import '../../domain/usecases/create_startup.dart';
import '../../domain/usecases/watch_my_startup.dart';
import 'startup_event.dart';
import 'startup_state.dart';

class StartupBloc extends Bloc<StartupEvent, StartupState> {
  final WatchMyStartup watchMyStartup;
  final CreateStartup createStartup;
  StreamSubscription? _subscription;

  StartupBloc({required this.watchMyStartup, required this.createStartup})
      : super(const StartupState()) {
    on<WatchMyStartupStarted>(_onWatchStarted);
    on<MyStartupChanged>(_onChanged);
    on<CreateStartupRequested>(_onCreateRequested);
  }

  void _onWatchStarted(WatchMyStartupStarted event, Emitter<StartupState> emit) {
    _subscription?.cancel();
    _subscription = watchMyStartup(event.uid).listen(
          (startup) => add(MyStartupChanged(startup)),
    );
  }

  void _onChanged(MyStartupChanged event, Emitter<StartupState> emit) {
    if (event.startup == null) {
      emit(state.copyWith(clearStartup: true, isLoading: false));
    } else {
      emit(state.copyWith(myStartup: event.startup, isLoading: false));
    }
  }

  Future<void> _onCreateRequested(
      CreateStartupRequested event, Emitter<StartupState> emit) async {
    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      await createStartup(Startup(
        id: '',
        name: event.name,
        description: event.description,
        verified: false,
        createdBy: event.createdBy,
      ));
      emit(state.copyWith(isSubmitting: false));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}