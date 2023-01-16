import "package:flutter/material.dart";
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../shared/colors.dart';
import '../shared/constraints.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key, required this.msg}) : super(key: key);

  final String msg;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SpinKitDualRing(
          color: dominantColor,
        ),
        const SizedBox(height: vGap,),
        Text(
            msg,
          style: const TextStyle(
            fontSize: 20
          ),
        )
      ],
    );
  }
}
