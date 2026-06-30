import 'package:equatable/equatable.dart';
import '../../domain/entities/app_user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once at app startup to begin listening to Firebase's auth state.
class AuthStateWatchStarted extends AuthEvent {
  const AuthStateWatchStarted();
}

/// Fired internally whenever Firebase's auth stream emits — never
/// dispatched directly from the UI.
class AuthStateChanged extends AuthEvent {
  final AppUser? user;
  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final UserRole role;
  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, role];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class AuthErrorOccurred extends AuthEvent {
  final String message;
  const AuthErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}