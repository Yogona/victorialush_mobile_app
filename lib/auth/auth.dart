import 'package:flutter/material.dart';
import 'package:vll_mobile_app/auth/register.dart';
import 'login.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key, required this.toggleAuth}) : super(key: key);

  final Function toggleAuth;

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> with TickerProviderStateMixin{

  bool _isLogin = true;
  double titleSize = 24.0;
  double iconSize = 30.0;

  void _swapAuth(){
    setState((){
      _isLogin = !_isLogin;
    });
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(
          left: 10.0, right: 10.0
        ),
        child: (_isLogin)?
        Login(toggleAuth: widget.toggleAuth, swapAuth: _swapAuth,):
        Register(toggleAuth: widget.toggleAuth, swapAuth: _swapAuth,),
      ),
    );
  }
}
