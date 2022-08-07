import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/services/auth/auth_user.dart';

abstract class AuthProvider {
  //protocol not logic
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  AuthUser? get currentUser;
  Future<AuthUser> logIn({
    // log in with user
    required String email,
    required String password,
  });
  Future<AuthUser> createUser({
    //creates user
    required String email,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordReset({required String email});
}
