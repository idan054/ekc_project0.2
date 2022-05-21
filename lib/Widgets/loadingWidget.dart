import 'package:ekc_project/theme/colors.dart';
import 'package:flutter/material.dart';

void showLoader(context) {
  // print('isShowLoader $isHideLoader');
  // isHideLoader = isHideLoader != isHideLoader;
  // print('isShowLoader $isHideLoader');
  showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        return loadingWidget(context);
      });
}
Widget loadingWidget(context, {bool myDark = false}) =>
  Center(
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color:
        myDark ?
          Colors.grey
        : Colors.white,
      ),
      height: 100,
      width: 100,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: myDark ?
          Colors.white
          : cRilPurple),
      ),
    ),
  );

