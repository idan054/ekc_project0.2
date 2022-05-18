import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekc_project/Pages/ril_gDashboard.dart';
import 'package:ekc_project/dump/usersPage.dart';
import 'package:ekc_project/Widgets/addPtDialog.dart';
import 'package:ekc_project/Widgets/myAppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'dart:convert';
import 'package:ekc_project/Widgets/myDrawers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show LengthLimitingTextInputFormatter, rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:io';
import '../theme/colors.dart';
import '../theme/constants.dart';
import 'dummyPage.dart';
import '../dump/flyerChat.dart';
import 'flyerChatV2.dart';

class ProfilePage extends StatefulWidget {
  // bool isGoogleSign_user;
  final types.User? userData;

  // UserCredential? classic_currentUser;
  // final currentUser;
  //
  // AllUsersPage({this.currentUser, required this.isGoogleSign_user});
  const ProfilePage({Key? key, this.userData}) : super(key: key);

  // const AllUsersPage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool imagePicked = false;
  XFile? localImage;
  String? imageUrl;
  User? fUSer = FirebaseAuth.instance.currentUser;
  var nameController = TextEditingController();
  var nameNode = FocusNode();

  @override
  void initState() {
    nameController = TextEditingController(text: '${fUSer?.displayName}');
    imageUrl = fUSer?.photoURL;
    super.initState();
  }

  // `FirebaseChatCore.instance.users()` stream

  @override
  Widget build(BuildContext context) {
    var selectedTime = DateTime.now();
    // var fUSer = FirebaseAuth.instance.currentUser;

    return Scaffold(

        // appBar: myAppBar('Find someone to chat'),
        // appBar: myAppBar(context, '${widget.userData?.firstName}'),
        appBar: myAppBar(context, 'יצירת פרופיל'),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                Center(
                  child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[400]?.withOpacity(0.75),
                      child: imagePicked
                          ? CircleAvatar(
                              radius: 46,
                              backgroundColor:
                                  Colors.grey[400]?.withOpacity(0.75),
                              backgroundImage: FileImage(File(localImage!.path))
/*                        backgroundImage:
                            DecorationImage(
                              image: AssetImage('assets/background_doodle.png'),
                              fit: BoxFit.cover,
                            )*/
                              // ,
                              )
                          : CircleAvatar(
                              radius: 46,
                              backgroundColor:
                                  Colors.grey[400]?.withOpacity(0.75),
                              backgroundImage:
                                  NetworkImage('${fUSer?.photoURL}'),
                            )),
                ),
                Positioned(
                  bottom: 0,
                  left: kMediaQuery(context).size.width * 0.525,
                  child: InkWell(
                    onTap: () async {
                      //~ 1: Choosing picture
                      final ImagePicker _picker = ImagePicker();
                      localImage =
                          await _picker.pickImage(source: ImageSource.gallery);
                      // setState(() => imagePicked = true);
                      cleanSnack(context,
                          text: 'המתן. מעדכן את התמונה..', sec: 2);
                      print('XFile? image ${localImage?.path}');

                      //~ 2: Upload the picture
                      final storage = FirebaseStorage.instance;
                      Reference ref = storage.ref().child(
                          '${fUSer?.displayName}_ProfilePic_${DateTime.now()}');
                      await ref.putFile(File(localImage!.path)).catchError((e) {
                        print('putFile $e');
                      });
                      imageUrl = await ref.getDownloadURL();

                      //~ 2: Set Auth url
                      await fUSer?.updatePhotoURL(imageUrl);
                      FirebaseAuth.instance.authStateChanges(); // update
                      //! fUSer?.photoURL is actually imageUrl
                      // BUT it will take time to sync
                      print('imageUrl is $imageUrl');
                      // print('new fUSer?.photoURL is ${fUSer?.photoURL}');

                      setState(() => imagePicked = true);
                      cleanSnack(context,
                          text: 'התמונה עודכנה בהצלחה!', sec: 2);
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey[300],
                      // backgroundColor: Colors.white,
                      child: const Icon(Icons.photo_camera_rounded,
                          size: 22, color: cRilDeepPurple
                          // color: Colors.black,
                          ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => nameNode.requestFocus(),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.create_rounded,
                        size: 22, color: cRilDeepPurple),
                  ),
                ),
                const SizedBox(width: 7),
                Transform.translate(
                  offset: Offset(0, 3),
                  child: SizedBox(
                    // width min 120 or size - max padding
                    // width: '${fUSer?.displayName}'.length * 12, // 19
                    width: '${nameController.text}'.length * 18 < 120 ?
                        140 : '${nameController.text}'.length * 16, // 19
                    height: 60,
                    child: TextField(
                      controller: nameController,
                      focusNode: nameNode,
                      // inputFormatters: [LengthLimitingTextInputFormatter(10),],
                      // expands: false,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      cursorColor: cRilDeepPurple,
                      onChanged: (val)=>setState(() {}),
                      decoration: InputDecoration(
                        // prefixIcon: Icon(Icons.create_rounded, size: 22, color: cRilDeepPurple),
                        filled: false,
                        enabledBorder: InputBorder.none,
                        // hintText: '${fUSer?.displayName}',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                            color: cRilDeepPurple, width: 2),
                            ),
                        hintText: '${fUSer?.displayName}',
                        hintStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  'שלום',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ],
            ),
            if(nameNode.hasFocus)
            if(nameNode.hasFocus)
              const SizedBox(height: 8,),
            const Text(
              'מה תאריך הלידה שלך?',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                height: 125,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (DateTime dTime) {
                    selectedTime = dTime;
                  },
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
                    var user = widget.userData;

                    //the birthday's date
                    var difference =
                        DateTime.now().difference(selectedTime).inDays;
                    var age = difference / 365;
                    print('Age is $age');

                    await fUSer?.updateDisplayName(nameController.text);
                    var userData = widget.userData?.copyWith(
                        // firstName: '${user?.firstName}',
                        firstName: nameController.text,
                        imageUrl: '$imageUrl',
                        // lastName: '${fireStoreUser?.email}'.toLowerCase(),
                        role: types.Role.user,
                        metadata: {
                          'id': '${user?.id ?? UniqueKey()}',
                          'email': user?.metadata?.values.first,
                          'birthDay': '$selectedTime',
                          'age': age,
                          'lastHomeMessage': DateTime(01, 01, 2000),
                        });

                    if (age < 13) {
                      print('True - AGE: $age');
                      cleanSnack(context, text: 'אתה חייב להיות מעל גיל 13.');
                    } else {
                      print('False - AGE: $age');
                      // create or update
                      FirebaseChatCore.instance
                          .createUserInFirestore(userData!)
                          .whenComplete(() => print(
                              'firebaseDatabase_basedFlyer Completed \n(FirebaseChatCore.instance.createUserInFirestore)'
                              '\n userData: $userData'))
                          .onError((error, stackTrace) => print(
                              'firebaseDatabase_basedFlyer FAILED: $error \n-|- $stackTrace \n(FirebaseChatCore.instance.createUserInFirestore)'));

                      // final room = await FirebaseChatCore.instance
                      //     .room('NAMAkmZKdEAv9AefwXhR');

                      // Fixing push replacement
                      // showRilAlert(context, false);
                      // await Future.delayed(const Duration(seconds: 4), () => Navigator.of(context).popUntil((route) => route.isFirst));
                      showCustomRilAlert(context,
                      title: '${nameController.text}' ', האם תרצה להמשיך?',
                      desc: 'שים לב ❤️, לא ניתן לשנות פרטים אלו.',
                      actions: [
                        TextButton(
                          onPressed: () async {
                            kNavigator(context).pop();
                            showCustomRilAlert(context,
                              titleWidget: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 13.0),
                                      child: Text( 'ברוכים הבאים אל',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                           'רילטופיה',
                                          textDirection: TextDirection.rtl,
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
                                    const SizedBox(height: 20),
                                    const Center(
                                        child: Text(
                                          'כולם כאן בגיל שלך (+3-)'
                                              '\n זה המקום להכיר, לשתף, לעזור ולהיות מי שאתה!',
                                          style: TextStyle(
                                            color: neutral2,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            height: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                          textDirection: TextDirection.rtl,
                                        )),
                                  ],
                                )),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // kNavigator(context).pop();
                                    // Navigator.of(context).popUntil((route) => route.isFirst);
                                  kPushNavigator(
                                      context,
                                      GDashboard(
                                        homePage: FlyerChatV2(
                                          room: types.Room(
                                              users: [widget.userData!],
                                              // Adds the user to group
                                              type: types.RoomType.group,
                                              id: 'NAMAkmZKdEAv9AefwXhR'),
                                          // currentUser: widget.userData,),
                                          currentUser: userData,
                                        ),
                                      ),
                                      replace: true);
                                  },
                                  child: const Text( 'התחל',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: cRilPurple)),
                                ),
                              ],
                            );
                          },
                          child: const Text('המשך',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: cRilDeepPurple
                              )),
                        ),
                        TextButton(
                          onPressed: () => kNavigator(context).pop(),
                          child: const Text('חזור',
                              style: TextStyle(
                                  color: Colors.grey
                              )),
                        ),
                      ]
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      // color: StreamChatTheme.of(context).colorTheme.barsBg,
                      border: Border.all(
                          // color: StreamChatTheme.of(context).colorTheme.borders,
                          color: Colors.deepPurple,
                          width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        'סיום',
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
                      trailing: Icon(
                        Icons.done_rounded,
                        color: cRilPurple,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            const SizedBox(
              height: 15,
            )
          ],
        ));
  }
}

cleanSnack(
  BuildContext context, {
  required String text,
  Color? color,
  Color? textColor,
  int sec = 3,
  SnackBarAction? action,
}) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    behavior: SnackBarBehavior.floating,
    // padding: const EdgeInsets.only(bottom: 15),
    // backgroundColor: kColorSpiderRed.withOpacity(0.80),
    // backgroundColor: Colors.grey[100]?.withOpacity(0.85),
    backgroundColor:
        color == null ? Colors.grey[100]?.withOpacity(0.85) : color,
    padding: const EdgeInsets.all(10),
    // content: Text(S.of(context).warning(message)),
    content: Text(
      '$text',
      textAlign: TextAlign.center,
      style: TextStyle(
          color: textColor == null ? Colors.black : textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold),
    ),
    duration: Duration(seconds: sec),
    action: action,
    // action: SnackBarAction(
    //   label: 'סגור',
    //   onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),),
  ));
}
