import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import '../theme/colors.dart';

PreferredSizeWidget? myAppBar(context, String? title, {bool stf = false, actions = const <Widget> []}) {
  return AppBar(
    // backgroundColor: neutral0,
    foregroundColor: Colors.black,
    backgroundColor: cGrey100,
    elevation: 2,
    leading: IconButton(
      icon: const Icon(Icons.keyboard_backspace_rounded, color: Colors.black),
      onPressed: () => Navigator.of(context).pop(),
    ),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        )),
    title: Text(title ?? '',
    style: const TextStyle(
      color: neutral0,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      height: 1.2,
    ),),
    actions: actions,
  );}
