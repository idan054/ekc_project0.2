import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekc_project/Widgets/myAppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'dart:convert';
import 'package:ekc_project/Widgets/myDrawer.dart';
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

import 'flyerFirebaseChat.dart';

class AllUsersPage extends StatefulWidget {
  // bool isGoogleSign_user;
  GoogleSignInAccount? googleSign_user;

  // UserCredential? classic_currentUser;
  // final currentUser;
  //
  // AllUsersPage({this.currentUser, required this.isGoogleSign_user});
  AllUsersPage({this.googleSign_user});

  // const AllUsersPage({Key? key}) : super(key: key);

  @override
  _AllUsersPageState createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  // Create a user with an ID of UID if you don't use
// `FirebaseChatCore.instance.users()` stream
  void _createRoom(types.User otherUser, BuildContext context) async {
    final room = await FirebaseChatCore.instance.createRoom(otherUser);


    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FireBaseChatPage(
                room: room,
                currentUser: widget.googleSign_user,
                // user: _user,
              )),
    );

    // Navigate to the Chat screen
  }

  // Create a user with an ID of UID if you don't use
// `FirebaseChatCore.instance.users()` stream
  Future _createGroupRoom(BuildContext context, String name) async {
    final room =
        await FirebaseChatCore.instance.createGroupRoom(name: name, users: []);
    print(room.id);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FireBaseChatPage(
                room: room,
                currentUser: widget.googleSign_user,
                // user: _user,
              )),
    );

    // Navigate to the Chat screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 8.0),
            height: MediaQuery.of(context).size.height * 0.13,
            child: const DrawerHeader(child: Text("Projects")),
          ),
          StreamBuilder<List<types.Room>>(
            stream: FirebaseChatCore.instance.rooms(),
            initialData: const [],
            builder: (context, snapshot) {
              // print(snapshot.data);
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      onTap: () {
                        print(snapshot.data?[i].id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FireBaseChatPage(
                                room: snapshot.data![i],
                                currentUser: widget.googleSign_user,
                                // user: _user,
                              )),
                        );
                      },
                      title: Text('Project ${i + 1}'),
                      /*                leading: CachedNetworkImage(
                        imageUrl: "http://aarongorka.com/eks-orig.jpg",
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) {
                          // print(error);
                          return Icon(Icons.error);
                        },
                      )*/
                      // >> << \\
                      /*             Image(
                            width: 50,
                              image: AssetImage('Assets/eks-thumb.jpg'))
                              */
                    );
                  },
                ),
              );
              // ...
            },
          ),
          TextButton(
              onPressed: () async {
                await _createGroupRoom(context, 'new group');
              },
              child: const Text('Create New Project')),
        ],
      )),
      // appBar: myAppBar('Find someone to chat'),
      appBar: myAppBar('Hello ${widget.googleSign_user?.email}'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<types.User>>(
          stream: FirebaseChatCore.instance.users(),
          initialData: const [],
          builder: (context, snapshot) {
            var users = snapshot.data!;
            // print('AllUsers StreamBuilder: $users');
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, i) {
                final user = snapshot.data![i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    onTap: () {
                      // print(user);
                      _createRoom(user, context);
                    },
                    title: Text('${users[i].firstName}'),
                    trailing: IconButton(
                      onPressed: () {
                        print(user);
                        setState(() {
                          var _user = user;
                          _createRoom(_user, context);
                        });
                      },
                      icon: const Icon(
                        Icons.send,
                        color: dark,
                      ),
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: CachedNetworkImage(
                        imageUrl: '${users[i].imageUrl}',
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) {
                          // print(error);
                          return Icon(Icons.error);
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
