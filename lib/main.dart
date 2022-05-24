import 'package:ekc_project/Pages/C_rilHomePage.dart';
import 'package:ekc_project/theme/textV2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'Pages/A_loginPage.dart';
import 'Pages/ril_gDashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    User? authUser = FirebaseAuth.instance.currentUser;
    // print('FireAuth USER ${authUser?.displayName}');

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: buildLightText()
      ),
        home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return
                GDashboard(homePage:
                  RilHomePage(
                    room: types.Room(
                        users: [types.User(id: '${authUser?.uid}')], // Adds the user to group
                        type: types.RoomType.group,
                        id: 'ClZEotxQ0ybSVlNykN0e'),
                    // currentUser: widget.userData,),
                    flyerUser: types.User(id: '${authUser?.uid}')),);
              } else {
                return const LoginPage();
              }
            })
      // home: const LoginPage()
      // home: MainPage(),
    );
  }
}
