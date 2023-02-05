import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_listener/sms_listener.dart';
import '../packages/http_requests.dart';
import '../shared/constraints.dart';
import '../widgets/info.dart';
import '../widgets/loading.dart';
import '../widgets/toast.dart';
import 'incoming/auto_replies.dart';

@pragma('vm:entry-point')
void smsIsolate(String arg) async {
  SmsListener listener = SmsListener();
  listener.onReceive((Message newMessage) {
    print("message: ${newMessage.message} sender: ${newMessage.sender}");
    Toast.showToast(msg: "message: ${newMessage.message} sender: ${newMessage.sender}");


  }, errorCallback: (PlatformException exception) {

  });

  HttpRequests.headers["Authorization"] = "Bearer $arg";

  String sms        = 'no sms received';
  String? sender    = 'no sms received';
  bool hasSplit     = false;
  String time       = 'no sms received';

  String message    = "";
  // String? body     = sms.body;
  // String? sender  = sms.address;
  // int? nTime    = sms.date;

  try{
    sender    = sender?.split('+')[1];
    hasSplit  = true;
  }catch(e){
    hasSplit = false;
  }

  if(hasSplit) {
    // DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(nTime!);
    Map<String, dynamic> data = {
      'sender': sender,
      'sms':    message,
      // 'time':   dateTime,
    };
    print(data);
    // HttpRequests.post(uri: "/interact", data: data).then((value) {
    //   Response response = value;
    //   var body = json.decode(response.body);
    //   Toast.showToast(msg: body['message']);
    // });
  }else{
    Toast.showToast(msg: "Sender ID is not in numbers.");
  }


  // plugin.read();
  // plugin.smsStream.listen((event) {print("mesage: ${event.body} sender: ${event.sender}");
  //   //Used to handle preceeding segments to wait if this incoming message is longer than 160 characters and comes in segments
  //   //canDispatch = false;
  //
  //   sms     = event.body;
  //   sender  = event.sender;
  //   time    = event.timeReceived.toString();
  //
  //   try{
  //     sender    = sender?.split('+')[1];
  //     hasSplit  = true;
  //   }catch(e){
  //     hasSplit = false;
  //   }
  //
  //   if(hasSplit) {
  //     //Concatenates segments of a long message if it exists
  //     message += sms;
  //     // queuedSender = sender;
  //     // Timer(const Duration(microseconds: 0,), () {
  //     //   //After waiting long message segments allow to dispatch to the server
  //     //   canDispatch = true;
  //     //
  //     //   //This ensures second and more segments messages are to dispatched because they become empty after they concatenated to the preceding segments
  //     //   if(canDispatch && (message != "")){
  //     //     Map<String, dynamic> data = {
  //     //       'sender': sender,
  //     //       'sms':    message,
  //     //       'time':   time,
  //     //     };
  //     //     //We set it to empty string because we want to avoid concatenating preceding messages with other senders messages
  //     //     message = "";
  //     //
  //     //     HttpRequests.post(uri: "/interact", data: data).then((value) {
  //     //       Response response = value;
  //     //       var body = json.decode(response.body);
  //     //       Toast.showToast(msg: body['message']);
  //     //     });
  //     //     //After dispatching messages we need ensure no other messages can be dispatched unless they are verified after a millisecond
  //     //     canDispatch = false;
  //     //   }
  //     // });
  //   }else{
  //     Toast.showToast(msg: "Sender ID is not in numbers.");
  //   }
  // });
}

// @pragma('vm:entry-point')
// void handleBackgroundSms(SmsMessage sms){
//   Toast.showToast(msg: "Background: ${HttpRequests.token}");
// }

class Incoming extends StatefulWidget{
  @override
  State<Incoming> createState() => _Home();
  Incoming({Key? key, required this.toggleAuth}) : super(key: key);

  final formKey = GlobalKey<FormState>();
  final Function toggleAuth;
}

class _Home extends State<Incoming> with TickerProviderStateMixin{
  //Instances
  // final telephony = Telephony.instance;
  static late SharedPreferences _sharedPreferences;

  String display = "dashboard";
  String show = "Feed";
  String _progressMsg = "";
  bool _isLoading = false;
  bool _isReceivingSMS = false;

  Map<String, dynamic> resData = {};

  void setHome(){
    setState(() {
      display = "dashboard";
    });
  }

  List<dynamic> senders = <dynamic>[];
  List<dynamic> _currentSender = [];
  String _senderName = "";

  bool _hasLoaded = false;

  //Post data
  int _selectedSender = 0;

  Future<bool> getPermission() async {
    if (await Permission.sms.status == PermissionStatus.granted) {
      return true;
    } else {
      if (await Permission.sms.request() == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  late FlutterIsolate smsProcess;
  bool hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _getSharedPreferences();
    getPermission().then((value) async {
      if(value){
        hasPermissions = value;
        if(_isReceivingSMS && hasPermissions){
          String token = HttpRequests.token;
          smsProcess = await FlutterIsolate.spawn(smsIsolate, token);


        }
      }
    });
  }

  void _getSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    try{
      _isReceivingSMS = _sharedPreferences.getBool("receives")!;
    }catch(e){
      _sharedPreferences.setBool("receives", false);
    }
  }

  Future<void> _getSenders() async {
    Response response = await HttpRequests.get(uri: '/senders/list');
    resData = json.decode(response.body);
    resData = resData['data'];
    _currentSender = resData['current_sender'];

    senders.clear();
    senders.addAll(resData['senders']);

    if(_currentSender.isEmpty){
      _senderName = 'No sender ID attached.';
    }else{
      for(var sender in senders){
        if(sender['id'] == _currentSender[0]['sender_id']){
          _senderName = sender['sender_id'];
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!_hasLoaded) {
      _getSenders().then((value) {
        setState(() => _hasLoaded = true);
      });
    }

    return DefaultTabController(
        length: 3,
        initialIndex: 1,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("VLL SMS"),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  setState(() {
                    _isLoading = !_isLoading;
                    _progressMsg = "Logging out!";
                  });
                  await HttpRequests.get(uri: "/logout");

                  widget.toggleAuth();
                  setState(() {
                    _isLoading = !_isLoading;
                  });
                },
              )
            ],
          ),
          body: (_isLoading)?Loading(msg: _progressMsg,):
          TabBarView(
            children: [
              Center(
                child: Text(
                  display,
                  style: const TextStyle(
                      fontSize: h3
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Form(
                      key: widget.formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Center(
                            child: Text(_senderName,
                              style: const TextStyle(
                                  fontSize: h3,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          DropdownButtonFormField(
                            decoration: const InputDecoration(
                              label: Text("Sender IDs"),
                              hintText: "Bind sender ID to mobile number.",
                            ),
                            items: senders.map((sender) {
                              return DropdownMenuItem(
                                value: sender['id'],
                                child: Text(sender['sender_id']),
                              );
                            }).toList(),
                            validator: (val){
                              if(val == null){
                                return "Please select sender ID.";
                              }

                              return null;
                            },
                            onChanged: (val){
                              _selectedSender = int.parse(val.toString());
                            },
                          ),
                          const SizedBox(height: vGap,),
                          ElevatedButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(const EdgeInsets.fromLTRB(100.0, 15.0, 100.0, 15.0))
                              ),
                              onPressed: () async {
                                if(widget.formKey.currentState!.validate()){
                                  setState((){
                                    _progressMsg = "Attaching sender ID to your number.";
                                    _isLoading = true;
                                    _hasLoaded = false;
                                  });

                                  Map<String, dynamic> payLoad = {
                                    'sender_id': _selectedSender
                                  };

                                  Response response = await HttpRequests.post(uri: '/sender-pointers/bind', data: payLoad);
                                  resData = json.decode(response.body);

                                  if(response.statusCode == 200){
                                    _progressMsg = resData['message'];
                                  }
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }

                              },
                              child: const Text("BIND")
                          )
                        ],
                      ),
                    ),
                    Center(
                      child: ElevatedButton(
                        child: (_isReceivingSMS)?const Text("Stop Receiving"):const Text("Receive SMS"),
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                            _progressMsg = "We're booting up.";
                          });

                          if(_currentSender.isNotEmpty){
                            _isReceivingSMS = !_isReceivingSMS;
                            _sharedPreferences.setBool("receives", _isReceivingSMS);

                            if(_isReceivingSMS && hasPermissions){
                              String msg = "VLL App has started listening to SMS in the background.";
                              String token = HttpRequests.token;
                              smsProcess = await FlutterIsolate.spawn(smsIsolate, token);
                              Toast.showToast(msg: msg);
                            }else{
                              smsProcess.kill();
                            }
                          }else{
                            _progressMsg = "Please attach sender ID to this account.";
                            SnackBar snackBar = Info.snackBar(_progressMsg);
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }

                          setState(() {
                            _isLoading = false;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              AutoReplies()
            ],
          ),
          bottomNavigationBar: const Material(
            child: TabBar(
              tabs: [
                Tab(
                  child: Text("Incoming"),
                ),
                Tab(
                  child: Text("Bind"),
                ),
                Tab(
                  child: Text("Auto-replies"),
                )
              ],
            ),
          ),
        )
    );
  }
}
