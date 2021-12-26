import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import '../myUtil.dart';

class MyAlertDialog extends StatelessWidget {
  final String? title;
  final VoidCallback? onPressed;
  final TextEditingController? projectNameController;
  final List<Widget> actions;

  MyAlertDialog({
    this.title,
    this.onPressed,
    this.projectNameController,
    this.actions = const [],
  });
  //  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: eckDarkBlue,
      // backgroundColor: Colors.blueGrey[700],
      title: TextField(
        controller: projectNameController,
        decoration: const InputDecoration(
          hintText: 'New Project Name',
          hintStyle: TextStyle(color: eckLightBlue),
          fillColor: eckBlue,
        filled: true,
            border: OutlineInputBorder(
              // width: 0.0 produces a thin "hairline" border
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                borderSide: BorderSide.none,
            )        ),
      ),
      actions: actions,
      content:ElevatedButton(
        onPressed: onPressed,
        child:       const Text(
            'Add image',
            style: TextStyle(color: Colors.white)
        ),
      ),

    );
  }
}
