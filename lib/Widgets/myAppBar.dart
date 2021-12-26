import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

PreferredSizeWidget? myAppBar(String? title, {actions = const <Widget> []}) {
  return AppBar(
    backgroundColor: neutral0,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        )),
    title: Text(title ?? ''),
    actions: actions,
  );}
