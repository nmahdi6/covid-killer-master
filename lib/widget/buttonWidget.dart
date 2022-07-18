import 'package:flutter/material.dart';

import 'my_colors.dart';

class buttonWidget extends StatelessWidget {
  final String? title;
  final bool hasBorder;

  const buttonWidget({@required this.title, this.hasBorder = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
          color: hasBorder ? Colors.white : SolidColors.mainColor,
          borderRadius: BorderRadius.circular(10),
          border: hasBorder ? Border.all(color: SolidColors.mainColor) : const Border.fromBorderSide(BorderSide.none)),
      child: Container(
        alignment: Alignment.center,
        child: Text(
          title!,
          style: TextStyle(color: hasBorder ? SolidColors.mainColor : Colors.white),
        ),
      ),
    );
  }
}
