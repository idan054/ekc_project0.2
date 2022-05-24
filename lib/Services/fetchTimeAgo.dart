import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

String fetchTimeAgo(intDate, {bool numericDates = true}) {
  // print('intDate: $intDate');
  var date = DateTime.fromMicrosecondsSinceEpoch(intDate * 1000);
  // print('date: $date');

  final date2 = DateTime.now();
  final difference = date2.difference(date);

  if ((difference.inDays / 7).floor() >= 1) {
    // return (numericDates) ? '1 week ago' : 'Last week';
    return (numericDates) ? ' שבוע' : 'שבוע שעבר';
  } else if (difference.inDays >= 2) {
    // return '${difference.inDays} days ago';
    return '${difference.inDays} ימים ';
  } else if (difference.inDays >= 1) {
    // return (numericDates) ? '1 day ago' : 'Yesterday';
    return (numericDates) ? ' יום' : 'אתמול';
  } else if (difference.inHours >= 2) {
    // return '${difference.inHours} hours ago';
    return '${difference.inHours} שעות';
  } else if (difference.inHours >= 1) {
    // return (numericDates) ? '1 hour ago' : 'An hour ago';
    return (numericDates) ? ' שעה' : 'לפני שעה';
  } else if (difference.inMinutes >= 2) {
    // return '${difference.inMinutes} minutes ago';
    return '${difference.inMinutes} דקות ';
  } else if (difference.inMinutes >= 1) {
    // return (numericDates) ? '1 minute ago' : 'A minute ago';
    return (numericDates) ? ' דקה' : 'לפני דקה';
  } else if (difference.inSeconds >= 3) {
    // return '${difference.inSeconds} seconds ago';
    return '${difference.inSeconds} שניות ';
  } else {
    // return 'Just now';
    // return 'בדיוק הרגע';
    return 'רגע';
  }
}
