// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekc_project/Pages/B_profilePage.dart';
import 'package:ekc_project/theme/config.dart';
import 'package:ekc_project/Pages/ril_gDashboard.dart';
import 'package:ekc_project/Widgets/myAppBar.dart';
import 'package:ekc_project/theme/colors.dart';
import 'package:ekc_project/theme/constants.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/config.dart';
import 'flyerChatV2.dart';
import '../dump/usersPage.dart';
import '../dump/mainPage.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _googleSignIn = GoogleSignIn(scopes: ['email']);
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount? user = _googleSignIn.currentUser;

    return MaterialApp(
      home: Scaffold(
/*        appBar: myAppBar('Gang - ' +
        (user == null
        ? "צ'אט חברתי בטא"
            : user.displayName ?? 'user.displayName is Null')),*/
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 100),
              // Random Sign with google

              Padding(
                padding: const EdgeInsets.only(top: 13.0),
                child: Text(
                  'ברוכים הבאים אל',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'רילטופיה',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),

                  SvgPicture.asset(
                    'assets/svg_icons/CleanLogo.svg',
                    height: 30,
                    // color: StreamChatTheme.of(context).colorTheme.accentPrimary,
                  ),
                  // trailing: Image.asset('assets/RilTopialLogoAndTxt.png',
                  //   height: 45,)
                ],
              ),

              SizedBox(height: 50),

              buildInfoListTile(
                context,
                // title: 'המקום לפגוש חברים',
                // title: 'המקום לדבר עם אנשים',
                title: 'זה המקום להכיר אנשים (:',
                subTitle: 'כולם בגיל שלך (עד 3 שנים הבדל).',
                svgAsset: 'assets/svg_icons/group.svg',
              ),

              buildInfoListTile(
                context,
                // title: 'המקום לפגוש חברים',
                // title: 'המקום לדבר עם אנשים',
                title: 'והזמן לקבל תשובות.',
                // subTitle: 'מענה מיידי בכל נושא.',
                subTitle: 'מענה מיידי על כל דבר.',
                svgAsset: 'assets/svg_icons/thunder.svg',
              ),

              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: isLoading
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: LinearProgressIndicator(
                      backgroundColor: kEmptyColor, color: cRilPurple),
                ),
                secondChild: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 28,
                    color: Colors.grey[500]?.withOpacity(0.75),
                  ),
                ),
              ),

              Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      await _googleSignIn.signOut();
                      final GoogleSignInAccount? googleSignInAccount =
                          await _googleSignIn.signIn();

                      if (googleSignInAccount != null) {
                        setState(() => isLoading = true);

                        final GoogleSignInAuthentication
                            googleSignInAuthentication =
                            await googleSignInAccount.authentication;

                        final AuthCredential credential =
                            GoogleAuthProvider.credential(
                          accessToken: googleSignInAuthentication.accessToken,
                          idToken: googleSignInAuthentication.idToken,
                        );

                        final FirebaseAuth auth = FirebaseAuth.instance;
                        final UserCredential userCredential =
                            await auth.signInWithCredential(credential);

                        final User? fireStoreUser = userCredential.user;
                        final myUid = fireStoreUser?.uid;

                        print('loginPAge user $fireStoreUser');
                        print('loginPAge myUid $myUid');

                        // var userDoc = await FirebaseFirestore.instance.collection('users').doc(myUid).get();
                        // print('userDoc.exists ${userDoc.exists}');
                        // print('userDoc.data ${userDoc.data()}');

                        Map<String, dynamic>? currentUser;
                        try {
                          currentUser =
                              await fetchUser(fireStoreUser!.uid, 'users');
                        } catch (e) {
                          print('err 164: $e');
                        }

                        // if(userDoc.exists){
                        if (!config.debug.alwaysSignup
                        && currentUser != null) { // AKA user exists
                          types.User flyerUser =
                              types.User.fromJson(currentUser);
                          setState(() => isLoading = false);
                          kPushNavigator(
                              context,
                              GDashboard(
                                homePage: FlyerChatV2(
                                  room: types.Room(
                                      users: [flyerUser],
                                      // Adds the user to group
                                      type: types.RoomType.group,
                                      id: 'NAMAkmZKdEAv9AefwXhR'),
                                  // currentUser: widget.userData,),
                                  currentUser: flyerUser,
                                ),
                              ),
                              replace: true);
                        } else { // AKA new user
                          var userData = types.User(
                              firstName: fireStoreUser?.displayName,
                              id: fireStoreUser?.uid ?? UniqueKey().toString(),
                              imageUrl: fireStoreUser?.photoURL,
                              // lastName: '${fireStoreUser?.email}'.toLowerCase(),
                              metadata: {'email': fireStoreUser?.email});

                          await FirebaseChatCore.instance
                              .createUserInFirestore(userData)
                              .whenComplete(() => print(
                                  'firebaseDatabase_basedFlyer Completed \n(FirebaseChatCore.instance.createUserInFirestore)'
                                  '\n userData: $userData'))
                              .onError((error, stackTrace) => print(
                                  'firebaseDatabase_basedFlyer FAILED: $error \n-|- $stackTrace \n(FirebaseChatCore.instance.createUserInFirestore)'));

                          setState(() => isLoading = false);
                          kPushNavigator(
                            context,
                            ProfilePage(userData: userData), /*replace: true*/
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        // color: StreamChatTheme.of(context).colorTheme.barsBg,
                        border: Border.all(
                            // color: StreamChatTheme.of(context).colorTheme.borders,
                            color: cRilPurple,
                            width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        visualDensity: VisualDensity.compact,
                        leading: SvgPicture.asset(
                          'assets/svg_icons/google_logo.svg',
                          height: 30,
                          // color: StreamChatTheme.of(context).colorTheme.accentPrimary,
                        ),
                        title: Text(
                          isLoading ? 'מיד נכנסים...' : 'התחבר באמצעות גוגל',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

/*                subtitle: Text(
                        AppLocalizations.of(context).streamTestAccount,
                        style: StreamChatTheme.of(context)
                            .textTheme
                            .footnote
                            .copyWith(
                          color: StreamChatTheme.of(context)
                              .colorTheme
                              .textLowEmphasis,
                        ),
                      ),*/
                        trailing: Transform.scale(
                            scale: -1,
                            child: const Icon(
                              Icons.arrow_right_alt_rounded,
                              color: cRilPurple,
                              size: 28,
                            )),
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(),
              Center(
                child: InkWell(
                    child: Wrap(
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          // 'התחברותך מהווה הסכמה ',
                          'By logging I agree that I have read and accepted the',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          'Terms of use',
                          // 'לתנאי המדיניות',
                          style:
                          TextStyle(color: Colors.blue[600]!, fontSize: 12),
                        ),
                      ],
                    ),
                    onTap: () => launchUrl(Uri.parse(
                        'https://www.privacypolicies.com/live/4ae28974-cd40-4c8e-b265-6d6da2c7690b'))),
              ),
              SizedBox(height: 15,),
            ],
          ), // Column
        ), // Center
      ),
    );
  }
}

Widget buildInfoListTile(
  BuildContext context, {
  required String title,
  required String subTitle,
  required String svgAsset,
}) {
  return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          decoration: BoxDecoration(
            // color: StreamChatTheme.of(context).colorTheme.inputBg,
            color: Colors.grey[100],
            border: Border.all(
                color: Colors.grey[500]!.withOpacity(0.75),
                // color: StreamChatTheme.of(context).colorTheme.disabled,
                // color: cRilPurple,
                width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            visualDensity: VisualDensity.compact,
            leading: SvgPicture.asset(
              '$svgAsset',
              height: 30,
              color: Colors.grey[500]?.withOpacity(0.75),
              // color: StreamChatTheme.of(context).colorTheme.textLowEmphasis.withOpacity(0.6),
            ),
            title: Text(
              '$title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              '$subTitle',
              style: TextStyle(
                fontSize: 14,
                // fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
      ));
}
