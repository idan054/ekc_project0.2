import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'firebase_chat_core_config.dart';
import 'util.dart';
import 'package:ekc_project/theme/config.dart' as my;

/// Provides access to Firebase chat data. Singleton, use
/// FirebaseChatCore.instance to aceess methods.
class FirebaseChatCore {
  FirebaseChatCore._privateConstructor() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      firebaseUser = user;
    });
  }

  /// Config to set custom names for rooms and users collections. Also
  /// see [FirebaseChatCoreConfig].
  FirebaseChatCoreConfig config = const FirebaseChatCoreConfig(
    'rooms',
    'users',
  );

  /// Current logged in user in Firebase. Does not update automatically.
  /// Use [FirebaseAuth.authStateChanges] to listen to the state changes.
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  /// Singleton instance
  static final FirebaseChatCore instance =
  FirebaseChatCore._privateConstructor();

  /// Sets custom config to change default names for rooms
  /// and users collections. Also see [FirebaseChatCoreConfig].
  void setConfig(FirebaseChatCoreConfig firebaseChatCoreConfig) {
    config = firebaseChatCoreConfig;
  }

  /// Creates a chat group room with [users]. Creator is automatically
  /// added to the group. [name] is required and will be used as
  /// a group name. Add an optional [imageUrl] that will be a group avatar
  /// and [metadata] for any additional custom data.
  Future<types.Room> createGroupRoom({
    String? imageUrl,
    Map<String, dynamic>? metadata,
    required String name,
    required List<types.User> users,
  }) async {
    if (firebaseUser == null) return Future.error('User does not exist');

    final currentUser = await fetchUser(
      firebaseUser!.uid,
      config.usersCollectionName,
    );

    final roomUsers = [types.User.fromJson(currentUser)] + users;

    final room = await FirebaseFirestore.instance
        .collection(config.roomsCollectionName)
        .add({
      'createdAt': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
      'metadata': metadata,
      'name': name,
      'type': types.RoomType.group.toShortString(),
      'updatedAt': FieldValue.serverTimestamp(),
      'userIds': roomUsers.map((u) => u.id).toList(),
      'userRoles': roomUsers.fold<Map<String, String?>>(
        {},
            (previousValue, user) =>
        {
          ...previousValue,
          user.id: user.role?.toShortString(),
        },
      ),
    });

    return types.Room(
      id: room.id,
      imageUrl: imageUrl,
      metadata: metadata,
      name: name,
      type: types.RoomType.group,
      users: roomUsers,
    );
  }

  /// Creates a direct chat for 2 people. Add [metadata] for any additional
  /// custom data.
  Future<types.Room> createRoom(types.User? otherUser, {
    Map<String, dynamic>? metadata,
  }) async {
    final fu = firebaseUser;

    if (fu == null) return Future.error('User does not exist');
    if (otherUser == null) return Future.error('User does not exist');

    final query = await FirebaseFirestore.instance
        .collection(config.roomsCollectionName)
        .where('userIds', arrayContains: fu.uid)
        .get();

    final rooms = // err here IDK Y.
      await processRoomsQuery(fu, query, config.usersCollectionName);

    try {

      return rooms.firstWhere((room) {
        if (room.type == types.RoomType.group) return false;

        final userIds = room.users.map((u) => u.id);
        return userIds.contains(fu.uid) && userIds.contains(otherUser.id);
      });
    } catch (e) {
      // Do nothing if room does not exist
      // Create a new room instead
    }

    final currentUser = await fetchUser(
      fu.uid,
      config.usersCollectionName,
    );

    final users = [types.User.fromJson(currentUser), otherUser];

    final room = await FirebaseFirestore.instance
        .collection(config.roomsCollectionName)
        .add({
      'createdAt': FieldValue.serverTimestamp(),
      'imageUrl': null,
      'metadata': metadata,
      'name': null,
      'type': types.RoomType.direct.toShortString(),
      'updatedAt': FieldValue.serverTimestamp(),
      'userIds': users.map((u) => u.id).toList(),
      'userRoles': null,
    });

    return types.Room(
      id: room.id,
      metadata: metadata,
      type: types.RoomType.direct,
      users: users,
    );
  }

  /// Creates [types.User] in Firebase to store name and avatar used on
  /// rooms list
  Future<void> createUserInFirestore(types.User user) async {
    var createUser = await FirebaseFirestore.instance
        .collection(config.usersCollectionName)
        .doc(user.id)
        .set({
      'createdAt': FieldValue.serverTimestamp(),
      'firstName': user.firstName,
      'imageUrl': user.imageUrl,
      'lastName': user.lastName,
      'lastSeen': user.lastSeen,
      'metadata': user.metadata,
      'role': user.role?.toShortString(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge:true),);
  }

  /// Removes [types.User] from `users` collection in Firebase
  Future<void> deleteUserFromFirestore(String userId) async {
    await FirebaseFirestore.instance
        .collection(config.usersCollectionName)
        .doc(userId)
        .delete();
  }

  /// Returns a stream of messages from Firebase for a given room
  Stream<List<types.Message>> messages(
      types.Room room,
      {types.User? currentUser,
      bool rilHome = false}) {

    // final currentUser = await fetchUser(
    //   firebaseUser!.uid, 'users');

    int minAge = 0; // placeHolder only.
    int maxAge = 0; // placeHolder only.
    // print('What message() get as currentUser Json ${currentUser?.toJson()}');

    if(rilHome) {
      int currentUserAge = (currentUser?.metadata?['age'] ?? 0).toInt();
      // var ageFilter = 3; //{14 [17] 20}
      minAge = currentUserAge - my.config.app.ageFilter; // ?? 14;
      maxAge = currentUserAge + my.config.app.ageFilter; // ?? 20;
    }
    // bool inAgeRange = authorAge >= minAge && authorAge <= maxAge;

    List<types.Message> fetchSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot){
      return snapshot.docs.fold<List<types.Message>>(
        [], (previousValue, doc) {
          final data = doc.data();
          // print('DOC DATA A - Whats Stream get $data');

          // data.removeWhere((key, value) => key == 'authorPhotoURL' || key == 'authorDisplayName');
          data['metadata'] = data['author'];

          final author = room.users.firstWhere(
                (u) => u.id == data['authorId'],
            orElse: () => types.User(id: data['authorId'] as String),
          );
          data['author'] = author.toJson();
          data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;
          data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
          data['id'] = doc.id;

          var myNewList = [...previousValue, types.Message.fromJson(data)];
          //~ Remove posts from blockedUsers
          List? blockedUsers = currentUser?.metadata?['blockedUsers'];
          if(blockedUsers != null && rilHome){
            for (var blckUserId in blockedUsers) {
              myNewList.removeWhere((msg) => msg.author.id == blckUserId);
            }}

          //~ Sort posts by createdAt
          myNewList.sort((oldMsg, newMsg) =>
              newMsg.createdAt!.toDouble()
              .compareTo(oldMsg.createdAt!.toDouble()));

          // Todo: Currently this is INSTEAD createdAt
          //~ Move reported posts to Top for Moderators
          if(my.config.app.isModerator
              && my.config.app.moderatorMode.value) {
            myNewList.sort((msg1, msg2) {
              bool isMsg1Reported;
              bool isMsg2Reported;
              isMsg1Reported =
                  msg1.metadata?['metadata']['msgReported'] ?? false;
              isMsg2Reported =
                  msg2.metadata?['metadata']['msgReported'] ?? false;

              int result = '$isMsg2Reported'.compareTo('$isMsg1Reported');
              return result;
            });
          }

          return myNewList; // clean phase 2
        },
        // print('DOC DATA IS A $data');
      );
    }

    return
      rilHome && my.config.app.moderatorMode.value == false ?
          //~ ---------------- only for Ril Home
        FirebaseFirestore.instance
          .collection('${config.roomsCollectionName}/${room.id}/messages')
              .where('author.metadata.age',
                  isGreaterThanOrEqualTo: minAge,
                  isLessThanOrEqualTo: maxAge)
              // .orderBy('author.metadata', descending: true)
              .limit(100) // only 100 msgs
          .snapshots().map((snapshot) => fetchSnapshot(snapshot))
          //~ ---------------- only for Ril Home

      : FirebaseFirestore.instance
        .collection('${config.roomsCollectionName}/${room.id}/messages')
        .snapshots().map((snapshot) => fetchSnapshot(snapshot));
  }

  /// Returns a stream of changes in a room from Firebase
  Stream<types.Room>? room(String roomId) {
    final fu = firebaseUser;
    // print('what room() fu $fu');
    // print('what room() roomId $roomId');
    if (fu == null) return const Stream.empty();

    var room = FirebaseFirestore.instance
        .collection(config.roomsCollectionName)
        .doc(roomId)
        .snapshots()
        .asyncMap(
          (doc) {
            // print('what room() doc ${doc.data()}');
            return
              processRoomDocument(doc, fu, config.usersCollectionName);
          },
    );
    return room;
  }

  /// Returns a stream of rooms from Firebase. Only rooms where current
  /// logged in user exist are returned. [orderByUpdatedAt] is used in case
  /// you want to have last modified rooms on top, there are a couple
  /// of things you will need to do though:
  /// 1) Make sure `updatedAt` exists on all rooms
  /// 2) Write a Cloud Function which will update `updatedAt` of the room
  /// when the room changes or new messages come in
  /// 3) Create an Index (Firestore Database -> Indexes tab) where collection ID
  /// is `rooms`, field indexed are `userIds` (type Arrays) and `updatedAt`
  /// (type Descending), query scope is `Collection`
  Stream<List<types.Room>> rooms({bool orderByUpdatedAt = false}) {
    final fu = firebaseUser;
    if (fu == null) return const Stream.empty();

    print('rooms A');

    final collection = orderByUpdatedAt
        ? FirebaseFirestore.instance
        .collection(config.roomsCollectionName)
        .orderBy('updatedAt', descending: true)
        : FirebaseFirestore.instance
        .collection(config.roomsCollectionName)
        .where('userIds', arrayContains: fu.uid);

    /*    List<QueryDocumentSnapshot<Map<String, dynamic>>> cleanDocs = [];
    snapShots.forEach((snapShot) {
      for (var doc in snapShot.docs) {
        List uIds = doc.data()['userIds'];
        if(uIds[0] != uIds[1]){
          cleanDocs.add(doc);
        }
      }
    });*/

    return collection.snapshots().asyncMap(
          (query) =>
          processRoomsQuery(
            fu,
            query,
            config.usersCollectionName,
          ),
    );
  }

  /// Sends a message to the Firestore. Accepts any partial message and a
  /// room ID. If arbitraty data is provided in the [partialMessage]
  /// does nothing.
  void sendMessage(dynamic partialMessage, String roomId,
      {types.User? myAuthUser}) async {
    print('Start sendMessage() with my firebase_chat_core.dart');

    if (firebaseUser == null) return;

    types.Message? message;

    if (partialMessage is types.PartialCustom) {
      message = types.CustomMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialCustom: partialMessage,
      );
    } else if (partialMessage is types.PartialFile) {
      message = types.FileMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialFile: partialMessage,
      );
    } else if (partialMessage is types.PartialImage) {
      message = types.ImageMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialImage: partialMessage,
      );
    } else if (partialMessage is types.PartialText) {
      message = types.TextMessage.fromPartial(
        author: myAuthUser ??
                  types.User(
                      id: firebaseUser!.uid,
                      imageUrl: firebaseUser?.photoURL, // my
                      firstName: firebaseUser?.displayName,
                    ), // my
        id: '',
        partialText: partialMessage,
      );
      // print('Message B: ${message.toJson()}');
    }

    if (message != null) {
      var messageMap = message.toJson();
      // messageMap.removeWhere((key, value) => key == 'author' || key == 'id');

      messageMap['authorDisplayName'] = firebaseUser!.displayName;
      messageMap['authorPhotoURL'] = firebaseUser!.photoURL;

      messageMap['authorId'] = firebaseUser!.uid;
      messageMap['createdAt'] = FieldValue.serverTimestamp();
      messageMap['updatedAt'] = FieldValue.serverTimestamp();

      // ----------------- Add author
      // Todo save api call by just adding name & photo to the message metadata
      /*var getUser = *//*await*//* FirebaseFirestore.instance.collection(
          'users').doc(msg.author.id).get()
          .then((value) =>
      msg = msg.copyWith(metadata: value.data()
      )
      );
      print('msg.tpJson');
      print(msg.toJson());*/

      // messageMap = {'messageMap' : messageMap};

      print('sendMessage() B');
      // Todo combine to 1 request
      await FirebaseFirestore.instance.collection('rooms/$roomId/messages').add(messageMap);
      if(roomId != 'ClZEotxQ0ybSVlNykN0e') { // AKA RilHome
        await FirebaseFirestore.instance
            .doc('rooms/$roomId')
            .set({
          'metadata': {
            'unreadCountFrom_${firebaseUser?.uid.substring(0, 5)}': FieldValue.increment(1),
            'last_messageTxt' : '${message.toJson()['text']}'
          }
          // 'metadata': {'X': 1}
        }, SetOptions(merge:true),)/*.catchError(print)*/;
      }
      print('sendMessage() C');
    }
  }

  /// Updates a message in the Firestore. Accepts any message and a
  /// room ID. Message will probably be taken from the [messages] stream.
  void updateMessage(types.Message message, String roomId) async {
    if (firebaseUser == null) return;
    if (message.author.id != firebaseUser!.uid) return;

    final messageMap = message.toJson();
    messageMap.removeWhere(
            (key, value) =>
        key == 'author' || key == 'createdAt' || key == 'id');
    messageMap['authorId'] = message.author.id;
    messageMap['updatedAt'] = FieldValue.serverTimestamp();

    await FirebaseFirestore.instance
        .collection('${config.roomsCollectionName}/$roomId/messages')
        .doc(message.id)
        .update(messageMap);
  }

  /// Returns a stream of all users from Firebase
  Stream<List<types.User>> users() {
    if (firebaseUser == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection(config.usersCollectionName)
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.fold<List<types.User>>(
            [],
                (previousValue, doc) {
              if (firebaseUser!.uid == doc.id) return previousValue;

              final data = doc.data();

              data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
              data['id'] = doc.id;
              data['lastSeen'] = data['lastSeen']?.millisecondsSinceEpoch;
              data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

              return [...previousValue, types.User.fromJson(data)];
            },
          ),
    );
  }
}
