import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import '../packages/http_requests.dart';
import '../shared/constraints.dart';
import '../widgets/info.dart';
import '../widgets/loading.dart';
import '../widgets/toast.dart';
import 'incoming/auto_replies.dart';

class Incoming extends StatefulWidget{
  @override
  State<Incoming> createState() => _Home();
  Incoming({Key? key, required this.toggleAuth}) : super(key: key);

  final formKey = GlobalKey<FormState>();
  final Function toggleAuth;
}

class _Home extends State<Incoming> with TickerProviderStateMixin{
  //Instances
  final telephony = Telephony.instance;
  static late SharedPreferences _sharedPreferences;

  String display = "dashboard";
  String show = "Feed";
  String _progressMsg = "";
  bool _isLoading = false;
  static bool _isReceivingSMS = false;

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

  void initTelephonyInstance() async {
    getPermission().then((value){
      if(value){
        telephony.listenIncomingSms(
            onNewMessage: foregroundMessage,
            onBackgroundMessage: backgroundMessage,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getSharedPreferences();
    initTelephonyInstance();
  }

  void _getSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    try{
      _isReceivingSMS = _sharedPreferences.getBool("receives")!;
    }catch(e){
      _sharedPreferences.setBool("receives", false);
    }
  }

  static void _receiveSMS(SmsMessage receivedSms) async {
    var shared = await SharedPreferences.getInstance();
    bool isReceiving = false;

    try{
      isReceiving = shared.getBool("receives")!;
    }catch(e){
      isReceiving = false;
      shared.setBool("receives", isReceiving);
    }

    print(isReceiving);

    String? sms       = 'no sms received';
    String? sender    = 'no sms received';
    int? time         = 0;

    sms     = receivedSms.body;
    bool hasSplit = false;
    try{
      sender  = receivedSms.address?.split('+')[1];
      hasSplit = true;
    }catch(e){
      hasSplit = false;
    }

    time    = receivedSms.date;
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time!);

    Map<String, dynamic> data = {
      'sender': sender,
      'sms':    sms,
      'time':   dateTime.toString(),
    };

    if(hasSplit) {
      HttpRequests.prepareGateway();
      HttpRequests.checkAuth().then((value) {
        if(value){
          HttpRequests.post(uri: "/interact", data: data).then((value) {
            Response response = value;
            var body = json.decode(response.body);
            Toast.showToast(msg: body['message']);
          });
        }
      });
    }
  }

  static void foregroundMessage(SmsMessage sms) {
    if(_isReceivingSMS){
      _receiveSMS(sms);
    }
    print("foreground");
  }

  static void backgroundMessage(SmsMessage sms) {
    _receiveSMS(sms);
    print("background");
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
                        onPressed: (){
                          setState(() {
                            if(_currentSender.isNotEmpty){
                              _isReceivingSMS = !_isReceivingSMS;
                              _sharedPreferences.setBool("receives", _isReceivingSMS);
                            }else{
                              _progressMsg = "Please attach sender ID to this account.";
                              SnackBar snackBar = Info.snackBar(_progressMsg);
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
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
