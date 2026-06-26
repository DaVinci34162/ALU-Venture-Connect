import 'package:equatable/equatable.dart';

enum UserRole { student, startupAdmin }

/// Same principle as Opportunity: no FirebaseAuth.User, no Firestore types
/// here. Just the plain shape of a user as far as the rest of the app
/// needs to know it.
class AppUser extends Equatable {
  final String uid;
  final String email;
  final String name;
  final UserRole role;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [uid, email, name, role];
}