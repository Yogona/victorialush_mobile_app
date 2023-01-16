import 'package:flutter/material.dart';

import '../shared/colors.dart';
class Info{
  static SnackBar snackBar(String msg){
    dynamic words = msg.split(" ");
    int duration = words.length;
    return SnackBar(
      backgroundColor: dominantColor,
      content: Text(msg),
      duration: Duration(seconds: duration),
      action: SnackBarAction(
        label: "Dismiss",
        onPressed: (){

        },
      ),
    );
  }
}