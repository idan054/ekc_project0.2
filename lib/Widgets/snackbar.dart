import 'package:flutter/material.dart';

import '../theme/constants.dart';
import '../theme/textV2.dart';

cleanSnack(BuildContext context,{
  required String text,
  Color? color,
  Color? textColor,
  int sec = 3,
  SnackBarAction? action,
    }){
  return
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color ?? Colors.grey[100]?.withOpacity(0.85),
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 80),
        content: Text(
          text,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: kTextTheme(context).bodyText2
                    ?.copyWith(color: textColor ?? Colors.black,)
        ),
        duration: Duration(seconds: sec),
        action: action,
        // action: SnackBarAction(
        //   label: 'סגור',
        //   onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),),
      )
  );
}