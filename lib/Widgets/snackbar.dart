import 'package:flutter/material.dart';

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
          style: TextStyle(
              color: textColor ?? Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: sec),
        action: action,
        // action: SnackBarAction(
        //   label: 'סגור',
        //   onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),),
      )
  );
}