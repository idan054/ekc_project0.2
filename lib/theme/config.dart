import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter/foundation.dart';
var config = Config();

//~ Require Hot restart!
class Config {
  var design = Design() ;
  var debug = Debug() ;
  var app = App() ;
}

class App {
  int ageFilter = 3; // +-3, so 17 will meet 14 - 20.
  bool isModerator = false;
  var moderatorMode = ValueNotifier<bool>(false);
  types.User? riltopiaTeamUser;
  types.Room? riltopiaTeamRoom;
}

class Design {
  bool isPostStyle = true; // rilHome look like facebook (or whatsapp)?
  bool showTabBarTitles = false; // on AppBar
  bool cMinimizeIndicator = true; // on AppBar
}

class Debug {
  bool alwaysSignup = kDebugMode && false;
}

// ? CTRL + F: Outside Lib folder:
//~ Hot to use ValueNotifier:
// 1 make a void that change the val by val.value
// 2 change type to ValueNotifier
// 3 add ValueListenableBuilder
// bool moderatorMode = false; // Moderator can disable it by switch

