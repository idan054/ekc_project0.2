import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

import '../Widgets/myAppBar.dart';
import '../theme/colors.dart';
import '../theme/config.dart';
import '../theme/constants.dart';
import 'A_loginPage.dart';
import 'flyerDm.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({Key? key}) : super(key: key);

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {

  // Get Riltopia Team user.
  Future<types.User> getRtUser() async {
    // print('getRtUser()');
    types.User? _fetchedRtUser;
    if(config.app.riltopiaTeamUser != null){
      // print('!= null: ${config.app.riltopiaTeamUser?.toJson()}');
      _fetchedRtUser = config.app.riltopiaTeamUser;
    } else {
      // Todo add sharedPref Map to save api calls.
      fetchUser(
          'RtGHUgiIP5b5jkag1sYPo7tg0nD2', 'users')
          .then((rtUser) {
        _fetchedRtUser = types.User.fromJson(rtUser);

        print('rilTopiaTeamUser.toJson()');
        print(_fetchedRtUser?.toJson());
        config.app.riltopiaTeamUser = _fetchedRtUser;
      });
    }
      return _fetchedRtUser!;
  }

  @override
  void initState() {
    // getRtUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: myAppBar('Your chats',),
      body: StreamBuilder<List<types.Room>>(
        stream: FirebaseChatCore.instance.rooms(orderByUpdatedAt: true),
        initialData: const [],
        builder: (context, roomSnapshot) {
          // print('RoomsPage data Snapshot: ${roomSnapshot.data}');
          if (roomSnapshot.hasData /*&& snapshot.data!.isNotEmpty*/) {
            return Column(
              children: [
                const SizedBox(height: 10,),
                FutureBuilder<types.User>(
                    future: getRtUser(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData) {
                        var fetchedRtUser = snapshot.data;
                        return buildChatCard(
                          context,
                          otherUser: fetchedRtUser,
                          onTap: () async {
                            final room = await FirebaseChatCore.instance
                                .createRoom(fetchedRtUser!);
                            kPushNavigator(
                                context, FlyerDm(room: room));
                          },
                        );
                      } else {
                        return const Offstage();
                      }
                }),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    itemCount: roomSnapshot.data?.length ?? 0,
                    itemBuilder: (context, i) {
                      var room = roomSnapshot.data?[i];
                      User? authUser = FirebaseAuth.instance.currentUser;
                      types.User? otherUser = room?.users
                          .firstWhere((user) => user.id != authUser?.uid);

                      // [isUserInRoom] Probabby not needed because already
                      // in FirebaseChatCore.instance.rooms()
                      bool isUserInRoom = false;
                      // print('snapshot.data?[i].toJson');

                      room?.users.forEach((user) {
                        if (user.id == authUser?.uid) isUserInRoom = true;
                      });

                      if (isUserInRoom &&
                              otherUser != null &&
                              otherUser.id !=
                                  'RtGHUgiIP5b5jkag1sYPo7tg0nD2' // AKA Riltopia Team
                          ) {
                        return Column(
                          children: [
                            const SizedBox(height: 10),
                            buildChatCard(
                              context,
                              otherUser: otherUser,
                              room: room,
                              onTap: () async {
                                final room = await FirebaseChatCore.instance
                                    .createRoom(otherUser);
                                kPushNavigator(
                                    context,
                                    FlyerDm(
                                      room: room,
                                    ));
                              },
                            ),
                          ],
                        );
                      } else {
                        return const Offstage();
                      }
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(
                child: Text('התחל שיחה עם חברים חדשים \n דרך רילטופיה!',
              style: TextStyle(
                color: neutral2,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ));
          }
        },
      ),
    );
  }

  Widget buildChatCard(context,
      {types.User? otherUser, types.Room? room, VoidCallback? onTap}) {
    //~ Set unread count:
    String unreadKey = 'unreadCountFrom_'
        '${otherUser?.id.substring(0, 5)}';

    int unreadCount = room?.metadata?[unreadKey] ?? 0;
    // print('room metadata');
    // print(room?.metadata?.toString());

    bool normalUser = true;
    if(otherUser?.id == 'RtGHUgiIP5b5jkag1sYPo7tg0nD2') // AKA RilTopiaTeam
      {normalUser = false;}

    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        splashColor: Colors.black26,
        onTap: onTap,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey[200]!, width: 1.5),
            borderRadius: BorderRadius.circular(6.0),
          ),
          elevation: 0,
          shadowColor: Colors.black87,
          color: Colors.grey[100]!,
          child: Column(
            children: [
              const SizedBox(
                height: 2,
              ),
              Container(
                height: 80,
                padding: const EdgeInsets.only(right: 10),
                // color: Colors.primaries[Random().nextInt(Colors.primaries.length)].shade300,
                // color: cGrey100,
                child: Row(
                  children: [
                    Flexible(
                      child: ListTile(
                        dense: true,
                        visualDensity: VisualDensity.standard,
                        title: Row(
                          children: [
                            if(normalUser)
                            Builder(builder: (context) {
                              var age = otherUser?.metadata?['age']
                                  .toString()
                                  .substring(0, 2);
                              return Text(
                                /*' · '*/
                                '(${age ?? ''})',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    // color: Colors.primaries[Random().nextInt(Colors.primaries.length)].shade600,
                                    // color: Colors.black
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                                // style: bodyText1Format(context)
                              );
                            }),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Text(
                                '${otherUser?.firstName}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    // color: Colors.primaries[Random().nextInt(Colors.primaries.length)].shade600,
                                    // color: Colors.black
                                    color: Colors.grey[600]!,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                                // style: bodyText1Format(context)
                              ),
                            ),
                            // const Spacer(),
                            if (unreadCount != 0)
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Text('$unreadCount',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        // color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                            const SizedBox(
                              width: 15,
                            ),
                          ],
                        ),
                        subtitle:
                        normalUser ?
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                /*' · '*/
                                '${room?.metadata?['last_messageTxt'] ?? ""}',
                                textDirection: TextDirection.rtl,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    // color: Colors.primaries[Random().nextInt(Colors.primaries.length)].shade600,
                                    // color: Colors.black
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                                // style: bodyText1Format(context)
                              ),
                            ),
                          ],
                        ) :
                        const Text(' ספרו לנו מה אתם חושבים!', ),
                        contentPadding: EdgeInsets.zero,
                        leading: /* CircleAvatar(
                                          backgroundImage: NetworkImage('${otherUser?.imageUrl}'),
                                          // backgroundImage: NetworkImage('https://bit.ly/3l64LIk'),
                                        )*/
                            CircleAvatar(
                                backgroundColor: Colors.grey[400]!,
                                radius: 44 / 2,
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey[400]!,
                                  radius: 39 / 2,
                                  backgroundImage:
                                      NetworkImage('${otherUser?.imageUrl}'),
                                )),
                      ),
                    ),

                    Builder(
                        builder: (context) => Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  radius: 20,
                                  child: IconButton(
                                      onPressed: () async {
                                        final room = await FirebaseChatCore
                                            .instance
                                            .createRoom(otherUser!);

                                        kPushNavigator(
                                            context,
                                            FlyerDm(
                                              room: room,
                                            ));
                                      },
                                      icon: Icon(
                                        Icons.send_rounded,
                                        color: Colors.grey[500],
                                        size: 20,
                                      )),
                                ),
                              ),
                            ))

                    // const SizedBox(width: 10),
                    // const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
