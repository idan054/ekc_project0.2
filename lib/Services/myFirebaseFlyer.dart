import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekc_project/Pages/flyerChat.dart';
import 'package:ekc_project/Widgets/myAlertDialog.dart';
import 'package:ekc_project/Widgets/myAppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'dart:convert';
import 'package:ekc_project/Widgets/myDrawers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:uuid/uuid.dart';

// Create a user with an ID of UID if you don't use
// `FirebaseChatCore.instance.users()` stream
Future createGroupRoom(BuildContext context, String name, GoogleSignInAccount currentUser) async {
  final room =
  await FirebaseChatCore.instance.createGroupRoom(name: name, users: []);
  print(room.id);
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => FireBaseChatPage(
          room: room,
          currentUser: currentUser,
          // user: _user,
        )),
  );

  // Navigate to the Chat screen
}