import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:animated_button/animated_button.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:covid/components/music.dart';
import 'package:covid/components/settings.dart';
import 'package:covid/config/game_config.dart';
import 'package:covid/models/levels_manager.dart';
import 'package:covid/models/settings_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../db/database_helper.dart';
import '../models/game_intents.dart';
import 'package:rive/rive.dart' as rive;
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:joystick/joystick.dart';
import '../models/stages.dart';
import '../components/blinking_text.dart';
import 'win_screen.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

const int tabletThreshold = 1200;

class GameScreen extends StatefulWidget {
  final int currentStage;

  const GameScreen({required this.currentStage, Key? key}) : super(key: key);

  @override
  createState() => GameScreenState(currentLevel: currentStage);
}

class GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  static const List<Direction> directions = [Direction.right, Direction.left, Direction.up, Direction.down, Direction.stay];

  final Random random = Random();
  final playerS = AudioCache();
  final screenshotController = ScreenshotController();

  late int maxScore;
  late int currentSteps;
  late bool showAppbar;
  late bool showBottomBar;
  late Stages gameStage;
  late List<List<Type>> gameMap;
  late bool hasWon;
  late bool endGame;
  late int _secs;
  late EmojiParser parser;
  late Music gameMusic;
  late int doctorX;
  late int doctorY;
  late int score;
  late int disinfectantSpray;
  late Timer timer;
  late Map<Type, int> remainingCovid;
  int currentLevel;
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  bool stared = false;

  GameScreenState({required this.currentLevel});

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return;
      setState(() {
        _secs--;
        moveViruses();
        if (_secs <= 0) {
          endGame = true;
          hasWon = false;
          checkIfWin(context, true, true);
        }
      });
    });
  }

  Future<bool> init() async {
    startTimer();
    currentSteps = 0;
    showAppbar = true;
    showBottomBar = true;
    hasWon = false;
    endGame = false;
    parser = EmojiParser();
    gameMusic = Music();
    score = 0;
    disinfectantSpray = 12;

    var stage = await dbHelper.getStage(currentLevel);
    var map = await dbHelper.getMap(stage!["mapID"]);
    var walls = await dbHelper.getWalls(stage["mapID"]);

    gameStage = Stages(
      onLevel: stage["onLevel"],
      doctor: Point(map!["doctorX"], map["doctorY"]),
      row: map['rows'],
      col: map['columns'],
      randomObjects: {Type.redCovid: stage['redCovid'], Type.greenCovid: stage['greenCovid'], Type.spray: stage['spray']},
      walls: walls!.map((element) {
        return {'x': element['posX'], 'y': element['posY']};
      }).toList(),
      timeInSeconds: stage['secs'],
    );

    //
    _secs = gameStage.timeInSeconds;
    gameMap = gameStage.gameMap.map<List<Type>>((item) => item.toList()).toList();
    doctorX = gameStage.doctor.x;
    doctorY = gameStage.doctor.y;
    maxScore =
        gameStage.randomObjects[Type.redCovid]! * GameConfig.redCovidScore + gameStage.randomObjects[Type.greenCovid]! * GameConfig.greenCovidScore;
    remainingCovid = {Type.redCovid: gameStage.randomObjects[Type.redCovid]!, Type.greenCovid: gameStage.randomObjects[Type.greenCovid]!};

    stared = true;
    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
  }

  Point<int> moveRandom(int posX, int posY) {
    late int newX;
    late int newY;
    late Direction direction;

    label:
    while (true) {
      newX = posX;
      newY = posY;
      direction = directions[random.nextInt(directions.length)];
      switch (direction) {
        case Direction.right:
          newX = min(gameStage.col - 1, posX + 1);
          break;
        case Direction.left:
          newX = max(0, posX - 1);
          break;
        case Direction.up:
          newY = max(0, posY - 1);
          break;
        case Direction.down:
          newY = min(gameStage.row - 1, posY + 1);
          break;
        case Direction.stay:
          break label;
      }

      if (gameMap[newY][newX] == Type.empty) {
        move(posX, posY, newX, newY, increaseSteps: false);
        break;
      }
    }

    return Point(newX, newY);
  }

  move(int oldX, int oldY, int newX, int newY, {required bool increaseSteps}) {
    Type objectType = gameMap[oldY][oldX];
    gameMap[oldY][oldX] = Type.empty;
    gameMap[newY][newX] = objectType;

    if (increaseSteps) {
      currentSteps++;
    }

    if (objectType == Type.doctor) {
      doctorX = newX;
      doctorY = newY;
    }
  }

  bool moved(List<Point<int>> movedViruses, int x, int y) {
    for (Point<int> movedVirus in movedViruses) {
      if (movedVirus.x == x && movedVirus.y == y) {
        return true;
      }
    }
    return false;
  }

  moveViruses() {
    Type target;
    List<Point<int>> movedViruses = [];
    for (int y = 0; y < gameStage.row; y++) {
      for (int x = 0; x < gameStage.col; x++) {
        target = gameMap[y][x];
        if ([Type.empty, Type.wall, Type.doctor, Type.spray].contains(target) || moved(movedViruses, x, y)) {
          continue;
        }
        movedViruses.add(moveRandom(x, y));
      }
    }
  }

  moveDoctor(context, Direction direction, bool music, bool vibration) {
    int newX = doctorX;
    int newY = doctorY;

    switch (direction) {
      case Direction.up:
        newY--;
        break;
      case Direction.down:
        newY++;
        break;
      case Direction.left:
        newX--;
        break;
      case Direction.right:
        newX++;
        break;
      case Direction.stay:
        // TODO: Handle this case.
        break;
    }

    Type destType = gameMap[newY][newX];

    switch (destType) {
      case Type.wall:
      case Type.doctor:
        break;
      case Type.empty:
        move(doctorX, doctorY, newX, newY, increaseSteps: true);
        break;
      case Type.spray:
        move(doctorX, doctorY, newX, newY, increaseSteps: true);
        disinfectantSpray = GameConfig.spraysInBox;
        break;
      case Type.greenCovid:
        move(doctorX, doctorY, newX, newY, increaseSteps: true);
        disinfectantSpray -= GameConfig.greenCovidSprayNeeded;

        if (disinfectantSpray >= 0) {
          remainingCovid[Type.greenCovid] = remainingCovid[Type.greenCovid]! - 1;
          score += GameConfig.greenCovidScore;
        } else {
          endGame = true;
        }
        break;
      case Type.redCovid:
        move(doctorX, doctorY, newX, newY, increaseSteps: true);
        disinfectantSpray -= GameConfig.redCovidSprayNeeded;

        if (disinfectantSpray >= 0) {
          remainingCovid[Type.redCovid] = remainingCovid[Type.redCovid]! - 1;
          score += GameConfig.redCovidScore;
        } else {
          endGame = true;
        }
        break;
    }

    setState(() {});
    checkIfWin(context, music, vibration);
  }

  calcStars() {
    double standard = _secs / gameStage.timeInSeconds;

    if (standard > 0.75) {
      return 3;
    } else if (standard > 0.5) {
      return 2;
    } else if (standard > 0.25) {
      return 1;
    } else {
      return 0;
    }
  }

  void checkIfWin(BuildContext context, bool music, bool vibration) async {
    hasWon = (remainingCovid[Type.redCovid] == 0 && remainingCovid[Type.greenCovid] == 0) ? true : false;
    endGame = hasWon ? hasWon : endGame;

    if (endGame) {
      timer.cancel();
      if (hasWon) {
        await Future.delayed(const Duration(seconds: 1));
        int star = calcStars();
        setState(() {
          if (Provider.of<LevelsManager>(context, listen: false).presentLevel == currentLevel) {
            Provider.of<LevelsManager>(context, listen: false).incrementLevel(star);
            Provider.of<LevelsManager>(context, listen: false).updateLevelStatus();
          }

          music ? gameMusic.winScreen() : "";
          vibration ? HapticFeedback.vibrate() : "";
          showAppbar = false;
          showBottomBar = false;
        });
      }
    }
  }

  List<Widget> getCovidIcons() {
    List<Widget> icons = [];
    remainingCovid.forEach((key, value) {
      for (int i = 0; i < value; i++) {
        icons.add(key == Type.greenCovid
            ? const Icon(Icons.coronavirus, color: Colors.green, size: 30)
            : const Icon(Icons.coronavirus, color: Colors.red, size: 30));
      }
    });

    return icons;
  }

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
        offset: const Offset(1.1, 4.0),
        blurRadius: 8.0,
      ),
    ],
  );

  Future giveUp(BuildContext context) {
    timer.cancel();
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
                  Center(
                    child: Container(
                      height: ResponsiveValue(
                        context,
                        defaultValue: 150.0,
                        valueWhen: const [
                          Condition.largerThan(
                            name: TABLET,
                            value: 250.0,
                          )
                        ],
                      ).value,
                      width: ResponsiveValue(
                        context,
                        defaultValue: MediaQuery.of(context).size.width / 2,
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
                        height: 150,
                        decoration: kInnerDecoration,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Are you sure want to give up ?',
                                style: TextStyle(
                                  fontSize: ResponsiveValue(
                                    context,
                                    defaultValue: 15.0,
                                    valueWhen: const [
                                      Condition.largerThan(
                                        name: TABLET,
                                        value: 25.0,
                                      )
                                    ],
                                  ).value,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor: Colors.lightGreen,
                                        onSurface: Colors.grey,
                                      ),
                                      onPressed: () async {
                                        settingsStatus.musicStatus ? gameMusic.failMusic() : "";
                                        settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                                        Navigator.of(context).pop();
                                        await Future.delayed(
                                          const Duration(seconds: 1),
                                        );
                                        setState(() {
                                          endGame = true;
                                          showBottomBar = false;
                                          showAppbar = false;
                                        });
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  SizedBox(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor: Colors.red,
                                        onSurface: Colors.grey,
                                      ),
                                      onPressed: () {
                                        settingsStatus.musicStatus ? gameMusic.buttonClick() : "";
                                        settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                                        startTimer();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('No'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

  PreferredSizeWidget gameAppBar() {
    return PreferredSize(
      preferredSize: const Size(double.infinity, 200),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 60,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [Colors.black, Color(0xFFca5920)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10.0,
                offset: Offset(0.0, 0.0),
              ),
            ],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 20,
                          width: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              height: 5,
                              width: 10,
                              color: Colors.white,
                            ),
                            Container(
                              height: 5,
                              width: 10,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 5,
                          height: 25,
                          child: LiquidLinearProgressIndicator(
                            value: score / maxScore,
                            // Defaults to 0.5.
                            valueColor: AlwaysStoppedAnimation((((score / maxScore) * 100) == 100) ? Colors.lightGreen : Colors.white),
                            // Defaults to the current Theme's accentColor.
                            backgroundColor: Colors.cyan.shade300,
                            // Defaults to the current Theme's backgroundColor.
                            borderColor: Colors.transparent,
                            borderWidth: 0.0,
                            borderRadius: 12.0,
                            direction: Axis.horizontal,
                            center: Text(
                              (((score / maxScore) * 100) == 0)
                                  ? parser.emojify(':nauseated_face:')
                                  : (((score / maxScore) * 100) >= 25) && (((score / maxScore) * 100) <= 50)
                                      ? parser.emojify(':slightly_frowning_face:')
                                      : (((score / maxScore) * 100) <= 75)
                                          ? parser.emojify(':slightly_smiling_face:')
                                          : parser.emojify(':smiley:'),
                            ),
                          ),
                        ),
                        Container(
                          height: 8,
                          width: 5,
                          color: Colors.blue,
                        ),
                        Container(
                          height: 2,
                          width: 25,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 0.4,
                      colors: [
                        Colors.orange.shade200,
                        const Color(0xFFb64a16),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 12.0,
                        offset: Offset(0.0, 5.0),
                      ),
                    ],
                  ),
                  height: 95,
                  width: 95,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 2,
                        children: [
                          const Icon(
                            Icons.coronavirus,
                            size: 10,
                          ),
                          Text(
                            maxScore.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          const Text(
                            "|",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            (currentLevel + 1).toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "$currentSteps",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 8,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70),
                    gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                      Color(0xFF4b2318),
                      Color(0xFFb3471e),
                    ]),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        '${(_secs / 60).floor().toString().padLeft(2, '0')} : ${(_secs % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 8,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70),
                    gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                      Color(0xFF4b2318),
                      Color(0xFFb3471e),
                    ]),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(
                          '${disinfectantSpray}x',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 25,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage(
                                "assets/images/disinfectant_spray.png",
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomNavBar() {
    return Consumer<SettingsManager>(
      builder: (context, settingsStatus, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                // alignment: Alignment.center,
                // color: Colors.black,
                height: 100,
                width: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SettingDialog(
                      object: this,
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                height: 50,
                width: MediaQuery.of(context).size.width / 1.5,
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                    Color(0xFFca5920),
                    Colors.black,
                  ]),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 0.0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white70,
                              ),
                              color: const Color(0xFFe97238),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFb3471e), Color(0xFF4b2318)],
                              ),
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Row(
                              children: getCovidIcons(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: AnimatedButton(
                            onPressed: () {
                              settingsStatus.musicStatus ? gameMusic.giveUpMusic() : "";
                              settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                              giveUp(context);
                            },
                            enabled: true,
                            shadowDegree: ShadowDegree.dark,
                            width: 40,
                            height: 40,
                            duration: 60,
                            color: Colors.transparent,
                            shape: BoxShape.rectangle,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 12.0,
                                    offset: Offset(0.0, 5.0),
                                  ),
                                ],
                                border: Border.all(color: Colors.white70),
                                gradient: const RadialGradient(radius: 0.8, colors: [Color(0xFFb3471e), Color(0xFF4b2318)]),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.flag_sharp,
                                  size: 25,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: AnimatedButton(
                            onPressed: () {
                              settingsStatus.musicStatus ? gameMusic.gameEnterMusic() : "";
                              settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (BuildContext context) => super.widget),
                              );
                            },
                            enabled: true,
                            shadowDegree: ShadowDegree.dark,
                            width: 40,
                            height: 40,
                            duration: 60,
                            color: Colors.transparent,
                            shape: BoxShape.rectangle,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 12.0,
                                    offset: Offset(0.0, 5.0),
                                  ),
                                ],
                                border: Border.all(color: Colors.white70),
                                gradient: const RadialGradient(radius: 0.8, colors: [Color(0xFFb3471e), Color(0xFF4b2318)]),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.replay,
                                  size: 25,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsManager>(
      builder: (context, settingsStatus, child) {
        return WillPopScope(
          onWillPop: () async {
            bool willLeave = false;
            timer.cancel();
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Stack(children: [
                      Container(
                        height: 150,
                        width: MediaQuery.of(context).size.height / 3,
                        decoration: kGradientBoxDecoration,
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          height: 150,
                          decoration: kInnerDecoration,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Are you sure want to exit ?',
                                  style: TextStyle(fontSize: 15),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          primary: Colors.white,
                                          backgroundColor: Colors.lightGreen,
                                          onSurface: Colors.grey,
                                        ),
                                        onPressed: () {
                                          settingsStatus.musicStatus ? gameMusic.failMusic() : "";
                                          settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                                          willLeave = true;
                                          Navigator.popUntil(context, ModalRoute.withName("/home"));
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 25,
                                    ),
                                    SizedBox(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          primary: Colors.white,
                                          backgroundColor: Colors.red,
                                          onSurface: Colors.grey,
                                        ),
                                        onPressed: () {
                                          settingsStatus.musicStatus ? gameMusic.buttonClick() : "";
                                          settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                                          startTimer();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('No'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),
                  );
                });
            return willLeave;
          },
          child: stared
              ? game(settingsStatus)
              : FutureBuilder(
                  future: init(),
                  initialData: false,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<bool> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return game(settingsStatus);
                    } else {
                      return Scaffold(
                        backgroundColor: const Color(0xFF17062F),
                        body: Container(
                          constraints: const BoxConstraints.expand(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 300,
                                height: 300,
                                child: Center(
                                  child: Text('State: ${snapshot.connectionState}'),
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LoadingBouncingGrid.circle(
                                    backgroundColor: Colors.white70,
                                    size: 20,
                                  ),
                                  LoadingBouncingGrid.circle(
                                    backgroundColor: Colors.white70,
                                    size: 25,
                                  ),
                                  LoadingBouncingGrid.circle(
                                    backgroundColor: Colors.white70,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
        );
      },
    );
  }

  Widget game(SettingsManager settingsStatus) {
    return SafeArea(
      child: Screenshot(
        controller: screenshotController,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              opacity: 60,
              image: AssetImage("assets/images/DocGivingVaccine.png"),
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: showAppbar
                ? (MediaQuery.of(context).size.width < tabletThreshold)
                    ? gameAppBar()
                    : const PreferredSize(
                        preferredSize: Size(0.0, 0.0),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                        ),
                      )
                : const PreferredSize(
                    preferredSize: Size(0.0, 0.0),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                    ),
                  ),
            bottomNavigationBar: showBottomBar
                ? (MediaQuery.of(context).size.width < tabletThreshold)
                    ? bottomNavBar()
                    : Container(
                        height: 1,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black.withOpacity(0.6),
                      )
                : Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black.withOpacity(0.6),
                  ),
            body: endGame
                ? Center(
                    child: hasWon
                        ? WinScreen(
                            currentStage: currentLevel,
                            stepsTaken: currentSteps,
                            hours: (_secs / 3600).floor(),
                            mins: (_secs / 60).floor(),
                            secs: (_secs % 60),
                            screenshotController: screenshotController,
                          )
                        : lostScreen(),
                  )
                : Center(
                    child: Shortcuts(
                      shortcuts: {
                        LogicalKeySet(LogicalKeyboardKey.arrowUp): UpIntent(),
                        LogicalKeySet(LogicalKeyboardKey.arrowDown): DownIntent(),
                        LogicalKeySet(LogicalKeyboardKey.arrowRight): RightIntent(),
                        LogicalKeySet(LogicalKeyboardKey.arrowLeft): LeftIntent(),
                      },
                      child: Actions(
                        actions: {
                          UpIntent: CallbackAction<UpIntent>(
                            onInvoke: (intent) => moveDoctor(context, Direction.up, settingsStatus.musicStatus, settingsStatus.vibrateStatus),
                          ),
                          DownIntent: CallbackAction<DownIntent>(
                            onInvoke: (intent) => moveDoctor(context, Direction.down, settingsStatus.musicStatus, settingsStatus.vibrateStatus),
                          ),
                          RightIntent: CallbackAction<RightIntent>(
                            onInvoke: (intent) => moveDoctor(context, Direction.right, settingsStatus.musicStatus, settingsStatus.vibrateStatus),
                          ),
                          LeftIntent: CallbackAction<LeftIntent>(
                            onInvoke: (intent) => moveDoctor(context, Direction.left, settingsStatus.musicStatus, settingsStatus.vibrateStatus),
                          ),
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              MediaQuery.of(context).size.width > tabletThreshold
                                  ? Positioned(
                                      top: 0,
                                      left: 10,
                                      child: SizedBox(
                                        height: 200,
                                        width: 500,
                                        // color: Colors.black,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            FittedBox(
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
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              MediaQuery.of(context).size.width > tabletThreshold
                                  ? Positioned(
                                      top: 0,
                                      right: 0,
                                      child: SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SettingDialog(
                                              object: this,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              MediaQuery.of(context).size.width >= tabletThreshold ? gameRowScreen(settingsStatus) : gameColumnScreen(settingsStatus),
                              settingsStatus.joyStickstatus ? joyStick() : Container(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget gameRowScreen(SettingsManager settingsStatus) {
    return Stack(
      children: [
        Positioned(
          bottom: 30,
          left: 30,
          child: Container(
            height: 100,
            width: 200,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF4b2318), width: 4),
              color: const Color(0xFFe97238),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFb3471e), Color(0xFF4b2318)],
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Time Taken",
                  style: TextStyle(fontSize: 20),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text(
                    '${(_secs / 3600).floor().toString().padLeft(2, '0')} : ${(_secs / 60).floor().toString().padLeft(2, '0')} : ${(_secs % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(
                  flex: 1,
                ),
                Flexible(
                  flex: 3,
                  child: Column(
                    children: [
                      Flexible(
                        flex: 4,
                        child: Container(
                          height: 300,
                          width: 400,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF4b2318),
                              width: 5,
                            ),
                            color: const Color(0xFFe97238),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF4b2318), Color(0xFFb3471e), Color(0xFF4b2318)],
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF4b2318),
                                      width: 5,
                                    ),
                                    gradient: const RadialGradient(
                                      radius: 0.5,
                                      colors: [
                                        Color(0xFFb64a16),
                                        Color(0xFF4b2318),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(100),
                                      bottomRight: Radius.circular(100),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF4b2318),
                                        blurRadius: 12.0,
                                        offset: Offset(0.0, 5.0),
                                      ),
                                    ],
                                  ),
                                  height: 100,
                                  width: 150,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 0,
                                  ),
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Spacer(),
                                      Text(
                                        "Level $currentLevel",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 35,
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.coronavirus,
                                            size: 15,
                                          ),
                                          Text(
                                            maxScore.toString(),
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                          const Text(
                                            "|",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          Text(
                                            currentLevel.toString(),
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Flexible(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Moves : ",
                                      style: TextStyle(fontSize: 30),
                                    ),
                                    Text(
                                      "$currentSteps",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Flexible(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 10,
                                          width: 15,
                                          color: Colors.white,
                                        ),
                                        Container(
                                          height: 10,
                                          width: 15,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 170,
                                      height: 40,
                                      child: LiquidLinearProgressIndicator(
                                        value: score / maxScore,
                                        // Defaults to 0.5.
                                        valueColor: AlwaysStoppedAnimation((((score / maxScore) * 100) == 100) ? Colors.lightGreen : Colors.white),
                                        // Defaults to the current Theme's accentColor.
                                        backgroundColor: Colors.cyan.shade300,
                                        // Defaults to the current Theme's backgroundColor.
                                        borderColor: Colors.transparent,
                                        borderWidth: 0.0,
                                        borderRadius: 12.0,
                                        direction: Axis.horizontal,
                                        // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
                                        center: Text(
                                          (((score / maxScore) * 100) == 0)
                                              ? parser.emojify(':nauseated_face:')
                                              : (((score / maxScore) * 100) >= 25) && (((score / maxScore) * 100) <= 50)
                                                  ? parser.emojify(':slightly_frowning_face:')
                                                  : (((score / maxScore) * 100) <= 75)
                                                      ? parser.emojify(':slightly_smiling_face:')
                                                      : parser.emojify(':smiley:'),
                                          style: const TextStyle(fontSize: 35),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 16,
                                      width: 10,
                                      color: Colors.blue,
                                    ),
                                    Container(
                                      height: 4,
                                      width: 50,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: SizedBox(
                          height: 50,
                          width: 500,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Spacer(),
                              Container(
                                color: const Color(0xFF4b2318),
                                height: 50,
                                width: 10,
                              ),
                              const Spacer(
                                flex: 1,
                              ),
                              Container(
                                color: const Color(0xFF4b2318),
                                height: 50,
                                width: 10,
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: SizedBox(
                          height: 60,
                          width: 420,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              AnimatedButton(
                                onPressed: () {
                                  settingsStatus.musicStatus ? gameMusic.giveUpMusic() : "";
                                  settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                                  giveUp(context);
                                },
                                enabled: true,
                                shadowDegree: ShadowDegree.dark,
                                width: 50,
                                height: 50,
                                duration: 60,
                                color: Colors.transparent,
                                shape: BoxShape.rectangle,
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black38,
                                        blurRadius: 12.0,
                                        offset: Offset(0.0, 5.0),
                                      ),
                                    ],
                                    border: Border.all(color: Colors.white70),
                                    gradient: const RadialGradient(radius: 0.8, colors: [Color(0xFFb3471e), Color(0xFF4b2318)]),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.flag_sharp,
                                      size: 35,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 60,
                                width: 250,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF4b2318),
                                    width: 4,
                                  ),
                                  color: const Color(0xFFe97238),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFFb3471e), Color(0xFF4b2318)],
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: getCovidIcons()),
                              ),
                              AnimatedButton(
                                onPressed: () {
                                  settingsStatus.musicStatus ? gameMusic.gameEnterMusic() : "";
                                  settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (BuildContext context) => super.widget),
                                  );
                                },
                                enabled: true,
                                shadowDegree: ShadowDegree.dark,
                                width: 50,
                                height: 50,
                                duration: 60,
                                color: Colors.transparent,
                                shape: BoxShape.rectangle,
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black38,
                                        blurRadius: 12.0,
                                        offset: Offset(0.0, 5.0),
                                      ),
                                    ],
                                    border: Border.all(color: Colors.white70),
                                    gradient: const RadialGradient(radius: 0.8, colors: [Color(0xFFb3471e), Color(0xFF4b2318)]),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.replay,
                                      size: 35,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                    width: (MediaQuery.of(context).size.width < MediaQuery.of(context).size.height)
                        ? MediaQuery.of(context).size.width * 0.9
                        : MediaQuery.of(context).size.width * 0.5,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.bounceOut,
                      opacity: hasWon ? 0 : 1,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gameStage.col,
                        ),
                        itemBuilder: (context, index) => _buildGridItems(context, index, settingsStatus),
                        itemCount: gameStage.row * gameStage.col,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(
              flex: 1,
            ),
          ],
        ),
      ],
    );
  }

  Widget gameColumnScreen(SettingsManager settingsStatus) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              width: (MediaQuery.of(context).size.width < MediaQuery.of(context).size.height)
                  ? MediaQuery.of(context).size.width * 0.9
                  : MediaQuery.of(context).size.width * 0.5,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                curve: Curves.bounceOut,
                opacity: hasWon ? 0 : 1,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gameStage.col,
                  ),
                  itemBuilder: (context, index) => _buildGridItems(context, index, settingsStatus),
                  itemCount: gameStage.row * gameStage.col,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget joyStick() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Consumer<SettingsManager>(
        builder: (context, settingsStatus, child) {
          return Joystick(
            backgroundColor: Colors.blueGrey.shade900,
            size: ResponsiveValue(
              context,
              defaultValue: 125.0,
              valueWhen: const [
                Condition.smallerThan(
                  name: TABLET,
                  value: 150.0,
                ),
                Condition.largerThan(
                  name: TABLET,
                  value: 200.0,
                )
              ],
            ).value!,
            isDraggable: true,
            iconColor: Colors.white,
            opacity: 0.8,
            joystickMode: JoystickModes.all,
            onLeftPressed: () {
              settingsStatus.musicStatus ? gameMusic.gameBoardMusic() : "";
              settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
              moveDoctor(context, Direction.left, settingsStatus.musicStatus, settingsStatus.vibrateStatus);
            },
            onRightPressed: () {
              settingsStatus.musicStatus ? gameMusic.gameBoardMusic() : "";
              settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
              moveDoctor(context, Direction.right, settingsStatus.musicStatus, settingsStatus.vibrateStatus);
            },
            onDownPressed: () {
              settingsStatus.musicStatus ? gameMusic.gameBoardMusic() : "";
              settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
              moveDoctor(context, Direction.down, settingsStatus.musicStatus, settingsStatus.vibrateStatus);
            },
            onUpPressed: () {
              settingsStatus.musicStatus ? gameMusic.gameBoardMusic() : "";
              settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
              moveDoctor(context, Direction.up, settingsStatus.musicStatus, settingsStatus.vibrateStatus);
            },
          );
        },
      ),
    );
  }

  Widget lostScreen() {
    return Consumer<SettingsManager>(
      builder: (context, settingsStatus, child) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Stack(children: [
            Container(
              height: ResponsiveValue(
                context,
                defaultValue: 400.0,
                valueWhen: const [
                  Condition.smallerThan(
                    name: MOBILE,
                    value: 500.0,
                  ),
                  Condition.smallerThan(
                    name: TABLET,
                    value: 400.0,
                  ),
                  Condition.equals(
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
                defaultValue: MediaQuery.of(context).size.height / 3,
                valueWhen: const [
                  Condition.smallerThan(
                    name: TABLET,
                    value: 350.0,
                  ),
                  Condition.equals(
                    name: TABLET,
                    value: 350.0,
                  ),
                  Condition.largerThan(
                    name: TABLET,
                    value: 400.0,
                  )
                ],
              ).value,
              decoration: kGradientBoxDecoration,
              // color: Colors.black,
              padding: const EdgeInsets.all(5),
              child: Container(
                height: 200,
                decoration: kInnerDecoration,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Text(
                        'Level ${currentLevel + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveValue(
                            context,
                            defaultValue: 30.0,
                            valueWhen: const [
                              Condition.smallerThan(
                                name: MOBILE,
                                value: 50.0,
                              ),
                              Condition.largerThan(
                                name: MOBILE,
                                value: 40.0,
                              ),
                              Condition.largerThan(
                                name: TABLET,
                                value: 50.0,
                              )
                            ],
                          ).value,
                          color: Colors.yellow,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(
                        height: 10,
                      ),
                      const BlinkingText(
                        text: 'You Failed !',
                      ),
                      Flexible(
                        flex: 10,
                        child: SizedBox(
                          // color: Colors.red,
                          width: MediaQuery.of(context).size.width / 1.5,
                          height: MediaQuery.of(context).size.height / 5,
                          child: const Center(
                            child: rive.RiveAnimation.asset(
                              "assets/rive_assets/winandloose.riv",
                              fit: BoxFit.contain,
                              artboard: "LooseBoard",
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Time Taken",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: ResponsiveValue(
                                    context,
                                    defaultValue: 16.0,
                                    valueWhen: const [
                                      Condition.smallerThan(
                                        name: MOBILE,
                                        value: 25.0,
                                      ),
                                      Condition.largerThan(
                                        name: MOBILE,
                                        value: 30.0,
                                      ),
                                      Condition.largerThan(
                                        name: TABLET,
                                        value: 20.0,
                                      )
                                    ],
                                  ).value,
                                ),
                              ),
                              const Text(" : "),
                              Wrap(
                                children: [
                                  Text(
                                    (_secs / 3600).floor() == 0 ? "" : "${(_secs / 3600).floor()} Hrs",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: ResponsiveValue(
                                        context,
                                        defaultValue: 16.0,
                                        valueWhen: const [
                                          Condition.smallerThan(
                                            name: MOBILE,
                                            value: 25.0,
                                          ),
                                          Condition.largerThan(
                                            name: MOBILE,
                                            value: 30.0,
                                          ),
                                          Condition.largerThan(
                                            name: TABLET,
                                            value: 20.0,
                                          )
                                        ],
                                      ).value,
                                    ),
                                  ),
                                  Text(
                                    (_secs / 60).floor() == 0 ? "" : "${(_secs / 60).floor()} Mins",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: ResponsiveValue(
                                        context,
                                        defaultValue: 16.0,
                                        valueWhen: const [
                                          Condition.smallerThan(
                                            name: MOBILE,
                                            value: 25.0,
                                          ),
                                          Condition.largerThan(
                                            name: MOBILE,
                                            value: 30.0,
                                          ),
                                          Condition.largerThan(
                                            name: TABLET,
                                            value: 20.0,
                                          )
                                        ],
                                      ).value,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                (_secs % 60) == 0 ? "" : "${(_secs % 60)} Secs",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ResponsiveValue(
                                    context,
                                    defaultValue: 16.0,
                                    valueWhen: const [
                                      Condition.smallerThan(
                                        name: MOBILE,
                                        value: 25.0,
                                      ),
                                      Condition.largerThan(
                                        name: MOBILE,
                                        value: 30.0,
                                      ),
                                      Condition.largerThan(
                                        name: TABLET,
                                        value: 20.0,
                                      )
                                    ],
                                  ).value,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "No of Moves",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: ResponsiveValue(
                                    context,
                                    defaultValue: 16.0,
                                    valueWhen: const [
                                      Condition.smallerThan(
                                        name: MOBILE,
                                        value: 25.0,
                                      ),
                                      Condition.largerThan(
                                        name: MOBILE,
                                        value: 30.0,
                                      ),
                                      Condition.largerThan(
                                        name: TABLET,
                                        value: 20.0,
                                      )
                                    ],
                                  ).value,
                                ),
                              ),
                              const Text(" : "),
                              Text(
                                "$currentSteps",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ResponsiveValue(
                                    context,
                                    defaultValue: 16.0,
                                    valueWhen: const [
                                      Condition.smallerThan(
                                        name: MOBILE,
                                        value: 25.0,
                                      ),
                                      Condition.largerThan(
                                        name: MOBILE,
                                        value: 30.0,
                                      ),
                                      Condition.largerThan(
                                        name: TABLET,
                                        value: 20.0,
                                      )
                                    ],
                                  ).value,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          AnimatedButton(
                            onPressed: () async {
                              settingsStatus.musicStatus ? gameMusic.buttonClick() : "";
                              settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                              final image = await screenshotController.capture();
                              if (image == null) return;
                              await saveAndShare(image);
                            },
                            enabled: true,
                            shadowDegree: ShadowDegree.dark,
                            width: 50,
                            height: 50,
                            duration: 60,
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            child: Container(
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.orange,
                                      blurRadius: 8.0,
                                      offset: Offset(0.0, 0.0),
                                    ),
                                  ],
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange,
                                      Colors.orangeAccent,
                                      Colors.deepOrange,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Center(
                                child: Icon(
                                  Icons.share,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          AnimatedButton(
                            onPressed: () async {
                              settingsStatus.musicStatus ? gameMusic.buttonClick() : "";
                              settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                              Navigator.popUntil(context, ModalRoute.withName("/home"));
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (BuildContext context) =>
                              //             HomeScreen()
                              //     )
                              // );
                            },
                            enabled: true,
                            shadowDegree: ShadowDegree.dark,
                            width: 90,
                            height: 50,
                            duration: 60,
                            color: Colors.transparent,
                            shape: BoxShape.rectangle,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.cyan,
                                    blurRadius: 8.0,
                                    offset: Offset(0.0, 0.0),
                                  ),
                                ],
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue,
                                    Colors.lightBlueAccent,
                                    Colors.cyan,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.home,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          AnimatedButton(
                            onPressed: () async {
                              settingsStatus.musicStatus ? gameMusic.gameEnterMusic() : "";
                              settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
                              if (endGame) {
                                currentLevel = currentLevel;
                              }
                              setState(() {
                                stared = false;
                              });
                            },
                            enabled: true,
                            shadowDegree: ShadowDegree.dark,
                            width: 50,
                            height: 50,
                            duration: 60,
                            color: Colors.transparent,
                            shape: BoxShape.circle,
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
                                child: Icon(
                                  Icons.replay,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  Future saveAndShare(Uint8List bytes) async {
    final time = DateTime.now().toIso8601String().replaceAll(".", "_").replaceAll(":", "_");
    final fileName = "screenshot_$time";
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = File('${directory.path}/$fileName.png');
    imagePath.writeAsBytes(bytes);
    const text = "Test share";
    await Share.shareFiles([imagePath.path], text: text);
  }

  Widget _buildGridItems(BuildContext context, int index, SettingsManager settingsStatus) {
    int x = (index % gameStage.col);
    int y = (index / gameStage.row).floor();
    return GridTile(
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
        child: Center(
          child: _buildGridItem(x, y, settingsStatus),
        ),
      ),
    );
  }

  Widget _buildGridItem(int x, int y, SettingsManager settingsStatus) {
    switch (gameMap[y][x]) {
      case Type.wall:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
          ),
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                // opacity: 60,
                image: AssetImage(
                  "assets/images/wall.png",
                ),
              ),
            ),
          ),
        );
      case Type.redCovid:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 2,
          ),
          decoration: const BoxDecoration(
            color: Colors.grey,
          ),
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                // opacity: 60,
                image: AssetImage(
                  "assets/images/red_covid.png",
                ),
              ),
            ),
          ),
        );
      case Type.greenCovid:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 2,
          ),
          decoration: const BoxDecoration(
            color: Colors.grey,
          ),
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(
                  "assets/images/green_covid.png",
                ),
              ),
            ),
          ),
        );
      case Type.doctor:
        return SwipeDetector(
          child: Focus(
            autofocus: true,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 2,
              ),
              decoration: const BoxDecoration(
                color: Colors.grey,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    // opacity: 60,
                    image: AssetImage("assets/images/male_doctor.gif"),
                  ),
                ),
              ),
            ),
          ),
          onSwipeUp: (offset) {
            settingsStatus.musicStatus ? gameMusic.gameBoardMusic() : "";
            settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
            moveDoctor(context, Direction.up, settingsStatus.musicStatus, settingsStatus.vibrateStatus);
          },
          onSwipeDown: (offset) {
            settingsStatus.musicStatus ? gameMusic.gameBoardMusic() : "";
            settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
            moveDoctor(context, Direction.down, settingsStatus.musicStatus, settingsStatus.vibrateStatus);
          },
          onSwipeLeft: (offset) {
            settingsStatus.musicStatus ? gameMusic.gameBoardMusic() : "";
            settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
            moveDoctor(context, Direction.left, settingsStatus.musicStatus, settingsStatus.vibrateStatus);
          },
          onSwipeRight: (offset) {
            settingsStatus.musicStatus ? gameMusic.gameBoardMusic() : "";
            settingsStatus.vibrateStatus ? HapticFeedback.vibrate() : "";
            moveDoctor(context, Direction.right, settingsStatus.musicStatus, settingsStatus.vibrateStatus);
          },
        );
      case Type.empty:
        return Container();
      case Type.spray:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 2,
          ),
          decoration: const BoxDecoration(
            color: Colors.grey,
          ),
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(
                  "assets/images/disinfectant_spray.png",
                ),
              ),
            ),
          ),
        );
      default:
        return Container(
          color: Colors.grey,
        );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startTimer();
    } else if (state == AppLifecycleState.paused) {
      timer.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
