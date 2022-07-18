import 'package:covid/pages/page_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widget/my_colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var size = MediaQuery.of(context).size;
    double bodyMargin = size.width / 10;
    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: [
          //appbar
          Container(
            width: double.infinity,
            height: size.height / 7,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(40),
                bottomLeft: Radius.circular(40),
              ),
              gradient: LinearGradient(
                  colors: GradiantColors.appBar,
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Level select",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          // main
          Padding(
            padding: EdgeInsets.fromLTRB(
                bodyMargin, size.height / 7, bodyMargin, 0),
            child: ListView(
              children: const [
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
          //bottom
          Positioned(
            bottom: 40,
            left: 30,
            child: InkWell(
              highlightColor: Colors.white,
              splashColor: Colors.white,
              child: Container(
                width: 70,
                height: 70,
                decoration:  const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(100),
                  ),
                 // border: Border.all(color: const Color.fromARGB(200, 0, 114, 116)),
                  // gradient: LinearGradient(
                  //     colors: GradiantColors.appBar,
                  //     end: Alignment.bottomCenter,
                  //     begin: Alignment.topCenter),
                  color: SolidColors.setting
                ),
                child:  const Icon(
                  CupertinoIcons.settings,
                  size: 45,
                  color: Colors.black,
                ),
              ),
              onTap: (){
                Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: ((context) =>const SettingsPage())));
              },
            ),
         
          ),
        ],
      ),
    ));
  }
}
