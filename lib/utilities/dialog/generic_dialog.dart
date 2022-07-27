import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String,
        T?> //<T> insures that every string is unique so that two strings dont have the same title
    Function(); //user specifies a lsit of buttons and every button has to have a value

Future<T?> showGenericDialog<T>({
  //
  required BuildContext context,
  required String title, // title parameter
  required String content, // content parameter
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: options.keys.map((optionTitle) {
            final T value = options[optionTitle];
            return TextButton(
                onPressed: () {
                  // when pressed
                  if (value != null) {
                    // if value is not null
                    Navigator.of(context).pop(value); //
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(optionTitle));
          }).toList(),
        );
      });
}
