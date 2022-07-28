import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

@immutable //internals are never gonna be changed upon initialization
class AuthUser {
  final String id;
  //retrieve notes from specific authUser
  final String? email;
  //is the email verified or not
  final bool isEmailVerified;
  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(
          User
              user) => // We made a copy of the firebase user into our own AuthUser so we're not exposing firebase to our UI
      AuthUser(
          email: user.email!, //(!) makes it not optional
          isEmailVerified: user.emailVerified,
          id: user.uid);
}
