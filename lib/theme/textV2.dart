import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'colors.dart';
import 'constants.dart';

// Split C_rilHome & A, B

// kTextTheme(context).caption
TextStyle defaultStyle() => const TextStyle();
TextTheme buildLightText () => TextTheme(
  headline1: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 24),
  headline2: defaultStyle(),
  headline3: defaultStyle(),
  headline4: defaultStyle(),
  headline5: defaultStyle(),
  headline6: defaultStyle(),


  subtitle1: TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
  ),
  subtitle2: defaultStyle(),

  bodyText2:
    const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 16),
  bodyText1:
    const TextStyle(
    color: Colors.black,
    fontSize: 16),

  caption: const TextStyle(
    color: neutral2,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    height: 1.5,
  ),
  overline: defaultStyle(),
  button: defaultStyle(),
);

// Shadow smallTxtShadow = Shadow(
//     color: Colors.black.withOpacity(0.76),
//     blurRadius: 4,
//     offset: const Offset(0, 1));