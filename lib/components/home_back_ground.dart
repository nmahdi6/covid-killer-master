import 'package:covid/components/home_back_ground.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import 'package:responsive_framework/responsive_framework.dart';

class HomeBackGround extends StatefulWidget {
  const HomeBackGround({Key? key}) : super(key: key);

  @override
  State<HomeBackGround> createState() => _HomeBackGroundState();
}

class _HomeBackGroundState extends State<HomeBackGround> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4,
              child: const rive.RiveAnimation.asset(
                "assets/rive_assets/homescreen.riv",
                fit: BoxFit.fill,
                artboard: "Clouds",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4,
              child: const rive.RiveAnimation.asset(
                "assets/rive_assets/homescreen.riv",
                fit: BoxFit.fill,
                artboard: "Clouds",
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          child: SizedBox(
            height: ResponsiveValue(
              context,
              defaultValue: 150.0,
              valueWhen: const [
                Condition.smallerThan(
                  name: MOBILE,
                  value: 150.0,
                ),
                Condition.smallerThan(
                  name: TABLET,
                  value: 200.0,
                ),
                Condition.largerThan(
                  name: TABLET,
                  value: 250.0,
                ),
                Condition.smallerThan(
                  name: DESKTOP,
                  value: 250.0,
                )
              ],
            ).value,
            width: ResponsiveValue(
              context,
              defaultValue: 150.0,
              valueWhen: const [
                Condition.smallerThan(
                  name: MOBILE,
                  value: 200.0,
                ),
                Condition.smallerThan(
                  name: TABLET,
                  value: 250.0,
                ),
                Condition.largerThan(
                  name: TABLET,
                  value: 300.0,
                )
              ],
            ).value,
            child: FittedBox(
              fit: BoxFit.cover,
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(
                      "assets/images/Covi-Kill logo.png",
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width / 9,
          top: 150,
          width: MediaQuery.of(context).size.height / 8.5,
          height: MediaQuery.of(context).size.height / 8.5,
          child: const rive.RiveAnimation.asset(
            "assets/rive_assets/homescreen.riv",
            fit: BoxFit.cover,
            artboard: "CovidElements",
          ),
        ),
        Positioned(
          right: MediaQuery.of(context).size.width / 11,
          bottom: 150,
          width: MediaQuery.of(context).size.height / 11,
          height: MediaQuery.of(context).size.height / 11,
          child: const rive.RiveAnimation.asset(
            "assets/rive_assets/homescreen.riv",
            fit: BoxFit.cover,
            artboard: "CovidElements",
          ),
        ),
        Positioned(
          top: 120,
          width: MediaQuery.of(context).size.height / 1.6,
          height: MediaQuery.of(context).size.height / 1.6,
          child: const rive.RiveAnimation.asset(
            "assets/rive_assets/homescreen.riv",
            fit: BoxFit.cover,
            artboard: "MainComponenet",
          ),
        ),
      ],
    );
  }
}
