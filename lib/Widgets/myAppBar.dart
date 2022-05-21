import 'dart:async';

import 'package:ekc_project/theme/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import '../Pages/A_loginPage.dart';
import '../theme/colors.dart';

PreferredSizeWidget? myAppBar(context, String? title, {actions = const <Widget> []}) {
  return AppBar(
    // backgroundColor: neutral0,
    foregroundColor: Colors.black,
    backgroundColor: cGrey100,
    elevation: 2,
    leading: IconButton(
      icon: const Icon(Icons.keyboard_backspace_rounded, color: Colors.black),
      onPressed: () {
        title == 'יצירת פרופיל' ?
        kPushNavigator(context, const LoginPage())
        : Navigator.of(context).pop();
      },
    ),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        )),
    title: Align(
      alignment: Alignment.centerRight,
      child: Text(title ?? '',
      style: const TextStyle(
        color: neutral0,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),),
    ),
    actions: actions,
  );}
