import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1/utilities/dialog/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog(
      context: context,
      title: 'An error occured',
      content: text,
      optionsBuilder: () => {'OK': null});
}
