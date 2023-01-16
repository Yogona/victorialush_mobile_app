import 'package:flutter/material.dart';

import '../shared/colors.dart';

class CircularCard extends StatelessWidget {
  const CircularCard({Key? key, required this.icon, required this.bgColor}) : super(key: key);

  final Icon icon;
  final Color bgColor;

  //Circular cards
  final circularCardBlurRadius = 5.0;
  final circularCardSpreadRadius = 2.0;
  final circularCardDx = -3.0;
  final circularCardDy = 3.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          boxShadow: [
            BoxShadow(
                color: shadowColor,
                blurStyle: BlurStyle.normal,
                blurRadius: circularCardBlurRadius,
                spreadRadius: circularCardSpreadRadius,
                offset: Offset(circularCardDx, circularCardDy)
            )
          ]
      ),
      padding: const EdgeInsets.all(10.0),
      child: icon,
    );
  }
}
