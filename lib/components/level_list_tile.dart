import 'dart:ui';

import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_value.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

import '../models/levels_manager.dart';
import '../models/settings_manager.dart';
import '../screens/game_screen.dart';
import 'music.dart';

class LevelListTile extends StatelessWidget {
  LevelListTile({required this.levelNo, Key? key}) : super(key: key);
  final Music gameMusic = Music();
  final int levelNo;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsManager>(
      builder: (context, settingsStatus, child) {
        return Consumer<LevelsManager>(
          builder: (context, lvlStatus, child) {
            return ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 1.0,
                  sigmaY: 1.0,
                ),
                child: GestureDetector(
                  onTap: () {
                    settingsStatus.musicStatus ? gameMusic.buttonClick() : "";
                    settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                    lvlStatus.validateSelectedLevel(levelNo)
                        ? levelDialog(context, (levelNo))
                        : ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Complete Previous Levels",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.lightGreenAccent,
                              elevation: 0.5,
                              dismissDirection: DismissDirection.horizontal,
                            ),
                          );
                  },
                  child: Container(
                    height: 150,
                    width: 150,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 2.0,
                          offset: Offset(0.0, 5.0),
                        ),
                      ],
                      border: (lvlStatus.presentLevel == levelNo)
                          ? Border.all(
                              color: Colors.lightGreenAccent,
                              width: 3,
                            )
                          : (levelNo < lvlStatus.presentLevel)
                              ? Border.all(
                                  color: Colors.orangeAccent,
                                  width: 3,
                                )
                              : Border.all(
                                  color: Colors.transparent,
                                  width: 2,
                                ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: lvlStatus.presentLevel == levelNo
                            ? [Colors.black45, Colors.black54, Colors.lightGreenAccent]
                            : ((levelNo < lvlStatus.presentLevel)
                                ? [Colors.black45, Colors.black54, Colors.yellow]
                                : [Colors.black45, Colors.black54, Colors.black87]),
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            'Level $levelNo',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                        ),
                        Wrap(
                          children: [
                            Icon(
                              ((lvlStatus.levelStar[levelNo] ?? 0) >= 1) ? Icons.star : Icons.star_border,
                              color: ((lvlStatus.levelStar[levelNo] ?? 0) >= 1) ? Colors.orangeAccent : Colors.white,
                              size: 30,
                            ),
                            Icon(
                              ((lvlStatus.levelStar[levelNo] ?? 0) >= 2) ? Icons.star : Icons.star_border,
                              color: ((lvlStatus.levelStar[levelNo] ?? 0) >= 2) ? Colors.orangeAccent : Colors.white,
                              size: 30,
                            ),
                            Icon(
                              ((lvlStatus.levelStar[levelNo] ?? 0) >= 3) ? Icons.star : Icons.star_border,
                              color: ((lvlStatus.levelStar[levelNo] ?? 0) >= 3) ? Colors.orangeAccent : Colors.white,
                              size: 30,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
        BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(1.1, 4.0), blurRadius: 8.0),
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
                    height: ResponsiveValue(
                      context,
                      defaultValue: 225.0,
                      valueWhen: const [
                        Condition.largerThan(
                          name: TABLET,
                          value: 275.0,
                        )
                      ],
                    ).value,
                    width: ResponsiveValue(
                      context,
                      defaultValue: MediaQuery.of(context).size.height / 3,
                      valueWhen: const [
                        Condition.largerThan(
                          name: TABLET,
                          value: 400.0,
                        )
                      ],
                    ).value,
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
                              style: TextStyle(
                                fontSize: ResponsiveValue(
                                  context,
                                  defaultValue: 30.0,
                                  valueWhen: const [
                                    Condition.largerThan(
                                      name: TABLET,
                                      value: 40.0,
                                    )
                                  ],
                                ).value,
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
                                Text(
                                  "Difficulty : ",
                                  style: TextStyle(
                                    fontSize: ResponsiveValue(
                                      context,
                                      defaultValue: 18.0,
                                      valueWhen: const [
                                        Condition.largerThan(
                                          name: TABLET,
                                          value: 25.0,
                                        )
                                      ],
                                    ).value,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  (level) <= 2
                                      ? "Easy"
                                      : ((level) > 2 && (level) < 5)
                                          ? "Medium"
                                          : "Hard",
                                  style: TextStyle(
                                    fontSize: ResponsiveValue(
                                      context,
                                      defaultValue: 18.0,
                                      valueWhen: const [
                                        Condition.largerThan(
                                          name: TABLET,
                                          value: 25.0,
                                        )
                                      ],
                                    ).value,
                                    color: (level) <= 2
                                        ? Colors.green
                                        : ((level) > 2 && (level) < 5)
                                            ? Colors.orange
                                            : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              "Inject all the vaccines",
                              style: TextStyle(
                                fontSize: ResponsiveValue(
                                  context,
                                  defaultValue: 20.0,
                                  valueWhen: const [
                                    Condition.largerThan(
                                      name: TABLET,
                                      value: 25.0,
                                    )
                                  ],
                                ).value,
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
                                          currentStage: (level),
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
                                    child: Center(
                                      child: Text(
                                        "Play",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: ResponsiveValue(
                                            context,
                                            defaultValue: 25.0,
                                            valueWhen: const [
                                              Condition.largerThan(
                                                name: TABLET,
                                                value: 35.0,
                                              )
                                            ],
                                          ).value,
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
                      height: ResponsiveValue(
                        context,
                        defaultValue: 35.0,
                        valueWhen: const [
                          Condition.largerThan(
                            name: TABLET,
                            value: 45.0,
                          )
                        ],
                      ).value,
                      width: ResponsiveValue(
                        context,
                        defaultValue: 35.0,
                        valueWhen: const [
                          Condition.largerThan(
                            name: TABLET,
                            value: 45.0,
                          )
                        ],
                      ).value,
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
                          child: Center(
                            child: Text(
                              "X",
                              style: TextStyle(
                                fontSize: ResponsiveValue(
                                  context,
                                  defaultValue: 25.0,
                                  valueWhen: [
                                    Condition.largerThan(
                                      name: TABLET,
                                      value: ResponsiveValue(
                                        context,
                                        defaultValue: 25.0,
                                        valueWhen: const [
                                          Condition.largerThan(
                                            name: TABLET,
                                            value: 30.0,
                                          )
                                        ],
                                      ).value,
                                    )
                                  ],
                                ).value,
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
}
