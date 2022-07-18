import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonProfile extends StatelessWidget {
  const ButtonProfile({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: const TextStyle(fontSize: 20),
              ),
              const Icon(
                Icons.chevron_right,
                size: 30,
                color: Colors.orange,
              ),
            ],
          )),
    );
  }
}
