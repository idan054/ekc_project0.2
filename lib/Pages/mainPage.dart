// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MainPage extends StatefulWidget {
  GoogleSignInAccount? user;

  MainPage({this.user});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List projectNum = [1, 2];
  List msgIndex = [1, 2, 3];

  // Dict Sample
  Map<String, Map> chatsDict = {
    'chats': {
      'meUser': {
        'emailUser': 'idanbit80@gmail.com',
        'msgs' : {
          '1' : {
            'msgChatIndex': 1,
            'msgText': 'I have news',
            'timeStamp': 12.00,
            'uniqueKey': 'XXX'
          },
          '3' : {
            'msgChatIndex': 3,
            'msgText': 'Chat mock works.',
            'timeStamp': 12.50,
            'uniqueKey': 'ZZZ'
          }
        }
      },
      'guestUser': {
        'emailUser': 'oleg@gmail.com',
        'msgs' : {
          '2' : {
            'msgChatIndex': 2,
            'msgText': 'What is it?',
            'timeStamp': 12.10,
            'uniqueKey': 'YYY'
          },
        }
      }
    }
  };

// ValueNotifier<List> _counter = ValueNotifier<List>([1,2,3,4,5,6,7]);

  @override
  void initState() {
    print('init Coming!');
    print(chatsDict['chats']?['meUser']);
    print('init Done');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Hello ${widget.user?.displayName}'),
        ),
        drawer: Drawer(
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
                      leading: CachedNetworkImage(
                        imageUrl: "http://aarongorka.com/eks-orig.jpg",
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) {
                          print(error);
                          return Icon(Icons.error);
                        },
                      )
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
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 8.0),
              height: MediaQuery.of(context).size.height * 0.13,
              child: DrawerHeader(child: Text("Projects")),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: msgIndex.length,
                itemBuilder: (context, i) {
                  return ListTile(
                      title: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Container(
                              padding: const EdgeInsets.all(15.0),
                              color: Colors.black12,
                              child: Text('Msg ${msgIndex[i]}')),
                        ),
                      ),
                      leading: Container(
                        width: 50,
                        height: 50,
                        child: Image(image: AssetImage('Assets/eks-thumb.jpg')),
                      ));
                },
              ),
            ),
            TextButton(
                onPressed: () {
                  setState(() {
                    msgIndex.add(msgIndex.length + 1);
                    print(msgIndex);
                  });
                },
                child: Text('Create New Project'))
          ],
        ));
  }
}
