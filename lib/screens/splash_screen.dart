import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

import '../db/database_helper.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2)).then((value) {
      getUser();
    });

    super.initState();
  }

  Future getUser() async {
    var user = await dbHelper.getLoggedInUser();
    if(user == null){
      routeRegister();
    }else{
      dbHelper.setCurrentUser(user['email'], context);
      routeHome();
    }
  }

  routeHome() {
    Navigator.of(context).pushNamed("/home");
  }

  routeRegister() {
    Navigator.of(context).pushNamed("/register");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17062F),
      body: Container(
        constraints: const BoxConstraints.expand(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                    "assets/images/app_logo.png",
                  ),
                ),
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
}
