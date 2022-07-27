import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/views/login_view.dart';
import 'package:flutter_application_1/views/notes/create_update_note_view.dart';
import 'package:flutter_application_1/views/register_view.dart';
import 'package:flutter_application_1/views/verifyEmail.dart';
import 'views/notes/notes_view.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NotesView(),
      verifyEmailRoute: (context) => const VerifyEmailView(),
      createUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        // upon firebase initializaiton being done successfully
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              //check for user
              if (user.isEmailVerified) {
                //check to see if email is verified
                return const NotesView(); // return NotesView
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator(
              color: Colors.amber,
            );
        }
      },
    );
  }
}
