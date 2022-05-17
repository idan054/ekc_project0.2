
import 'package:flutter/foundation.dart';

/// Api config
bool myUseSample = false;
bool myCleanConfig = false;
const kStreamApiKey = 'ah48ckptkjvm';

// Demo
// const kStreamApiKey = 'wr4g7gb2388g';
// const kStreamUserId = 'tom';
// const kStreamToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoidG9tIn0._HkDWmGM3ItRXTLn9-s7N_8XBew_DxHBBH9eDHjRtP4';

/// App config (cp)
int cpAgeFilter = 3; // +-3, so 17 will meet 14 - 20.
bool cpIsLoading = false; // setState to hide

bool isModerator = false;
// 1 make a void that change the val by val.value // 2 change type to ValueNotifier // 3 add ValueListenableBuilder
ValueNotifier<bool> moderatorMode = ValueNotifier<bool>(false);
// bool moderatorMode = false; // Moderator can disable it by switch

/// Design (c)onfig
bool cShowTabBarTitles = false; // in Use - AppBar
bool cMinimizeIndicator = true; // in Use - AppBar
bool cShowChatsSearch = true; // Not embedded yet
bool cShowGroups = true; // Not embedded yet
bool cShowAgeAndPostLen = false;

/// Dev (debug)
bool devLogin = true; // auto set gender & bDay when סיום button clicked
bool showDebugPrints = true;
bool genderDebug = true; // false: fake New user mode.
bool cleanOnExitDebug = true; // true: exit button will erase user extraData
bool alwaysNewUserDebug = true && kDebugMode;

// ? CTRL + F: Outside Lib folder:
// ? var homeCooldown = 2 * 60;
// ? bool quickerSlowModeDebug = true; // true: x15 faster

