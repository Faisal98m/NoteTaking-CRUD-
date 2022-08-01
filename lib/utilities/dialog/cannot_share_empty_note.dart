import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1/utilities/dialog/generic_dialog.dart';

Future<void> showCannotShareEmptyNotesDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Sharing',
    content: 'You cannot share an empty note',
    optionsBuilder: () => {'OK': null},
  );
}
