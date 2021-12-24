// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MainPage extends StatefulWidget {
  GoogleSignInAccount? user;

  MainPage({this.user});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController? _msgController = TextEditingController();

  List projectNum = [1, 2]; // For hamburger Menu

  // Dict Sample
  // Map 1 = Chats as key
  // Map 2 = meUser / guestUser as key
  // Map 3 = msgs as key (Not available cuz emailUser Key)
  // Map<String, Map<String, Map<String, Map>>> chatsDict = {
  Map<String, Map<String, Map>> chatsDict_Mock = {
    'project 1 chat': {
      'currentUser': {
        'emailUser': 'idanbit80@gmail.com',
        'userId': '325245355'
      },
      'guestUser': {'emailUser': 'oleg@gmail.com', 'userId': '047826484'},
      'msgs': {
        1: {
          'from': 'idanbit80@gmail.com',
          'to': 'oleg@gmail.com',
          'msgChatIndex': 1,
          'msgText': 'I have news',
          'timeStamp': 12.00,
          'uniqueKey': 'XXX'
        },
        2: {
          'from': 'oleg@gmail.com',
          'to': 'idanbit80@gmail.com',
          'msgChatIndex': 2,
          'msgText': 'What is it?',
          'timeStamp': 12.10,
          'uniqueKey': 'YYY'
        },
        3: {
          'from': 'idanbit80@gmail.com',
          'to': 'oleg@gmail.com',
          'msgChatIndex': 3,
          'msgText': 'Chat mock works.',
          'timeStamp': 12.50,
          'uniqueKey': 'ZZZ'
        }
      },
    }
  };

// ValueNotifier<List> _counter = ValueNotifier<List>([1,2,3,4,5,6,7]);

  @override
  void initState() {
    print('\ninit Coming!');
    // print(chatsDict[ 'project 1 chat']?['msgs']);
    // print(chatsDict);
    print('init Done \n');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount? currentUser = widget.user;
    String? currentUser_email = currentUser?.email;
    QueryDocumentSnapshot? fireBase_Chat;

    String? guestUser_email;
    return Scaffold(
        appBar: AppBar(
          title: Text('Hello ${widget.user?.email}'),
        ),
        drawer:
        Drawer(
            child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 8.0),
              height: MediaQuery.of(context).size.height * 0.13,
              child: DrawerHeader(child: Text("Projects")),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: projectNum.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    title: Text('Project ${projectNum[i]}'),
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
            ),
            TextButton(
                onPressed: () {
                  setState(() {
                    projectNum.add(projectNum.length + 1);
                    print(projectNum);
                  });
                },
                child: Text('Create New Project'))
          ],
        )),
        body: FutureBuilder<QuerySnapshot>(
            // body: FutureBuilder(
            // body: FutureBuilder<UserPoints>(
            future: FirebaseFirestore.instance.collection('chats').get(),
            builder: (context, snapshot) {
              print(snapshot.hasData);
              fireBase_Chat = snapshot.data?.docs.first;
              print('massages:  ${fireBase_Chat?['massages']?.length}');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: fireBase_Chat?['massages']?.length,
                      itemBuilder: (context, i) {
                        // print('i is $i');
                        // var msg = fireBase_Chat?.get('massages');
                        var msg = fireBase_Chat?['massages'];
                        // print('msg = ${msg['${i+1}']['massage_from']}');
                        // print('msg == ${msg['2']}');
                        print('ListView.builder!');
                        var msg_from = msg?['${i + 1}']['massage_from'];
                        var msg_to = msg?['${i + 1}']['massage_to'];
                        var msgText = msg?['${i + 1}']['msgText'];

                        bool? myMsg = currentUser_email == msg_from;
                        if (myMsg) {
                          guestUser_email = msg_to;
                        }
                        // print('myMsg $myMsg');

                        return Container(
                          // color: Colors.blue,
                          alignment: myMsg
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg_from,
                                style: TextStyle(fontSize: 10),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                      padding: const EdgeInsets.all(15.0),
                                      color: myMsg
                                          ? Colors.green[200]
                                          : Colors.black12,
                                      // child: Text('Msg ${msgIndex[i]}')),
                                      child: Text(msgText)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          decoration:
                              InputDecoration(hintText: 'Type new message..'),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            var msgs = fireBase_Chat?['massages'];
                            var msgs_length = msgs?.length ?? 0;
                            setState(() {
                              print(msgs_length);

                              msgs?[msgs_length + 1] = {
                                'from': currentUser_email,
                                'to': guestUser_email,
                                'msgChatIndex': msgs_length + 1,
                                'msgText': '${_msgController?.text}',
                                'timeStamp': 12.50,
                                'uniqueKey': 'XYZ'
                              };
                            });
                          },
                          child: Text('Create New Project')),
                    ],
                  ),
                ],
              );
            }));
  }
}
