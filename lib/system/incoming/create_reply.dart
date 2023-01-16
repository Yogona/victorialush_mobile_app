import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../packages/http_requests.dart';
import '../../shared/constraints.dart';
import '../../widgets/loading.dart';
import '../../widgets/toast.dart';

class CreateReply extends StatefulWidget {
  CreateReply({Key? key}) : super(key: key);

  final formKey = GlobalKey<FormState>();

  @override
  State<CreateReply> createState() => _CreateReplyState();
}

class _CreateReplyState extends State<CreateReply> {
  bool _isLoading = false;
  Map<String,dynamic> resData = {};

  List<dynamic> hoursList = [];
  List<dynamic> minutesList = [];

  String reply = "";
  String hours = "00";
  String minutes = "00";

  void _loadHours(){
    hoursList.clear();
    for(int index = 0; index < 24; ++index){
      hoursList.add(index);
    }
  }

  void _loadMinutes(){
    minutesList.clear();
    int index = 0;
    while( index < 60 ){
      minutesList.add(index);
      index += 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadHours();
    _loadMinutes();

    return (_isLoading)?const Loading(msg: "Creating a new reply."):Form(
      key: widget.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextFormField(
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: "Asante kwa kuwasiliana nasi, tutakurudia hivi punde.",
              label: Text(
                  "Reply"
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10
              )
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (val){
              if(val!.isEmpty){
                return "You should enter a reply.";
              }

              return null;
            },
            onSaved: (val){
              reply = val!;
            },
          ),
          const SizedBox(height: vGap,),

          Row(
            children: [
              Expanded(
                flex: 1,
                child: DropdownButtonFormField(
                    hint: const Text("Select Hour"),
                    items: hoursList.map((hour) {
                      // hours = hour;
                      // print(hour);
                      return  DropdownMenuItem(
                        value: hour,
                        child: Text(hour.toString()),
                      );
                    }).toList(),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (val){
                      if(val == null){
                        return "Please select hour.";
                      }
                      return null;
                    },
                    onChanged: (val){
                      if(int.parse(val.toString()) < 10){
                        hours = "0$val";
                      }else{
                        hours = val.toString();
                      }
                    }
                ),
              ),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField(
                    hint: const Text("Select Minutes"),
                    items: minutesList.map((minute) {

                      return  DropdownMenuItem(
                        value: minute,
                        child: Text(minute.toString()),
                      );
                    }).toList(),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (val){
                      if(val == null){
                        return "Please select minute.";
                      }
                      return null;
                    },
                    onChanged: (val){
                      if(int.parse(val.toString()) < 10){
                        minutes = "0$val";
                      }else{
                        minutes = val.toString();
                      }
                    }
                ),
              ),
            ],
          ),


          const SizedBox(height: vGap,),

          ElevatedButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20
              ))
            ),
            child: const Text("Create New Reply"),

            onPressed: () async {
              if(widget.formKey.currentState!.validate()){
                widget.formKey.currentState!.save();
                bool isConnected = await InternetConnectionChecker().hasConnection;

                if(isConnected){

                  setState(() {
                    _isLoading = !_isLoading;
                  });

                  Map<String, dynamic> data = {
                    "reply": reply,
                    "time_schedule": "$hours:$minutes",
                  };

                  Response response = await HttpRequests.post(uri: "/auto-replies/create", data: data);
                  resData = json.decode(response.body);
                  String msg = resData["message"];
                  Toast.showToast(msg: msg);
                  setState(() {
                    _isLoading = !_isLoading;
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
