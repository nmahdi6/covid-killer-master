import 'dart:math';

import 'package:flutter/material.dart';

import '../components/level_list_tile.dart';
import '../db/database_helper.dart';

class LevelsManager extends ChangeNotifier {
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  int presentLevel = 1;
  late List<dynamic> lvlsStatus;
  List<Widget> levelListTiles = [];
  Map<int, int> levelStar = {};
  bool allDone = false;

  LevelsManager() {
    levelSetUp();
  }

  void levelSetUp() async {
    if(DatabaseHelper.currentLoggedInEmail != null){
      lvlsStatus = await dbHelper.getUserLevels();
      int? maxLevel = await dbHelper.getNumOfLevels();
      presentLevel = min(lvlsStatus.length + 1, maxLevel!);
      var userLevels = await dbHelper.getUserLevels();
      levelStar.clear();
      for (var element in userLevels) {
        levelStar[element['levelNum']] = element['star'];
      }

      allDone = presentLevel == maxLevel ? true : false;
      notifyListeners();
    }
  }

  void incrementLevel(int star) async{
    int? maxLevel = await dbHelper.getNumOfLevels();
      if (maxLevel != null && presentLevel <= maxLevel) {
        var userLevels = await dbHelper.getLevelFromUserLevels(presentLevel);
        if(userLevels.isEmpty){
          levelStar[presentLevel] = star;
          dbHelper.insert(tableName: 'userLevels', record: {"email": DatabaseHelper.currentLoggedInEmail, "levelNum": presentLevel, "star": star});
          presentLevel++;
        }else{
          if(userLevels[0]['star'] < star){
            levelStar[presentLevel] = star;
            dbHelper.updateUserLevels(presentLevel, {'star': star});
          }
        }
      }

    allDone = presentLevel == maxLevel ? true : false;

    notifyListeners();
  }

  void updateLevelStatus() async{
    lvlsStatus = await dbHelper.getUserLevels();
    notifyListeners();
  }

  bool validateSelectedLevel(int levelNum){
    return levelNum <= presentLevel;
  }

  void getLevelsFromDB(){
    levelListTiles.clear();
    dbHelper.getNumOfLevels().then((value){
      for(int i = 1; i <= value!; i++){
        levelListTiles.add(LevelListTile(levelNo: i));
      }
    });
    notifyListeners();
  }
}
