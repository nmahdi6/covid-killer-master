import 'dart:io' as io;
import 'package:covid/pages/page_main.dart';
import 'package:covid/pages/register_intro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../db/database_helper.dart';
import '../widget/button_profile.dart';
import '../widget/my_colors.dart';
import 'edit_profile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _imageFile;
  var dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var size = MediaQuery.of(context).size;
    double bodyMargin = size.width / 10;
    return SafeArea(
        child: Scaffold(
            body: FutureBuilder<Map>(
      future: _select(), // async work
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const CircularProgressIndicator();
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              _imageFile = snapshot.data!['image'];
              return Stack(
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
                          "Setting",
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
                      children: [
                        const SizedBox(
                          height: 80,
                        ),
                        imageProfile(),
                        // Image.asset(Assets.images.profileAvatar.path,scale: 6.6,),
                        const SizedBox(
                          height: 150,
                        ),
                        //const Divider(color: Colors.red,height: 2,),
                        InkWell(
                          child: const ButtonProfile(
                            text: "Edit profile",
                          ),
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: ((context) =>
                                        const EditProfile())));
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          child: const ButtonProfile(
                            text: "Delete account",
                          ),
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            var email =
                                prefs.getString('email');

                            Alert(
                              context: context,
                              type: AlertType.warning,
                              title: "Delete account",
                              desc:
                                  "Are you sure you want to delete an account?",
                              buttons: [
                                DialogButton(
                                  child: const Text(
                                    "No",
                                    style: TextStyle(
                                        color: SolidColors.white, fontSize: 20),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  color:
                                      const Color.fromARGB(205, 146, 154, 156),
                                ),
                                DialogButton(
                                  child: const Text(
                                    "Yes",
                                    style: TextStyle(
                                        color: SolidColors.white, fontSize: 20),
                                  ),
                                  onPressed: () async {
                                    await dbHelper.delete(email!);
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                const RegisterIntro())));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          "Delete account is successfully."),
                                    ));
                                  },
                                  gradient: const LinearGradient(colors: GradiantColors.alertColor
                                  ),
                                )
                              ],
                            ).show();
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              Alert(
                                context: context,
                                type: AlertType.warning,
                                title: "Log out",
                                desc: "Are you sure you want to lig out?",
                                buttons: [
                                  DialogButton(
                                    child: const Text(
                                      "No",
                                      style: TextStyle(
                                          color: SolidColors.white, fontSize: 20),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    color: const Color.fromARGB(
                                        205, 146, 154, 156),
                                  ),
                                  DialogButton(
                                    child: const Text(
                                      "Yes",
                                      style: TextStyle(
                                          color: SolidColors.white, fontSize: 20),
                                    ),
                                    onPressed: () async {
                                      await prefs.setString(
                                          'email', '');
                                      await prefs.setString(
                                          'password', '');
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: ((context) =>
                                                  const RegisterIntro())));

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            "Logout completed successfully."),
                                      ));
                                    },
                                    gradient: const LinearGradient(colors: GradiantColors.alertColor
                                    ),
                                  )
                                ],
                              ).show();
                            },
                            child: const ButtonProfile(
                              text: "Log out",
                            )),
                       
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  //bottom
                  Positioned(
                    top: (size.height / 7) / 5,
                    left: 0,
                    child: InkWell(
                      highlightColor: Colors.white,
                      splashColor: Colors.white,
                      child: const SizedBox(
                        width: 70,
                        height: 70,
                        child: Icon(
                          CupertinoIcons.back,
                          size: 25,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: ((context) => const MainPage())));
                      },
                    ),
                  ),
                ],
              );
            }
        }
      },
    )));
  }

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1000),
              child: (_imageFile == null)
                  ? Image.asset(
                      'assets/images/profileAvatar.png',
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      io.File(_imageFile!),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map> _select() async {
    final prefs = await SharedPreferences.getInstance();
    var password = prefs.getString('password');
    var email = prefs.getString('email');
    var user = await dbHelper.select(email!, password!);
    return user!;
  }

}
