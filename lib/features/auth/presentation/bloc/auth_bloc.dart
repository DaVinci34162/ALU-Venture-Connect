import 'dart:async';
import 'package:flutter/foundation.dart';
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
    debugPrint('AuthBloc: Watching auth state...');
    _authSubscription?.cancel();
    _authSubscription = watchAuthState().listen(
      (user) {
        debugPrint('AuthBloc: Auth state changed. User: ${user?.email}');
        add(AuthStateChanged(user));
      },
      onError: (error) {
        debugPrint('AuthBloc: Stream error: $error');
        add(AuthErrorOccurred(error.toString()));
      },
    );
  }

  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    debugPrint('AuthBloc: _onAuthStateChanged ENTERED. user=${event.user}');
    if (event.user == null) {
      emit(state.copyWith(clearUser: true, isLoading: false, isSubmitting: false));
    } else {
      emit(state.copyWith(user: event.user, isLoading: false, isSubmitting: false, clearError: true));
    }
    debugPrint('AuthBloc: _onAuthStateChanged EXITED. new isLoading=${state.isLoading}');
  }

  void _onAuthError(AuthErrorOccurred event, Emitter<AuthState> emit) {
    emit(state.copyWith(isLoading: false, isSubmitting: false, error: event.message));
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    debugPrint('AuthBloc: SignIn requested for ${event.email}');
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await signIn(email: event.email, password: event.password);
      debugPrint('AuthBloc: SignIn use case completed');
      // If after 3 seconds we still haven't switched pages (no AuthStateChanged),
      // we clear the spinner so the user can try again or see errors.
      await Future.delayed(const Duration(seconds: 3));
      if (state.isSubmitting) {
        emit(state.copyWith(isSubmitting: false));
      }
    } catch (e) {
      debugPrint('AuthBloc: SignIn use case failed: $e');
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await signUp(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
      );
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