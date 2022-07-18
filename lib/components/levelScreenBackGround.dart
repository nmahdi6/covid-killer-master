import 'dart:developer' as developer;
import 'package:covid/models/levels_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart' as rive;
import 'package:responsive_framework/responsive_framework.dart';
import 'dart:math' as math;
import 'music.dart';

class LevelBackGround extends StatefulWidget {
  const LevelBackGround({Key? key}) : super(key: key);

  @override
  State<LevelBackGround> createState() => _LevelBackGroundState();
}

class _LevelBackGroundState extends State<LevelBackGround> {
  Music gameMusic = Music();

  @override
  void initState() {
    developer.log("level/presentLevel = ${Provider.of<LevelsManager>(context, listen: false).presentLevel}", name: "level");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LevelsManager>(
      builder: (context, lvlStatus, child) {
        developer.log("level/presentLevel = ${lvlStatus.presentLevel}", name: "level");
        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: SizedBox(
                width: ResponsiveValue(
                  context,
                  defaultValue: 300.0,
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
                height: ResponsiveValue(
                  context,
                  defaultValue: 300.0,
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
                child: const rive.RiveAnimation.asset(
                  "assets/rive_assets/levelscreenbackground.riv",
                  fit: BoxFit.cover,
                  artboard: "Sun",
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Row(
                children: [
                  SizedBox(
                    width: ResponsiveValue(
                      context,
                      defaultValue: MediaQuery.of(context).size.width,
                      valueWhen: [
                        Condition.largerThan(
                          name: TABLET,
                          value: MediaQuery.of(context).size.width / 2,
                        )
                      ],
                    ).value,
                    height: ResponsiveValue(
                      context,
                      defaultValue: 700.0,
                      valueWhen: const [
                        Condition.smallerThan(
                          name: MOBILE,
                          value: 700.0,
                        ),
                        Condition.smallerThan(
                          name: TABLET,
                          value: 750.0,
                        ),
                        Condition.largerThan(
                          name: TABLET,
                          value: 800.0,
                        )
                      ],
                    ).value,
                    child: const rive.RiveAnimation.asset(
                      "assets/rive_assets/levelscreenbackground.riv",
                      fit: BoxFit.fill,
                      artboard: "greenbg",
                    ),
                  ),
                  ResponsiveVisibility(
                    visible: false,
                    visibleWhen: const [
                      Condition.largerThan(name: TABLET),
                    ],
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        height: ResponsiveValue(
                          context,
                          defaultValue: 700.0,
                          valueWhen: const [
                            Condition.smallerThan(
                              name: MOBILE,
                              value: 700.0,
                            ),
                            Condition.smallerThan(
                              name: TABLET,
                              value: 750.0,
                            ),
                            Condition.largerThan(
                              name: TABLET,
                              value: 800.0,
                            )
                          ],
                        ).value,
                        child: const rive.RiveAnimation.asset(
                          "assets/rive_assets/levelscreenbackground.riv",
                          fit: BoxFit.fill,
                          artboard: "greenbg",
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              right: 0,
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: ResponsiveValue(
                          context,
                          defaultValue: MediaQuery.of(context).size.width,
                          valueWhen: [
                            Condition.largerThan(
                              name: TABLET,
                              value: MediaQuery.of(context).size.width / 2,
                            )
                          ],
                        ).value,
                        height: ResponsiveValue(
                          context,
                          defaultValue: 300.0,
                          valueWhen: const [
                            Condition.smallerThan(
                              name: TABLET,
                              value: 200.0,
                            ),
                            Condition.smallerThan(
                              name: DESKTOP,
                              value: 300.0,
                            ),
                            Condition.largerThan(
                              name: DESKTOP,
                              value: 400.0,
                            )
                          ],
                        ).value,
                        child: const rive.RiveAnimation.asset(
                          "assets/rive_assets/levelscreenbackground.riv",
                          fit: BoxFit.fitWidth,
                          artboard: "Clouds",
                        ),
                      ),
                      ResponsiveVisibility(
                        visible: false,
                        visibleWhen: const [
                          Condition.largerThan(name: TABLET),
                        ],
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: Container(
                            alignment: Alignment.topCenter,
                            width: MediaQuery.of(context).size.width / 2,
                            height: 400,
                            child: const rive.RiveAnimation.asset(
                              "assets/rive_assets/levelscreenbackground.riv",
                              fit: BoxFit.fitWidth,
                              artboard: "Clouds",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ResponsiveVisibility(
                    visible: false,
                    visibleWhen: const [
                      Condition.smallerThan(name: DESKTOP),
                    ],
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: Container(
                        alignment: Alignment.topCenter,
                        width: MediaQuery.of(context).size.width,
                        height: ResponsiveValue(
                          context,
                          defaultValue: 300.0,
                          valueWhen: const [
                            Condition.smallerThan(
                              name: TABLET,
                              value: 200.0,
                            ),
                            Condition.smallerThan(
                              name: DESKTOP,
                              value: 300.0,
                            )
                          ],
                        ).value,
                        child: const rive.RiveAnimation.asset(
                          "assets/rive_assets/levelscreenbackground.riv",
                          fit: BoxFit.fitWidth,
                          artboard: "Clouds",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            MediaQuery.of(context).size.width >= 900 ? rowScreen(lvlStatus) : columnScreen(lvlStatus),
          ],
        );
      },
    );
  }

  Widget rowScreen(LevelsManager lvlStatus) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(),
        Column(
          children: [
            const Spacer(),
            Flexible(
              flex: 6,
              fit: FlexFit.loose,
              child: SizedBox(
                height: ResponsiveValue(
                  context,
                  defaultValue: 450.0,
                  valueWhen: const [
                    Condition.smallerThan(
                      name: MOBILE,
                      value: 450.0,
                    ),
                    Condition.smallerThan(
                      name: TABLET,
                      value: 500.0,
                    ),
                    Condition.largerThan(
                      name: TABLET,
                      value: 650.0,
                    )
                  ],
                ).value,
                width: ResponsiveValue(
                  context,
                  defaultValue: 450.0,
                  valueWhen: const [
                    Condition.smallerThan(
                      name: MOBILE,
                      value: 450.0,
                    ),
                    Condition.smallerThan(
                      name: TABLET,
                      value: 600.0,
                    ),
                    Condition.largerThan(
                      name: TABLET,
                      value: 700.0,
                    )
                  ],
                ).value,
                child: rive.RiveAnimation.asset(
                  "assets/rive_assets/levelscreenbackground.riv",
                  fit: BoxFit.fill,
                  artboard: "FortAnimations",
                  animations: lvlStatus.allDone ? ["AllDone"] : ["level${lvlStatus.presentLevel}"],
                ),
              ),
            ),
            const Spacer()
          ],
        ),
        const Spacer(),
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width / 3,
            child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const FittedBox(
                      fit: BoxFit.fill,
                      child: Text(
                        "Levels",
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Wrap(spacing: 10, runSpacing: 10, children: lvlStatus.levelListTiles)
                  ],
                )
              ],
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget columnScreen(LevelsManager lvlStatus) {
    return Stack(alignment: Alignment.center, children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(),
          Flexible(
            flex: 4,
            fit: FlexFit.loose,
            child: SizedBox(
              height: ResponsiveValue(
                context,
                defaultValue: 50.0,
                valueWhen: const [
                  Condition.smallerThan(
                    name: MOBILE,
                    value: 350.0,
                  ),
                  Condition.smallerThan(
                    name: TABLET,
                    value: 500.0,
                  ),
                  Condition.smallerThan(
                    name: DESKTOP,
                    value: 600.0,
                  )
                ],
              ).value,
              width: ResponsiveValue(
                context,
                defaultValue: 150.0,
                valueWhen: const [
                  Condition.smallerThan(
                    name: MOBILE,
                    value: 450.0,
                  ),
                  Condition.smallerThan(
                    name: TABLET,
                    value: 500.0,
                  ),
                  Condition.smallerThan(
                    name: DESKTOP,
                    value: 700.0,
                  )
                ],
              ).value,
              child: rive.RiveAnimation.asset(
                "assets/rive_assets/levelscreenbackground.riv",
                fit: BoxFit.fill,
                artboard: "FortAnimations",
                animations: lvlStatus.allDone ? ["AllDone"] : ["level${lvlStatus.presentLevel}"],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
      DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: .25,
        maxChildSize: .9,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            color: Colors.transparent,
            child: ListView(
              scrollDirection: Axis.vertical,
              controller: scrollController,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Levels",
                      style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                    ),
                    Wrap(spacing: 10, runSpacing: 10, direction: Axis.horizontal, children: lvlStatus.levelListTiles)
                  ],
                )
              ],
            ),
          );
        },
      ),
    ]);
  }
}
