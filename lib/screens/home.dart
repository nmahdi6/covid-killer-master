import 'package:audioplayers/audioplayers.dart';
import 'package:covid/components/home_back_ground.dart';
import 'package:covid/components/music.dart';
import 'package:covid/models/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:animated_button/animated_button.dart';
import '../components/earth_rotating_animation.dart';
import '../models/levels_manager.dart';
import '../pages/user_setting.dart';
import 'dart:developer' as developer;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final playerS = AudioCache();
  Music gameMusic = Music();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient:
                  LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black, Colors.cyanAccent, Colors.orange]),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const HomeBackGround(),
                  Positioned(
                    bottom: ResponsiveValue(
                      context,
                      defaultValue: -210.0,
                      valueWhen: const [
                        Condition.smallerThan(
                          name: MOBILE,
                          value: -210.0,
                        ),
                        Condition.smallerThan(
                          name: TABLET,
                          value: -260.0,
                        ),
                        Condition.largerThan(
                          name: TABLET,
                          value: -310.0,
                        )
                      ],
                    ).value,
                    height: ResponsiveValue(
                      context,
                      defaultValue: 400.0,
                      valueWhen: const [
                        Condition.smallerThan(
                          name: MOBILE,
                          value: 300.0,
                        ),
                        Condition.smallerThan(
                          name: TABLET,
                          value: 400.0,
                        ),
                        Condition.largerThan(
                          name: TABLET,
                          value: 500.0,
                        )
                      ],
                    ).value,
                    width: ResponsiveValue(
                      context,
                      defaultValue: 500.0,
                      valueWhen: const [
                        Condition.smallerThan(
                          name: MOBILE,
                          value: 300.0,
                        ),
                        Condition.smallerThan(
                          name: TABLET,
                          value: 400.0,
                        ),
                        Condition.largerThan(
                          name: TABLET,
                          value: 500.0,
                        )
                      ],
                    ).value,
                    child: const EarthAnimation(),
                  ),
                  Positioned(
                    bottom: 50,
                    child: Consumer<LevelsManager>(
                      builder: (context, lvlState, child) {
                        developer.log('home/presentLevel = ${lvlState.presentLevel}', name: 'home');
                        return Consumer<SettingsManager>(
                          builder: (context, settingsStatus, child) {
                            return AnimatedButton(
                              onPressed: () async {
                                lvlState.getLevelsFromDB();
                                settingsStatus.musicStatus ? gameMusic.buttonClick() : "";
                                settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                                Navigator.of(context).pushNamed("/level");
                              },
                              enabled: true,
                              shadowDegree: ShadowDegree.dark,
                              width: 110,
                              height: 60,
                              duration: 60,
                              color: Colors.transparent,
                              shape: BoxShape.rectangle,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 20.0,
                                      offset: Offset(10.0, 10.0),
                                    ),
                                  ],
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.green,
                                      Colors.lightGreen,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Start",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 35,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  settingsButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget settingsButton() {
    return const Positioned(
      bottom: 40,
      left: 22,
      child: UserSetting(),
    );
  }
}
