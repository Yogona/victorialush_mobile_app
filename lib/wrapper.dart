import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vll_mobile_app/shared/colors.dart';
import 'package:vll_mobile_app/shared/constants.dart';
import 'package:vll_mobile_app/system/incoming.dart';
import 'package:vll_mobile_app/widgets/loading.dart';
import 'auth/auth.dart';
import 'packages/http_requests.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> with TickerProviderStateMixin {
  // final androidConfig = FlutterBackgroundAndroidConfig(
  //   notificationTitle: "flutter_background example app",
  //   notificationText: "Background notification for keeping the example app running in the background",
  //   notificationImportance: AndroidNotificationImportance.Default,
  //   notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'), // Default is ic_launcher from folder mipmap
  // );

  bool _isAuth      = true;
  bool _showSplash  = true;
  bool _isLoading   = false;

  void _toggleAuth() {
    setState(() {
      _isAuth = !_isAuth;
    });
  }

  @override
  void initState() {
    super.initState();
    HttpRequests.prepareGateway();

    Future.delayed(
        const Duration(
          seconds: 10,
        ), () {
      setState(() {
        _showSplash = false;
        _isLoading  = true;
      });
    });
  }

  @override
  void dispose(){
    super.dispose();
    _logoController.dispose();
  }

  late final AnimationController _logoController = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
  )..animateTo(1);
  late final Animation<double> _logoAnim = CurvedAnimation(
    parent: _logoController,
    curve: Curves.fastOutSlowIn,
  );

  double _titleOpacity = 0.0;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      Timer(
        const Duration(seconds: 5),
        (){
          setState(() {
            _titleOpacity = 1.0;
          });
        }
      );

      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _logoAnim,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    logo,
                    width: 140,
                    height: 140,
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: _titleOpacity,
                duration: const Duration(seconds: 3),
                child: const SizedBox(
                  child: Text(
                    "Exceeding Expectations",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Georgina",
                      fontWeight: FontWeight.bold,
                      color: minorColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading){
      HttpRequests.checkAuth().then((val) {
        setState(() {
          _isAuth = !val;
          _isLoading = false;
        });
      });
      return const Scaffold(
        body: Center(
          child: Loading(
            msg: 'Authenticating...',
          ),
        ),
      );
    }

    if (_isAuth) {
      return Auth(toggleAuth: _toggleAuth);
    }

    return Incoming(toggleAuth: _toggleAuth);
  }
}
