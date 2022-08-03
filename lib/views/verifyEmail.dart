import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_application_1/services/auth/bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Column(children: [
        const Text(
            "We've sent you an email verification. Please verify your email adress."),
        const Text(
            "If you haven't recieved an email verification yet, press the button below."),
        TextButton(
          onPressed: () {
            context.read<AuthBloc>().add(
                  const AuthEventSendEmailVerification(),
                );
          },
          child: const Text('Send email verification'),
        ),
        TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                    const AuthEventLogOut(),
                  );
            },
            child: const Text('Restart'))
      ]),
    );
  }
}
