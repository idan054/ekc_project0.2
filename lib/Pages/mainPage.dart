// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MainPage extends StatefulWidget {
  GoogleSignInAccount? user;

  MainPage({this.user});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var numberTruthList = [1,2,3,4,5,6,7];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello ${widget.user?.displayName}'),
      ),
      drawer: Drawer(
          child: Column(
        children: [
          DrawerHeader(
          child: Text("Projects")),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text('Project ${numberTruthList[i]}'),
                );
              },
            ),
          ),
        ],
      )),
    );
  }
}
