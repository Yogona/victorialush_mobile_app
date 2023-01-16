import 'package:flutter/material.dart';

class DecorateInput extends StatelessWidget {
  const DecorateInput({Key? key, required this.leftColor, required this.widget}) : super(key: key);

  final Color leftColor;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: leftColor,
          borderRadius: BorderRadius.circular(10.0)
      ),
      child: Row(
        children: [
          const SizedBox(width: 10,),
          Expanded(
              child: widget,
          )
        ],
      ),
    );
  }
}
