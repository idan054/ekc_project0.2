
import 'package:flutter/material.dart';

/// Shortcuts:

//~ Universal
Size kMediaQuerySize(context) => MediaQuery.of(context).size;
TextTheme kTextTheme(context) => Theme.of(context).textTheme;

//~ Provider shortcuts
// Provider models shortcuts
// UniModel kUniModel(context, {bool listen = false})
//             => Provider.of<UniModel>(context, listen: listen);

//~ Navigation shortcuts
NavigatorState kNavigator(context) => Navigator.of(context);
Future<dynamic> kPushNavigator(context, screen,{bool replace = false}) {
    // Fixing push replacement
    if (replace) Navigator.of(context).popUntil((route) => route.isFirst);
    return
        replace ?  Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => screen))
            :  Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => screen));
}

/*Future<dynamic> kPushProvider(context, {
  required ChangeNotifier? Function(BuildContext) model,
  required Widget Function(BuildContext context, Widget? child)? screen
}) =>
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) =>
            ChangeNotifierProvider(
                create: model,
                builder: screen)
        ));*/

