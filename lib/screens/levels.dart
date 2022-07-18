import 'package:animated_button/animated_button.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:covid/components/levelScreenBackGround.dart';
import 'package:covid/components/music.dart';
import 'package:covid/models/levels_manager.dart';
import 'package:covid/models/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../components/settings.dart';
import 'game_screen.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({Key? key}) : super(key: key);

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  List<String> anime = [];
  final playerS = AudioCache();
  late int currentLevelbg;

  Music gameMusic = Music();

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    currentLevelbg = Provider.of<LevelsManager>(context, listen: false).presentLevel;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    super.initState();
  }

  Future<Widget> buildGamePageAsync(int level) async {
    return Future.microtask(() {
      return GameScreen(currentStage: (level));
    });
  }

  Future levelDialog(BuildContext context, int level) {
    final kInnerDecoration = BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(20),
    );

    final kGradientBoxDecoration = BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
        Colors.deepOrange,
        Colors.white70,
        Colors.deepOrange,
        Colors.white70,
        Colors.deepOrange,
        Colors.white70,
        Colors.deepOrange,
        Colors.white70,
      ]),
      borderRadius: BorderRadius.circular(20),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(1.1, 5.0),
          blurRadius: 8.0,
        ),
      ],
    );
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<SettingsManager>(
            builder: (context, settingsStatus, child) {
              return Dialog(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Stack(children: [
                  Container(
                    height: 225,
                    width: MediaQuery.of(context).size.width / 3,
                    decoration: kGradientBoxDecoration,
                    padding: const EdgeInsets.all(5),
                    child: Container(
                      height: 200,
                      decoration: kInnerDecoration,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Level $level',
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Difficulty : ",
                                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  (level) <= 2
                                      ? "Easy"
                                      : ((level) > 2 && (level) < 5)
                                          ? "Medium"
                                          : "Hard",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: (level) <= 2
                                          ? Colors.green
                                          : ((level) > 2 && (level) < 5)
                                              ? Colors.orange
                                              : Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Text(
                              "Inject all the vaccines",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedButton(
                                  onPressed: () async {
                                    settingsStatus.musicStatus ? gameMusic.gameEnterMusic() : "";
                                    settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) => GameScreen(
                                          currentStage: (level - 1),
                                        ),
                                      ),
                                    );
                                  },
                                  enabled: true,
                                  shadowDegree: ShadowDegree.dark,
                                  width: 100,
                                  height: 50,
                                  duration: 60,
                                  color: Colors.transparent,
                                  shape: BoxShape.rectangle,
                                  child: Container(
                                    width: 110,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.lightGreenAccent,
                                          blurRadius: 8.0,
                                          offset: Offset(0.0, 0.0),
                                        ),
                                      ],
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.green,
                                          Colors.lightGreen,
                                          Colors.lightGreenAccent,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Play",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: -1,
                    child: Container(
                      margin: const EdgeInsets.all(1),
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            settingsStatus.musicStatus ? gameMusic.buttonClick() : "";
                            settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                            Navigator.of(context).pop();
                          },
                          child: const Center(
                            child: Text(
                              "X",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.popUntil(context, ModalRoute.withName("/home"));
        return true;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.cyanAccent, Colors.orangeAccent, Colors.lightGreen, Colors.lightGreen]),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const LevelBackGround(),
              homeButton(),
              settingsButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget settingsButton() {
    return Positioned(
      bottom: 10,
      left: 10,
      child: SettingDialog(),
    );
  }

  Widget homeButton() {
    return Consumer<SettingsManager>(
      builder: (context, settingsStatus, child) {
        return Positioned(
          top: 28,
          left: 18,
          child: Column(
            children: [
              AnimatedButton(
                onPressed: () {
                  settingsStatus.musicStatus ? gameMusic.buttonClick() : "";
                  settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                  Navigator.of(context).pop();
                },
                enabled: true,
                shadowDegree: ShadowDegree.dark,
                width: ResponsiveValue(
                  context,
                  defaultValue: 40.0,
                  valueWhen: const [
                    Condition.smallerThan(
                      name: MOBILE,
                      value: 40.0,
                    ),
                    Condition.smallerThan(
                      name: TABLET,
                      value: 50.0,
                    ),
                    Condition.largerThan(
                      name: TABLET,
                      value: 60.0,
                    )
                  ],
                ).value!,
                height: ResponsiveValue(
                  context,
                  defaultValue: 40.0,
                  valueWhen: const [
                    Condition.smallerThan(
                      name: MOBILE,
                      value: 40.0,
                    ),
                    Condition.smallerThan(
                      name: TABLET,
                      value: 50.0,
                    ),
                    Condition.largerThan(
                      name: TABLET,
                      value: 60.0,
                    )
                  ],
                ).value!,
                duration: 60,
                color: Colors.transparent,
                shape: BoxShape.circle,
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Center(
                    child: Icon(
                      color: Colors.green.shade800,
                      Icons.arrow_back_ios,
                      size: ResponsiveValue(
                        context,
                        defaultValue: 10.0,
                        valueWhen: const [
                          Condition.smallerThan(
                            name: MOBILE,
                            value: 30.0,
                          ),
                          Condition.smallerThan(
                            name: TABLET,
                            value: 45.0,
                          ),
                          Condition.smallerThan(
                            name: DESKTOP,
                            value: 55.0,
                          ),
                          Condition.largerThan(
                            name: DESKTOP,
                            value: 65.0,
                          )
                        ],
                      ).value,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
