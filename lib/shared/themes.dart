import 'package:flutter/material.dart';

import 'colors.dart';

const appBarTheme = AppBarTheme(
  foregroundColor: Colors.white
);

const tabBarTheme = TabBarTheme(
  //indicator:
  labelColor: Colors.red,
  unselectedLabelColor: Colors.grey
);

const iconThemeData = IconThemeData(
  color: Colors.white,
  size: 10.0
);

const listTileTheme = ListTileThemeData(
  tileColor: Colors.white
);

var elevatedBtnTheme = ElevatedButtonThemeData(
  style: ButtonStyle(
    backgroundColor:  MaterialStateProperty.all(dominantColor),
    foregroundColor: MaterialStateProperty.all(Colors.white),
    shape: MaterialStateProperty.all(const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50.0))
    )),
  )
);

var textBtnTheme = TextButtonThemeData(
  style: ButtonStyle(
    foregroundColor: MaterialStateProperty.all(minorColor),
  ),
);

var defaultOutlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: const BorderSide(
      color: minorColor,
      width: 1.0
    )
);

var inputDecorationTheme = InputDecorationTheme(
  filled: true,
  fillColor: Colors.white,
  floatingLabelStyle: const TextStyle(
    color: Colors.black
  ),
  border: defaultOutlineBorder,
  contentPadding: const EdgeInsets.only(
      top: 0.0, bottom: 0.0, left: 10.0
  ),
  // errorBorder: defaultOutlineBorder.copyWith(
  //   borderSide: const BorderSide(
  //     color: Colors.red
  //   )
  // ),
  focusedBorder: defaultOutlineBorder.copyWith(
    borderSide: const BorderSide(
      color: primaryColor,
    ),
  ),
  enabledBorder: defaultOutlineBorder,
);