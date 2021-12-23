import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class GoogleLoginApp extends StatefulWidget {
  const GoogleLoginApp({ Key? key }) : super(key: key);

  @override
  _GoogleLoginAppState createState() => _GoogleLoginAppState();
}

class _GoogleLoginAppState extends State<GoogleLoginApp> {
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);


  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount? user = _googleSignIn.currentUser;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Auth: '  + (user == null ? 'Please Log in' : user.displayName??'user.displayName is Null')),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(child: Text('Sign In'),
                  onPressed: () async {
                    await _googleSignIn.signIn();
                    setState(() {});
                  }
              ),
              ElevatedButton(child: Text('Sign Out'),
                  onPressed: () async {
                    await _googleSignIn.signOut();
                    setState(() {});
                  }
              ),
            ],
          ), // Column
        ), // Center
      ),
    );
  }
}