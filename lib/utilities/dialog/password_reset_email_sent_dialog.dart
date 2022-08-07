import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1/utilities/dialog/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password Reset',
    content: 'We have now send you a password link',
    optionsBuilder: () => {'OK': null},
  );
}
