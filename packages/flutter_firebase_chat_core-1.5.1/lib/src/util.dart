import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

/// Extension with one [toShortString] method
extension RoleToShortString on types.Role {
  /// Converts enum to the string equal to enum's name
  String toShortString() {
    return toString().split('.').last;
  }
}

/// Extension with one [toShortString] method
extension RoomTypeToShortString on types.RoomType {
  /// Converts enum to the string equal to enum's name
  String toShortString() {
    return toString().split('.').last;
  }
}

/// Fetches user from Firebase and returns a promise
Future<Map<String, dynamic>> fetchUser(
  String userId,
  String usersCollectionName, {
  String? role,
}) async {
  final doc = await FirebaseFirestore.instance
      .collection(usersCollectionName)
      .doc(userId)
      .get();

  // FirebaseFirestore.instance.snapshotsInSync();

  // if(doc.data() == null) return {}; // my null safety
  if(doc.data() == null){
    print('Check this: fetchUser() gets $userId');
    print('Check this: ${doc.id}');
  }
  final data = doc.data()!;

  data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
  data['id'] = doc.id;
  data['lastSeen'] = data['lastSeen']?.millisecondsSinceEpoch;
  data['role'] = role;
  data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

  return data;
}

/// Returns a list of [types.Room] created from Firebase query.
/// If room has 2 participants, sets correct room name and image.
Future<List<types.Room>> processRoomsQuery(
  User firebaseUser,
  QuerySnapshot<Map<String, dynamic>> query,
  String usersCollectionName,
) async {
  print('processRoomsQuery A');

  var futures = query.docs.map(
    (doc) => processRoomDocument(
      doc,
      firebaseUser,
      usersCollectionName,
    ),
  );
  // futures.skipWhile((doc) => false);

  return await Future.wait(futures);

}

/// Returns a [types.Room] created from Firebase document
Future<types.Room> processRoomDocument(
  DocumentSnapshot<Map<String, dynamic>> doc,
  User firebaseUser,
  String usersCollectionName,
) async {
  final data = doc.data()!;
  print('processRoomDocument A');


  data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
  data['id'] = doc.id;
  data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

  var imageUrl = data['imageUrl'] as String?;
  var name = data['name'] as String?;
  final type = data['type'] as String;
  final userIds = data['userIds'] as List<dynamic>;
  final userRoles = data['userRoles'] as Map<String, dynamic>?;

  // print('Come on A!');
  // userIds.forEach((userId) {print(userId); });

  final users = await Future.wait(
    userIds.map(
      (userId) {
        print('Current UID: $userId');
        Future<Map<String, dynamic>> fetchedUser;
          fetchedUser = fetchUser(
            userId as String,
            usersCollectionName,
            role: userRoles?[userId] as String?,
          ).catchError((doc){
            return fetchUser(
              'RtGHUgiIP5b5jkag1sYPo7tg0nD2', // AKA Riltopia Team user.
              'users',
              role: userRoles?[userId] as String?,
            );
          });

        // print('fetchedUser');
        // print(fetchedUser);
        return fetchedUser;
      }
    ),
  );
  // users.forEach((user) {print('user: $user'); });

  if (type == types.RoomType.direct.toShortString()) {
    try {
      final otherUser = users.firstWhere(
        (u) => u['id'] != firebaseUser.uid,
      );

      imageUrl = otherUser['imageUrl'] as String?;
      name = '${otherUser['firstName'] ?? ''} ${otherUser['lastName'] ?? ''}'
          .trim();
    } catch (e) {
      // Do nothing if other user is not found, because he should be found.
      // Consider falling back to some default values.

      // "Uncaught Error: Bad state: No element" Safety
      // print('EE $e');

    }
  }

  data['imageUrl'] = imageUrl;
  data['name'] = name;
  data['users'] = users;

  if (data['lastMessages'] != null) {
    final lastMessages = data['lastMessages'].map((lm) {
      final author = users.firstWhere(
        (u) => u['id'] == lm['authorId'],
        orElse: () => {'id': lm['authorId'] as String},
      );

      lm['author'] = author;
      lm['createdAt'] = lm['createdAt']?.millisecondsSinceEpoch;
      lm['id'] = lm['id'] ?? '';
      lm['updatedAt'] = lm['updatedAt']?.millisecondsSinceEpoch;

      return lm;
    }).toList();

    data['lastMessages'] = lastMessages;
  }

  return types.Room.fromJson(data);
}
