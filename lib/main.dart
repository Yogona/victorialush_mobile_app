import 'package:flutter/material.dart';
import 'package:vll_mobile_app/shared/colors.dart';
import 'package:vll_mobile_app/shared/themes.dart';
import 'package:vll_mobile_app/wrapper.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'VLL Mobile App',
    theme: ThemeData(
      primarySwatch: dominantColor,
      scaffoldBackgroundColor: const Color.fromRGBO(234, 234, 234, 1.0),
      appBarTheme: appBarTheme,
      inputDecorationTheme: inputDecorationTheme,
      elevatedButtonTheme: elevatedBtnTheme,
      textButtonTheme: textBtnTheme,
      listTileTheme: listTileTheme,
      tabBarTheme: tabBarTheme,
    ),
    home: const Wrapper(),
  ));
}

