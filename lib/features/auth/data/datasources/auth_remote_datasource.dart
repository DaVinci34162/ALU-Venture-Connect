import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/app_user.dart';
import '../models/app_user_model.dart';

class AuthRemoteDataSource {
  final fb_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSource(this.firebaseAuth, this.firestore);

  Stream<AppUser?> watchAuthState() {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final doc = await firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get()
            .timeout(const Duration(seconds: 15));

        if (!doc.exists) {
          throw Exception("User profile not found. Did you complete your registration?");
        }

        return AppUserModel.fromMap(firebaseUser.uid, doc.data()!);
      } catch (e) {
        debugPrint('AuthRemoteDataSource: Error fetching user profile: $e');
        throw Exception("Could not load your profile. Check your network connection and try again.");
      }
    });
  }

  Future<AppUserModel> signIn({required String email, required String password}) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final doc = await firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 15));

      if (!doc.exists) {
        throw Exception("User profile not found in database.");
      }

      return AppUserModel.fromMap(uid, doc.data()!);
    } catch (e) {
      debugPrint('AuthRemoteDataSource: SignIn Error: $e');
      rethrow;
    }
  }

  Future<AppUserModel> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final model = AppUserModel(uid: uid, email: email, name: name, role: role);
    await firestore.collection('users').doc(uid).set(model.toMap());
    return model;
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}