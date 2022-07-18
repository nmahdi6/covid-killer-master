import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_state.dart';

class SettingsManager extends ChangeNotifier{
  final sharedpref = SettingsState();

  bool joyStickstatus = false;
  bool musicStatus = true;
  bool vibrateStatus = true;

  SettingsManager(){
    setUp();
  }

  void setUp() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool joyS = (prefs.getBool("CCStat") ?? false);
    bool musicS = (prefs.getBool("CVStat") ?? true);
    bool vibrationS = (prefs.getBool("CVibStat") ?? true);
    joyStickstatus = joyS;
    musicStatus = musicS;
    vibrateStatus = vibrationS;
    notifyListeners();
  }
  void updateControllerState(bool val) {
    joyStickstatus = val;
    sharedpref.saveCurrentControllerStatusSharedPreferences(val);
    notifyListeners();
  }
  void updateMusicState(bool val) {
    musicStatus= val;
    sharedpref.saveCurrentVolumeStatusSharedPreferences(val);
    notifyListeners();
  }
  void updatevibrateState(bool val) {
    vibrateStatus = val;
    sharedpref.saveCurrentVibrationStatusSharedPreferences(val);
    notifyListeners();
  }
}