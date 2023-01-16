import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../packages/http_requests.dart';
import '../shared/colors.dart';
import '../shared/constraints.dart';
import '../widgets/loading.dart';
import '../widgets/toast.dart';

class Login extends StatefulWidget {
  Login({Key? key, required this.toggleAuth, required this.swapAuth}) : super(key: key);

  final Function toggleAuth;
  final Function swapAuth;

  final formKey = GlobalKey<FormState>();

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin{
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..animateTo(1.0);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  bool _isLoading = false;
  String _username = "";
  String _password = "";
  String _errMsg = "";
  Map<String, dynamic> _temp = {};

  @override
  Widget build(BuildContext context) {
    return (_isLoading)?const Loading(msg: "We are logging you in!"):
      FadeTransition(
        opacity: _animation,
        child: Form(
          key: widget.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    hintText: "id@domain.com",
                    label: Text(
                        "Username"
                    )
                ),
                validator: (val){
                  if(val!.isEmpty){
                    return "Username is required.";
                  }

                  return null;
                },
                onSaved: (val){
                  _username = val!;
                },
              ),

              const SizedBox(height: vGap,),

              TextFormField(
                decoration: const InputDecoration(
                    hintText: "Alpha numerics, 6 characters long.",
                    label: Text(
                        "Password"
                    )
                ),
                obscureText: true,
                validator: (val){
                  if(val!.isEmpty){
                    return "Password is required.";
                  }

                  return null;
                },
                onSaved: (val){
                  _password = val!;
                },
              ),

              (_errMsg.isEmpty)?const SizedBox():Center(
                child: Text(
                  _errMsg,
                  style: const TextStyle(
                    color: errColor,
                  ),
                ),
              ),

              const SizedBox(height: vGap,),

              ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.fromLTRB(100.0, 15.0, 100.0, 15.0))
                ),
                child: const Text("Sign in"),
                onPressed: () async {
                  if(widget.formKey.currentState!.validate()){
                    widget.formKey.currentState!.save();
                    bool isConnected = await InternetConnectionChecker().hasConnection;

                    if(isConnected){
                      setState(() {
                        //Flip to display progress indicator
                        _isLoading = !_isLoading;
                      });

                      Map<String, dynamic> data = {
                        "user_id":_username,
                        "password":_password
                      };

                      Response response = await HttpRequests.post(uri: "/client/login", data: data);

                      if(response.statusCode == 400){

                      }else{
                        data = json.decode(response.body);
                        if(response.statusCode == 200){

                          _temp = data["data"];
                          String token = _temp["token"];
                          SharedPreferences.getInstance().then((value){
                            value.setString("token", token);
                          });
                          HttpRequests.headers["Authorization"] = "Bearer $token";

                          _temp = _temp["user"];

                          widget.toggleAuth();
                        }else{
                          setState(() {
                            _errMsg = data["message"];
                          });
                        }
                      }

                      setState(() {
                        //Flip to remove progress indicator
                        _isLoading = !_isLoading;
                      });
                    }else{
                      Toast.showToast(msg: "No internet connection!");
                    }
                  }
                },
              ),

              // TextButton(
              //   child: const Text("Don't have an account?"),
              //
              //   onPressed: (){
              //     widget.swapAuth();
              //   },
              // ),
            ],
          ),
        ),
      );
  }
}
