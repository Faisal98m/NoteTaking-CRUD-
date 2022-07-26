import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

@immutable //internals are never gonna be changed upon initialization
class AuthUser {
  //retrieve notes from specific authUser
  final String? email;

  //is the email verified or not
  final bool isEmailVerified;
  const AuthUser({
    required this.email,
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(
          User
              user) => // We made a copy of the firebase user into our own AuthUser so we're not exposing firebase to our UI
      AuthUser(
        email: user.email,
        isEmailVerified: user.emailVerified,
      );
}
