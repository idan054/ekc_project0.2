import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

import '../Widgets/myAppBar.dart';
import '../theme/constants.dart';
import 'A_loginPage.dart';
import 'flyerDm.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(
        // appBarTitle,
          'Your chats',
      ),

      body: StreamBuilder<List<types.Room>>(
        stream: FirebaseChatCore.instance.rooms(),
        initialData: const [],
        builder: (context, snapshot) {
          // print('RoomsPage data Snapshot: ${snapshot.data}');

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 20),
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, i) {
              User? authUser = FirebaseAuth.instance.currentUser;
              bool isUserInRoom = false;

              snapshot.data?[i].users.forEach((user) {
                print('authUser: ${authUser?.uid} | ${authUser?.displayName}');
                print('user: ${user.id} | ${user.firstName}');
                if (user.id == authUser?.uid) isUserInRoom = true;
              });

              var otherUser = snapshot.data?[i].users
                  .firstWhere((user) => user.id != authUser?.uid);

              if (isUserInRoom) {
                return Card(
                  child: ListTile(
                    style: ListTileStyle.list,
                    onTap: () async {
                      final room = await FirebaseChatCore.instance
                          .createRoom(otherUser!);
                      kPushNavigator(
                          context,
                          FlyerDm(
                            room: room,
                          ));
                    },
                    leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage('${otherUser?.imageUrl}')),
                    title: Text(
                      '${otherUser?.firstName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: otherUser?.lastSeen == null ? null :
                            Text('${otherUser?.lastSeen}'),
                    trailing:  IconButton(
                        onPressed: () async {
                          final room = await FirebaseChatCore.instance
                              .createRoom(otherUser!);

                          kPushNavigator(
                              context,
                              FlyerDm(
                                room: room,
                              ));
                        },
                        icon: Icon(Icons.send_rounded, color:
                        Colors.grey[500],
                          size: 20,)),
                  ),
                );
              } else {
                return const Center(child: Text('No rooms found..'));
              }
            },
          );
        },
      ),
    );
  }
}
