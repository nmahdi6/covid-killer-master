import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class BlinkingText extends StatefulWidget {
  final String text;

  const BlinkingText({required this.text, Key? key}) : super(key: key);

  @override
  createState() => BlinkingTextWidget(text: text);
}

class BlinkingTextWidget extends State<BlinkingText> with TickerProviderStateMixin {
  late AnimationController _animationController;

  String text;

  BlinkingTextWidget({required this.text});

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeTransition(
          opacity: _animationController,
          child: Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveValue(
                context,
                defaultValue: 40.0,
                valueWhen: const [
                  Condition.largerThan(
                    name: MOBILE,
                    value: 50.0,
                  ),
                  Condition.largerThan(
                    name: TABLET,
                    value: 60.0,
                  )
                ],
              ).value,
              color: text == "You Won" ? Colors.lightGreenAccent : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
