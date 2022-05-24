import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../Services/fetchTimeAgo.dart';
import '../Widgets/loadingWidget.dart';
import '../Widgets/snackbar.dart';
import '../theme/colors.dart';
import '../theme/config.dart';
import '../theme/constants.dart';
import 'A_loginPage.dart';
import 'B_profilePage.dart';
import 'flyerDmChat.dart';

bool localIsShown = false;
types.User? flyerUser; // temp Provider

class RilHomePage extends StatefulWidget {
  final types.Room room;
  types.User? flyerUser;

  RilHomePage({Key? key, this.flyerUser, required this.room}) : super(key: key);

  @override
  _RilHomePageState createState() => _RilHomePageState();
}

class _RilHomePageState extends State<RilHomePage> {
  User? authUser = FirebaseAuth.instance.currentUser;
  bool showLoader = true;
  bool _isAttachmentUploading = false;

  Widget _bubbleBuilder(
    Widget child, {
    required types.Message message,
    required nextMessageInGroup,
  }) {
    // log('Message C - Whats _bubbleBuilder gets: ${message.toJson()} \n');
    String? image = message.metadata?['imageUrl'] ?? 'https://bit.ly/3l64LIk';
    String text = message.toJson()['text'] ?? '';
    String name = message.metadata?['firstName'] ?? 'UserName Here.';
    String age =
        '${message.metadata?['metadata']?['age'] ?? 'XY'}'.substring(0, 2);
    bool isCurrentUser = authUser!.uid == message.author.id;
    bool msgReported = message.metadata?['metadata']['msgReported'] ?? false;
    var createdAgo = fetchTimeAgo(message.createdAt);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        onTap: isCurrentUser
            ? () {}
            : () async {
                final room =
                    await FirebaseChatCore.instance.createRoom(message.author);
                kPushNavigator(
                    context,
                    FlyerDmChat(
                      room: room,
                    ));
              },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey[200]!, width: 1.5),
            borderRadius: BorderRadius.circular(6.0),
          ),
          elevation: 0,
          shadowColor: Colors.black87,
          color: config.design.isPostStyle ? Colors.white : Colors.grey[100]!,
          // color: Colors.white,
          child: Column(
            children: [
              InkWell(
                child: SizedBox(
                  height: 25,
                  child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 10, left: 10, top: 7),
                      child:
                      isCurrentUser ? null :
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.more_horiz,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          if(msgReported && config.app.moderatorMode.value)
                          Icon(
                            Icons.flag,
                            color: Colors.red[700]?.withOpacity(0.50),
                            size: 20,
                          ),
                        ],
                      )),
                ),
                onTap: () async {
                  print('Long press taped.');
                  log(message.toJson().toString());
                  //   _handleDeleteAlert(context, message);
                  showCustomRilAlert(context,
                      titleWidget: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          children:  [
                            config.app.moderatorMode.value ?
                              ListTile(
                                title: Text('מחק הודעה זו'),
                                subtitle: Text('זמין למנהלים בלבד'),
                                leading: Icon(Icons.delete),
                                onTap: () async {
                                  // _handleDeleteAlert(context, message)
                                await _handleDeleteMsg(message);
                                  kNavigator(context).pop();
                                },
                              ) :
                            ListTile(
                              title: const Text('דווח על הפוסט'),
                              leading: const Icon(Icons.flag),
                              onTap: () async {
                                await _handleReportMsg(context, message);
                                setState(() => kNavigator(context).pop());
                              },
                            ),
                            ListTile(
                              title: Text('חסום משתמש זה'),
                              subtitle: Text('לעולם לא יוצגו פוסטים ממשתמש זה'),
                              leading: Icon(Icons.block),
                              onTap: () async {
                                await _handleBlockUser(context, message);
                                setState(() => kNavigator(context).pop());
                              },
                            ),
                          ],
                        ),
                      ));
                },
              ),
              Container(
                padding: const EdgeInsets.only(right: 10, left: 5),
                alignment: Alignment.topRight,
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
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
                          title: Text(
                            '$name ($age)',
                            style: TextStyle(
                                // color: Colors.primaries[Random().nextInt(Colors.primaries.length)].shade600,
                                // color: Colors.black
                                color: Colors.grey[600]!,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                            // style: bodyText1Format(context)
                          ),
                          subtitle: Text(
                            /*' · '*/
                            'לפני '
                            '$createdAgo',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                // color: Colors.primaries[Random().nextInt(Colors.primaries.length)].shade600,
                                // color: Colors.black
                                color: Colors.grey[600],
                                fontWeight: FontWeight.normal,
                                fontSize: 12),
                            // style: bodyText1Format(context)
                          ),
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(image!),
                            // backgroundImage: NetworkImage('https://bit.ly/3l64LIk'),
                          )),
                    ),

                    if (!isCurrentUser)
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            radius: 20,
                            child: IconButton(
                                onPressed: () async {
                                  print('message.author');
                                  print(message.author.id);
                                  final room = await FirebaseChatCore.instance
                                      .createRoom(message.author);
                                  kPushNavigator(
                                      context,
                                      FlyerDmChat(
                                        room: room,
                                        otherUserName: name,
                                      ));
                                },
                                icon: Icon(
                                  Icons.send_rounded,
                                  color: Colors.grey[500],
                                  size: 20,
                                )),
                          ),
                        ),
                      )

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

  @override
  Widget build(BuildContext context) {
    print('[Build] flyerChatV2');

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: FutureBuilder<types.User>(
            future: getFlyerUser(),
            builder: (context, flyerUserShot) {
              if (flyerUserShot.hasData) {
                types.User fetchedFlyerUser = flyerUserShot.data!;

                return ValueListenableBuilder<bool>(
                    valueListenable: config.app.moderatorMode,
                    builder: (BuildContext context, bool _moderatorMode,
                        Widget? child) {
                      return StreamBuilder<types.Room>(
                        initialData: widget.room,
                        stream: FirebaseChatCore.instance.room(widget.room.id),
                        builder: (context, roomSnapshot) {
                          if (roomSnapshot.hasData) {
                            // print('roomSnapshot.data');
                            // print(roomSnapshot.data.toJson());

                            return StreamBuilder<List<types.Message>>(
                              initialData: const [],
                              stream: FirebaseChatCore.instance.messages(
                                roomSnapshot.data!,
                                currentUser: fetchedFlyerUser,
                                rilHome: true,
                              ),
                              builder: (context, msgsSnapshot) {
                                if (msgsSnapshot.hasData) {
                                  if (msgsSnapshot.data!.isEmpty &&
                                      showLoader == true &&
                                      mounted) {
                                    Future.delayed(const Duration(seconds: 6))
                                        .then((_) {
                                      if (mounted)
                                        setState(() => showLoader = false);
                                      // print('showLoader is now $showLoader');
                                    });
                                    return Center(
                                      child: loadingWidget(context),
                                    );
                                  }

                                  return SafeArea(
                                    bottom: false,
                                    child: Chat(
                                      myIsPostStyle: config.design.isPostStyle,
                                      theme: DefaultChatTheme(
                                        inputBackgroundColor: cRilDarkPurple,
                                        backgroundColor:
                                            config.design.isPostStyle
                                                ? cGrey50
                                                : Colors.white,
                                      ),
                                      isAttachmentUploading:
                                          _isAttachmentUploading,
                                      messages: msgsSnapshot.data!,
                                      // onAttachmentPressed: _handleAtachmentPressed,
                                      // onMessageTap: _handleMessageTap,
                                      sendButtonVisibilityMode:
                                          SendButtonVisibilityMode.always,
                                      onPreviewDataFetched:
                                          _handlePreviewDataFetched,
                                      onSendPressed: (partialText) async =>
                                          _handleSendPressed(
                                              partialText, fetchedFlyerUser),
                                      user: fetchedFlyerUser,
                                      // author user
                                      bubbleBuilder: _bubbleBuilder,
                                      showUserAvatars: false,
                                      showUserNames: true,
                                    ),
                                  );
                                } else {
                                  return const Center(
                                    child: Text(
                                      'טוען...',
                                      style: TextStyle(
                                        color: neutral2,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                    ),
                                  );
                                }
                              },
                            );
                          } else {
                            return Center(
                              child: Text(
                                '${roomSnapshot.data}',
                                style: TextStyle(
                                  color: neutral2,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    });
              } else {
                return const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(
                      color: neutral2,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                );
              }
            }),
      ),
    );
  }

/*  @override
  void initState() {
    FirebaseChatCore.instance.createGroupRoom(name: 'RilHome', users: []);
    super.initState();
  }*/

  Future<types.User> getFlyerUser() async {
    if (flyerUser != null) return flyerUser!;
    var _fetchUser = await fetchUser(authUser!.uid, 'users');
    // print('fetchUser Json: $_fetchUser');

    // check Moderator & if signed up
    _handleSetUser(types.User.fromJson(_fetchUser));

    return types.User.fromJson(_fetchUser);
  }

  void _handleSetUser(types.User flyerUser) {
    config.app.isModerator = flyerUser.metadata?['MyModerator'] ?? false;

    bool isAgeSet = flyerUser.metadata?['age'] != null;
    // print('C_rilHomePage.dart isAgeSet $isAgeSet');
    if (!isAgeSet) {
      kPushNavigator(context, ProfilePage(flyerUser: flyerUser,
        fromLoginPage: true,), replace: true);
    }
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Photo'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleFileSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('File'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      _setAttachmentUploading(true);
      final name = result.files.single.name;
      final filePath = result.files.single.path!;
      final file = File(filePath);

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialFile(
          mimeType: lookupMimeType(filePath),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        FirebaseChatCore.instance.sendMessage(message, widget.room.id);
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      final file = File(result.path);
      final size = file.lengthSync();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.name;

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialImage(
          height: image.height.toDouble(),
          name: name,
          size: size,
          uri: uri,
          width: image.width.toDouble(),
        );

        FirebaseChatCore.instance.sendMessage(
          message,
          widget.room.id,
        );
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        final client = http.Client();
        final request = await client.get(Uri.parse(message.uri));
        final bytes = request.bodyBytes;
        final documentsDir = (await getApplicationDocumentsDirectory()).path;
        localPath = '$documentsDir/${message.name}';

        if (!File(localPath).existsSync()) {
          final file = File(localPath);
          await file.writeAsBytes(bytes);
        }
      }

      await OpenFile.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final updatedMessage = message.copyWith(previewData: previewData);

    FirebaseChatCore.instance.updateMessage(updatedMessage, widget.room.id);
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  void _handleSendPressed(
      types.PartialText message, types.User currentUser) async {
    print('my little msg $message');
    // var newMsg = message.metadata?.update
    //   ('8', (value) => 'New', ifAbsent: () => 'Mercury');

    // FirebaseChatCore.instance.updateMessage(newMsg, roomId);

    var getUser = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.id)
        .get();
    // print('AA');

    DateTime date;
    var _lastHomeMessage = getUser.data()?['metadata']['lastHomeMessage'];
    try {
      final _dateFormat = intl.DateFormat("yyyy-MM-dd HH:mm:ss");
      date = _dateFormat
          .parse(_lastHomeMessage); //Converting String to DateTime object
    } catch (e) {
      print('lastHomeMessage is probably timestamp. dealing with it..: err $e');
      date = _lastHomeMessage.toDate();
    }

    // Static Value - Don't use!
    // var date = firestoreUserData?.metadata?['lastHomeMessage'];
    //  2022-05-1317: 25: 18.649543,
    // print('FS MD ${firestoreUserData?.metadata?['lastHomeMessage']}');
    // String _lastHomeMessage = '${firestoreUserData?.metadata?['lastHomeMessage']}';

    final nowDate = DateTime.now();
    final difference = nowDate.difference(date);
    print('difference.inSeconds');
    print(difference.inSeconds);

    var time2Wait = kDebugMode ? 30 : 60 * 3;

    var waitUntil =
        DateTime.now().add(Duration(seconds: time2Wait - difference.inSeconds));
    print('waitUntil');
    print(waitUntil);

    if (difference.inSeconds < time2Wait) {
      cleanSnack(context,
          color: cRilDarkPurple,
          textColor: Colors.white54,
          text: 'ניתן לפרסם שוב בעוד '
                  '$time2Wait'
                  ' שניות'
                  ' (' +
              '${DateTime.now().add(Duration(seconds: time2Wait))}'
                  .substring(11, 16) +
              ')');
    } else {
      var _user = FirebaseAuth.instance.currentUser;
      var lastHomeMessage = DateTime.now();
      print('_user: ${_user?.uid}');

      var _userData = currentUser.copyWith(
          firstName: '${currentUser.firstName}',
          imageUrl: '${currentUser.imageUrl}',
          metadata: {
            'id': currentUser.id,
            'email': '${currentUser.metadata?['email']}',
            'birthDay': currentUser.metadata?['birthDay'],
            'age': currentUser.metadata?['age'],
            'lastHomeMessage': '$lastHomeMessage',
          });

      // setState(() async {
      // create or update
      await FirebaseChatCore.instance
          .createUserInFirestore(_userData)
          .whenComplete(() => print(
              'firebaseDatabase_basedFlyer Completed \n(FirebaseChatCore.instance.createUserInFirestore)'
              '\n userData: $_userData'))
          .onError((error, stackTrace) => print(
              'firebaseDatabase_basedFlyer FAILED: $error \n-|- $stackTrace \n(FirebaseChatCore.instance.createUserInFirestore)'));
      // });

      print('Message A: ${message.toJson()}');

      cleanSnack(context,
          color: cRilDarkPurple,
          textColor: Colors.white54,
          text: 'ניתן לפרסם שוב בעוד 3 דקות');
      FirebaseChatCore.instance.sendMessage(
        message,
        widget.room.id,
        myAuthUser: _userData,
      );
    }
  }
}

showRilAlert(context, bool exitProfile) async {
  showDialog(
    barrierDismissible: true,
    context: context,
    // barrierColor: StreamChatTheme.of(context).colorTheme.overlay,
    builder: (context) => Center(
        child: AlertDialog(
      // contentPadding: EdgeInsets.zero,
      // titlePadding: EdgeInsets.zero,
      actionsAlignment: MainAxisAlignment.center,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 13.0),
            child: Text(
              exitProfile ? 'תרצה לצאת' : 'ברוכים הבאים אל',
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                exitProfile ? ' מרילטופיה?' : 'רילטופיה',
                textDirection: TextDirection.rtl,
                style: const TextStyle(
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
      // content: Text("Saved successfully"),
      actions: [
        TextButton(
          onPressed: () => kNavigator(context).pop(),
          child: Text(exitProfile ? 'חזור' : 'התחל',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: cRilPurple)),
        ),
        if (exitProfile)
          TextButton(
            onPressed: () => kPushNavigator(context, const LoginPage()),
            child: const Text('יציאה', style: TextStyle(color: Colors.grey)),
          ),
      ],
    )),
  );
}

_handleBlockUser(context, types.Message message) async {
  User? authUser = FirebaseAuth.instance.currentUser;
  var firestoreDoc = FirebaseFirestore.instance.doc('users/${authUser?.uid}');

  await firestoreDoc.set({
    'metadata': {'blockedUsers':
    FieldValue.arrayUnion([(message.author.id)])}
  }, SetOptions(merge:true),);

  cleanSnack(context, text: 'המשתמש נחסם ולא תראה ממנו יותר פוסטים.',
      color: Colors.red[700],
      textColor: Colors.white,
      action: SnackBarAction(
        textColor: Colors.white,
        label: 'ביטול',
        onPressed: () async {
          await firestoreDoc.set({
            'metadata': {'blockedUsers':
            FieldValue.arrayRemove([(message.author.id)])}
          }, SetOptions(merge:true),);

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          cleanSnack(context, text: 'הפעולה בוטלה');
  }));
}

_handleReportMsg(context, types.Message message) async {
  await FirebaseFirestore.instance
      .collection('rooms/ClZEotxQ0ybSVlNykN0e/messages')
      .doc(message.id).set({
    'author': {
        'metadata' :
        {'msgReported': true}
      }
    }, SetOptions(merge:true),);

  cleanSnack(context, text: 'הפוסט דווח ויטופל בהקדם!',
      textColor: Colors.white,
      color: Colors.red[700]);
}

_handleDeleteMsg(types.Message message) async {
  await FirebaseFirestore.instance
      .collection('rooms/ClZEotxQ0ybSVlNykN0e/messages')
      .doc(message.id)
      .delete();
}

_handleDeleteAlert(context, types.Message message) {
  return showCustomRilAlert(
    context,
    title: 'למחוק הודעה זו?',
    desc: '${message.toJson()['text']}'
        '\n |'
        '\n...${message.author.id.substring(0, 8)}'
        '\n${message.author.firstName ?? message.metadata?['firstName']}'
        '\n${message.metadata?['metadata']['email']}',
    actions: [
      TextButton(
        onPressed: () async {
          await _handleDeleteMsg(message);
          kNavigator(context).pop();
        },
        child: const Text('מחק הודעה',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
      ),
      TextButton(
        onPressed: () => kNavigator(context).pop(),
        child: const Text('ביטול', style: TextStyle(color: Colors.grey)),
      ),
    ],
  );
}

showCustomRilAlert(context,
    {String? title,
    String? desc,
    List<Widget>? actions,
    Widget? titleWidget}) async {
  showDialog(
    barrierDismissible: true,
    context: context,
    // barrierColor: StreamChatTheme.of(context).colorTheme.overlay,
    builder: (context) => Center(
        child: AlertDialog(
      // contentPadding: EdgeInsets.zero,
      // titlePadding: EdgeInsets.zero,
      actionsAlignment: MainAxisAlignment.center,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: titleWidget ??
          Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 13.0),
                child: Text(
                  '$title',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                  child: Text(
                '$desc',
                style: const TextStyle(
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
      // content: Text("Saved successfully"),
      actions: actions,
    )),
  );
}
