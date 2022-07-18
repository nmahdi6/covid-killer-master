import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  late SharedPreferences sPrefs;

  Future<void> saveCurrentVolumeStatusSharedPreferences(bool curVolStat) async {
    sPrefs = await SharedPreferences.getInstance();
    await sPrefs.setBool("CVStat", curVolStat);
  }

  Future<void> saveCurrentControllerStatusSharedPreferences(bool curControllerStat) async {
    sPrefs = await SharedPreferences.getInstance();
    await sPrefs.setBool("CCStat", curControllerStat);
  }

  Future<void> saveCurrentVibrationStatusSharedPreferences(bool curVibrationStat) async {
    sPrefs = await SharedPreferences.getInstance();
    await sPrefs.setBool("CVibStat", curVibrationStat);
  }
}
