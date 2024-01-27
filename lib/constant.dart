import 'package:flutter/material.dart';
import 'package:mdg_fixasset/WIdgets/CustomAlertDialog.dart';

//Show Modal
Future<Widget?> showModal(BuildContext context, Widget child,
    {String title = "",
    required List<Widget> topActions,
    required List<Widget> bottomActions,
    Color? backgroundColor = Colors.black45,
    AlignmentGeometry? align,
    bool dismissible = true}) async {
  return showDialog(
    barrierDismissible: dismissible,
    barrierColor: backgroundColor,
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog(
        title: title,
        align: align,
        contet: child,
        topActions: topActions,
        bottomActions: bottomActions,
      );
    },
  );
}
