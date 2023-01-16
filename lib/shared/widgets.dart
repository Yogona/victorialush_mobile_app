import 'package:flutter/material.dart';

import 'colors.dart';

const divider = Divider(
  color: primaryColor,
  thickness: 2,
);

const btnShadow = [
  BoxShadow(
      color: Colors.grey,
      blurRadius: 2,
      spreadRadius: 2
  )
];

var yellowBtnDecoration = BoxDecoration(
  boxShadow: btnShadow,
  borderRadius: BorderRadius.circular(5.0),
  gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.lightGreen.shade200,
        Colors.yellowAccent,
        Colors.lightGreen.shade200,
      ]
  ),
);
var yellowBtnStyle = ButtonStyle(
  //backgroundColor: MaterialStateProperty.all(Colors.yellowAccent),
  foregroundColor: MaterialStateProperty.all(Colors.black),
  shape: MaterialStateProperty.all(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0)
  )),
  padding: MaterialStateProperty.all(const EdgeInsets.only(
      left: 30,right: 30
  ))
);

var blueBtnDecoration = BoxDecoration(
  boxShadow: btnShadow,
  borderRadius: BorderRadius.circular(5.0),
  gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.blue,
        primaryColor,
        Colors.blue,
      ]
  ),
);
var blueBtnStyle = ButtonStyle(
  //backgroundColor: MaterialStateProperty.all(primaryColor),
  foregroundColor: MaterialStateProperty.all(minorColor),
  shape: MaterialStateProperty.all(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0)
  )),
);