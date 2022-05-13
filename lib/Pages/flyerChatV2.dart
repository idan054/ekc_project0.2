import 'dart:io';
import 'package:ekc_project/Pages/mainPage.dart';
import 'package:ekc_project/Services/myFirebaseFlyer.dart';
import 'package:ekc_project/Widgets/addUserDialog.dart';

import 'package:ekc_project/Widgets/myAppBar.dart';
import 'package:ekc_project/Widgets/myDrawers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as lol;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../Widgets/cardPost.dart';
import '../myUtil.dart';
import '../theme/constants.dart';
import 'A_loginPage.dart';
import 'usersPage.dart';
import 'package:bubble/bubble.dart';

class FlyerChatV2 extends StatefulWidget {
/*  const FireBaseChatPage({
    Key? key,
    required this.room,
  }) : super(key: key);*/

  final types.Room room;

  final types.User? currentUser;

  // final UserCredential? currentUser;

  // final currentUser;

  const FlyerChatV2({this.currentUser, required this.room}) : super();

  @override
  _FlyerChatV2State createState() => _FlyerChatV2State();
}

class _FlyerChatV2State extends State<FlyerChatV2> {
  Widget _bubbleBuilder(
      Widget child, {
        required types.Message message,
        required nextMessageInGroup,
      }) {
    var user = widget.currentUser;

    // print(message.toJson());
    var image = {user?.imageUrl};
    var name = message.author.firstName ?? user?.firstName;
    var createdAgo = timeAgo(message.createdAt);
    var text = message.toJson()['text'];
    var age = '${message.author.metadata?['age']
                  ?? user?.metadata?['age']}'.substring(0, 2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        shape:
        RoundedRectangleBorder(
          side: BorderSide( color: Colors.grey[200]!, width: 1.5 ),
          borderRadius: BorderRadius.circular(6.0),),
        elevation: 0,
        shadowColor: Colors.black87,
        color: Colors.grey[100]!,
        child: Column(
          children: [
            const SizedBox(height: 2,),
            Container(
              padding: const EdgeInsets.only(right: 10, left: 10),
              alignment: Alignment.centerRight,
              child:
              InkWell(
                child:
                Icon(
                  Icons.more_horiz,
                  color: Colors.grey[200]!,
                ),
                onTap:() {},
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 10, left: 10),
              alignment: Alignment.topRight,
              child: Text(text,
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
              child:
              Row(
                children: [
                  Flexible(
                    child:
                    ListTile(
                        dense: true,
                        visualDensity: VisualDensity.standard,
                        title:
                        Text(
                          '$name ($age)',
                          style: TextStyle(
                            // color: Colors.primaries[Random().nextInt(Colors.primaries.length)].shade600,
                            // color: Colors.black
                              color: Colors.grey[600]!,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                          // style: bodyText1Format(context)
                        ),
                        subtitle:
                        Text(
                          /*' · '*/  'לפני ' '$createdAgo',
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
                        leading:   CircleAvatar(
                          backgroundImage: NetworkImage('$image'),
                        )
                    ),
                  ),


                  Builder(
                      builder: (context) =>
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child:
                          CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            radius: 20,
                            child: IconButton(
                                onPressed: (){},
                                icon: Icon(Icons.send_rounded, color:
                                Colors.grey[500],
                                  size: 20,)),
                          ),

                        ),
                      )
                  )

                  // const SizedBox(width: 10),
                  // const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Bubble(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if ('${user?.id}' == message.author.id)
                Text('${user?.firstName}'),
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('${user?.imageUrl}'),
              ),
              if ('${user?.id}' != message.author.id)
                Text('${user?.firstName}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14)
                ),
            ],
          ),
          child,
        ],
      ),
      color: '${user?.id}' != message.author.id ||
          message.type == types.MessageType.image
          ? const Color(0xfff5f5f7)
          : const Color(0xff6f61e8),
      margin: nextMessageInGroup
          ? const BubbleEdges.symmetric(horizontal: 6)
          : null,
      nip: nextMessageInGroup
          ? BubbleNip.no
          : '${user?.id}' != message.author.id
          ? BubbleNip.leftBottom
          : BubbleNip.rightBottom,
    );
  }


  bool _isAttachmentUploading = false;
  var guestUser;
  // GoogleSignInAccount? guestUser;
  // UserCredential? guestUser;
  String? appBarTitle;
  List<String>? roomEmailUsers;

  @override
  void initState() {
    print('widget.room.type');
    print(widget.room.type.toString());
    print(widget.room.name);


    // RoomType.direct
    // RoomType.group
    if (widget.room.type.toString() == 'RoomType.direct') {
      widget.room.users.forEach((user) {
/*        if (widget.currentUser?.email != user.lastName) {
          // Lastname is MAIL!
          setState(() {
            guestUser = user;
            appBarTitle = '${guestUser.lastName}';
          });
        }*/
      });
    } else {
      setState(() {
        appBarTitle = widget.room.name;
      });
    }

    // Get all users:
    widget.room.users.forEach((user) {
      print('XXX user.lastName ${user.lastName}');
      // roomEmailUsers?.add(user.lastName.toString());
      roomEmailUsers = [...?roomEmailUsers, user.lastName.toString()];
    }
    );
    print('roomEmailUsers: ${roomEmailUsers?.length} ${roomEmailUsers.runtimeType} $roomEmailUsers');

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: myAppBar(
          // appBarTitle,
          'Home',
          actions: [
            IconButton(
                onPressed: () => kPushNavigator(context, const LoginPage()),
                icon: const Icon(Icons.logout_rounded))
          ]
        ),
        body: StreamBuilder<types.Room>(
          initialData: widget.room,
          stream: FirebaseChatCore.instance.room(widget.room.id),
          builder: (context, snapshot) {
            return StreamBuilder<List<types.Message>>(
              initialData: const [],
              stream: FirebaseChatCore.instance.messages(snapshot.data!),
              builder: (context, snapshot) {

                List<types.Message> filteredMsgs = [];
                print('snapshot.data');
                var ageFilter = 3;  //{14 [17] 20}
                var maxAge = widget.currentUser
                        ?.metadata?['age']+ ageFilter;
                var minAge = widget.currentUser
                       ?.metadata?['age'] - ageFilter;
                snapshot.data?.forEach((msg) {
                  var _age = msg.author.metadata?['age'] ?? 0;
                  // if(_age != 0) print('$minAge - $_age - $maxAge');
                  // if(_age != 0) print(_age >= minAge && _age <= maxAge);
                  bool inAgeRange = _age >= minAge && _age <= maxAge;

                  if(inAgeRange || _age == 0) filteredMsgs.add(msg);
                //   print(_age.runtimeType);
                });

                return SafeArea(
                  bottom: false,
                  child: Chat(
                    isAttachmentUploading: _isAttachmentUploading,
                    // messages: snapshot.data ?? [],
                    messages: filteredMsgs,
                    onAttachmentPressed: _handleAtachmentPressed,
                    onMessageTap: _handleMessageTap,
                    onPreviewDataFetched: _handlePreviewDataFetched,
                    onSendPressed: (partialText) =>
                        _handleSendPressed(partialText, widget.currentUser!),
                    // user: types.User(id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',),
                    user: widget.currentUser!,
                    bubbleBuilder: _bubbleBuilder,
                    showUserAvatars: false,
                    showUserNames: true,
                    // customMessageBuilder: ,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
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

  void _handleSendPressed(types.PartialText message, types.User currentUser) {
    var _user = FirebaseAuth.instance.currentUser;
    print('_user: ${_user?.uid}');

    var _userData = currentUser.copyWith(
        firstName: '${currentUser.firstName}',
        imageUrl: '${currentUser.imageUrl}',
        metadata: {
          'id' : currentUser.id,
          'email' : '${currentUser.metadata?['email']}',
          'birthDay' : currentUser.metadata?['birthDay'],
          'age' : currentUser.metadata?['age'],
          'lastHomeMessage': '${DateTime.now()}',
        }
    );


      setState(() async {
        // create or update
        FirebaseChatCore.instance.createUserInFirestore(_userData)
            .whenComplete(() =>
            print(
                'firebaseDatabase_basedFlyer Completed \n(FirebaseChatCore.instance.createUserInFirestore)'
                    '\n userData: $_userData'))
            .onError((error, stackTrace) =>
            print(
                'firebaseDatabase_basedFlyer FAILED: $error \n-|- $stackTrace \n(FirebaseChatCore.instance.createUserInFirestore)'));

      });



    // FirebaseChatCore.instance.sendMessage(
    //   message,
    //   widget.room.id,
    // );
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }
}

