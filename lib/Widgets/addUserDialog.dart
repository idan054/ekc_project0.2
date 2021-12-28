import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import '../myUtil.dart';

class AddUserDialog extends StatelessWidget {
  final List<String>? currentUsers;
  final TextEditingController? contentFieldController;
  final VoidCallback? onPressed;
  final List<Widget> actions;

  AddUserDialog({
    this.currentUsers,
    this.onPressed,
    this.contentFieldController,
    this.actions = const [],
  });

  //  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Widget _myTextField({controller, name}) {
      return TextField(
        controller: controller,
        style: const TextStyle(color: eckLightBlue),
        decoration: InputDecoration(
            hintText: name,
            hintStyle: const TextStyle(color: eckLightBlue),
            fillColor: eckBlue,
            filled: true,
            border: const OutlineInputBorder(
              // width: 0.0 produces a thin "hairline" border
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              borderSide: BorderSide.none,
            )),
      );
    }

    return AlertDialog(
      backgroundColor: eckDarkBlue,
      // backgroundColor: Colors.blueGrey[700],
      title: Column(
        children: [
          _myTextField(
              controller: contentFieldController,
              name: 'Insert user email'),
        ],
      ),
      actions: actions,
      content: Container(
        height: 96,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(currentUsers.toString().replaceAll('[', '').replaceAll(']', ''),
              style: const TextStyle(color: eckLightBlue),),
              const SizedBox(height: 10,),

              ElevatedButton(
                onPressed: onPressed,
                child: const Text('Add user', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),

    );
  }
}
