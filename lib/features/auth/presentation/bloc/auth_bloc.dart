import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/watch_auth_state.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final WatchAuthState watchAuthState;
  final SignIn signIn;
  final SignUp signUp;
  final SignOut signOut;

  StreamSubscription? _authSubscription;

  AuthBloc({
    required this.watchAuthState,
    required this.signIn,
    required this.signUp,
    required this.signOut,
  }) : super(const AuthState()) {
    on<AuthStateWatchStarted>(_onWatchStarted);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthErrorOccurred>(_onAuthError);
  }

  void _onWatchStarted(AuthStateWatchStarted event, Emitter<AuthState> emit) {
    _authSubscription?.cancel();
    _authSubscription = watchAuthState().listen(
      (user) => add(AuthStateChanged(user)),
      onError: (error) => add(AuthErrorOccurred(error.toString())),
    );
  }

  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    if (event.user == null) {
      emit(state.copyWith(clearUser: true, isLoading: false));
    } else {
      emit(state.copyWith(user: event.user, isLoading: false));
    }
  }

  void _onAuthError(AuthErrorOccurred event, Emitter<AuthState> emit) {
    emit(state.copyWith(isLoading: false, error: event.message));
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      await signIn(email: event.email, password: event.password);
      // No need to manually set state.user here — the authStateChanges()
      // stream we're already subscribed to will fire AuthStateChanged
      // automatically once Firebase confirms the sign-in.
      emit(state.copyWith(isSubmitting: false));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      await signUp(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
      );
      emit(state.copyWith(isSubmitting: false));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    try {
      await signOut();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}