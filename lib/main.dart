import 'package:ekc_project/Pages/flyerChatV2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'Pages/A_loginPage.dart';

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
    print('FireAuth USER ${authUser?.displayName}');

    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var userData = types.User(
                  firstName: snapshot.data?.displayName ?? '',
                  id: snapshot.data?.uid ?? UniqueKey().toString(),
                  imageUrl: snapshot.data?.photoURL,
                  // lastName: '${fireStoreUser?.email}'.toLowerCase(),
                  metadata: {
                    'email': snapshot.data?.email ?? '',
                    'age': 18,
                  },
                );
                return FlyerChatV2(
                    currentUser:
                        types.User(id: snapshot.data?.uid ?? '', metadata: {
                      'age': 18,
                      'email': snapshot.data?.email ?? '',
                    }),
                    room: types.Room(
                      id: '1OepWQhysrUuqzU6eYOR',
                      users: [userData],
                      type: types.RoomType.group,
                    ));
              } else {
                return const LoginPage();
              }
            })
        // home: MainPage(),
        );
  }
}
