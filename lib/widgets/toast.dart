import 'package:fluttertoast/fluttertoast.dart';

class Toast extends Fluttertoast{
  // static const Color _backgroundColor = dominantColor;
  // static const Color _textColor = Colors.white;
  static void showToast({required msg}){
    dynamic words = msg.split(" ");
    int duration = words.length;
    Fluttertoast.showToast(
        msg: msg, timeInSecForIosWeb: duration,
    );
  }
}
