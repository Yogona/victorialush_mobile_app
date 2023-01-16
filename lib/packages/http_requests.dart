import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/toast.dart';

class HttpRequests{
  static String token             = "";
  static const String _protocol   = "https://";
  static const String _host       = "dev.victorialush.co.tz";
  static const String _port       = "443";
  static Map<String, String> headers = {
    "Content-Type" : "application/json",
    "Accept": "application/json",
    "Authorization" : "",
  };

  // static const String _protocol = "http://";
  // static const String _host      = "192.168.1.146";
  // static const String _port      = "8000";

  static String _gateWay = "";
  static int timeout = 15000;
  static Response response = Response("Bad request", 400);

  static void prepareGateway(){
    _gateWay = "$_protocol$_host:$_port/api/v1";
  }

  static Future<bool> checkAuth() async {
    // bool success = await FlutterBackground.initialize(androidConfig: androidConfig);
    var shared = await SharedPreferences.getInstance();

    try {
      String token = shared.getString("token")!;
      headers["Authorization"] = "Bearer $token";
      Toast.showToast(msg: headers['Authorization']);
    } catch (exc) {
      Toast.showToast(msg: exc.toString());
      shared.setString("token", "");
      return false;
    }

    bool isConnected = await InternetConnectionChecker().hasConnection;

    if(isConnected){
      Response response = await HttpRequests.get(uri: "/user");
      Toast.showToast(msg: response.body);
      if(response.statusCode == 200){
        Toast.showToast(msg: "Success");
        return true;
      }
    }else{
      Toast.showToast(msg: "No internet connection!");
    }

    return false;
  }

  static Future<dynamic> delete({required String uri}) async {
    try{
      var url = Uri.parse("$_gateWay$uri");
      //var startTime = DateTime.now().millisecondsSinceEpoch;
      var response = await http.delete(url, headers: headers).timeout(
          Duration(milliseconds: timeout), onTimeout: (){
        Toast.showToast(msg: "Connection timed out!"); return Response("Connection timed out!", 408);
      }
      );

      return response;
    }catch(e){
      Toast.showToast(msg: e.toString());
      response = Response(e.toString(), 400);
      return response;
    }
  }

  static Future<dynamic> get({required String uri}) async {
    try{
      var url = Uri.parse("$_gateWay$uri");
      //var startTime = DateTime.now().millisecondsSinceEpoch;
      var response = await http.get(url, headers: headers).timeout(
        Duration(milliseconds: timeout), onTimeout: (){
          Toast.showToast(msg: "Connection timed out!"); return Response("Connection timed out!", 408);
        }
      );

      return response;
    }catch(e){
      Toast.showToast(msg: e.toString());
      response = Response(e.toString(), 400);
      return response;
    }
  }

  static Future<dynamic> post({required String uri, required Map<String, dynamic> data}) async {
    try{
      var url = Uri.parse("$_gateWay$uri");
      var response = await http.post(url, body: json.encode(data), headers: headers).timeout(
          Duration(milliseconds: timeout), onTimeout: (){
        Toast.showToast(msg: "Connection timed out!");
        return Response("Connection timed out!", 408);
      }
      );

      return response;
    }catch(e){
      Toast.showToast(msg: e.toString());
      response = Response(e.toString(), 400);
      return response;
    }
  }

  static Future<dynamic> patch({required String uri, required Map<String, dynamic> data}) async {
    try{
      var url = Uri.parse("$_gateWay$uri");
      var response = await http.patch(url, body: json.encode(data), headers: headers);

      return response;
    }catch(e){
      Toast.showToast(msg: e.toString());
      response = Response(e.toString(), 400);
      return response;
    }
  }
}