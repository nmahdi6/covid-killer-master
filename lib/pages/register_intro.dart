import 'dart:async';
import 'dart:io' as io;
import 'package:covid/db/database_helper.dart';
import 'package:covid/widget/TextFieldwidget.dart';
import 'package:covid/widget/buttonWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:validators/validators.dart';
import '../components/earth_rotating_animation.dart';
import '../components/home_back_ground.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class RegisterIntro extends StatefulWidget {
  const RegisterIntro({Key? key}) : super(key: key);

  @override
  State<RegisterIntro> createState() => _RegisterIntroState();
}

class _RegisterIntroState extends State<RegisterIntro> {
  var dbHelper = DatabaseHelper.instance;
  final _signUpFormKey = GlobalKey<FormState>();
  final _signInFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    Timer(const Duration(milliseconds: 300),
        (() => showEmailModalBottomSheet(context, size, textTheme)));
    super.initState();
  }

  Size get size => MediaQuery.of(context).size;
  TextTheme get textTheme => Theme.of(context).textTheme;

  String? _imageFile;
  final ImagePicker _picker = ImagePicker();
  // var dbHelper = DatabaseHelper.instance ;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  // var imageController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final loginEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Future future;

    return SafeArea(
      child: Scaffold(
        body: InkWell(
          onTap: () {
            showEmailModalBottomSheet(context, size, textTheme);
          },
          child: Center(
                    child: Stack(
                 alignment: Alignment.center,
                 children: [
                   const HomeBackGround(),
                   Positioned(
                     bottom: ResponsiveValue(
                       context,
                       defaultValue: -210.0,
                       valueWhen: const [
                         Condition.smallerThan(
                           name: MOBILE,
                           value: -210.0,
                         ),
                         Condition.smallerThan(
                           name: TABLET,
                           value: -260.0,
                         ),
                        Condition.largerThan(
                          name: TABLET,
                          value: -310.0,
                        )
                       ],
                    ).value,
                    height: ResponsiveValue(
                      context,
                      defaultValue: 400.0,
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
                    width: ResponsiveValue(
                      context,
                      defaultValue: 500.0,
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
                     child: const EarthAnimation(),
                   ),
                 ],
               ),


            // child: Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.only(top: 32),
            //       child: RichText(
            //           textAlign: TextAlign.center,
            //           text: const TextSpan(
            //               text: "start",
            //               style: TextStyle(
            //                   color: Color.fromARGB(255, 11, 203, 200),
            //                   fontSize: 20))),
            //     ),
            //     Container()
            //   ],
            // ),
          ),


          
        ),
      ),
    );
  }

  Future<dynamic> showEmailModalBottomSheet(
      BuildContext context, Size size, TextTheme textTheme) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: ((context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: size.height / 2,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(160, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Form(
                         key: _signInFormKey,
                        //  autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextFieldWidget(
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return "Enter Email";
                                } else if (!isEmail(value)) {
                                  return "Enter correct email";
                                } else {
                                  return null;
                                }
                              },
                              controller: loginEmailController,
                              labelText: "Email",
                              icon: Icons.email_outlined,
                            ),
                            Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: TextFieldWidget(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Enter password";
                                    } else if (value.length < 6) {
                                      return "Enter correct password";
                                    } else {
                                      return null;
                                    }
                                  },
                                  controller: loginPasswordController,
                                  labelText: "Password",
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                  //  suffixIcon: Icons.visibility_off,
                                )),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          margin: const EdgeInsets.only(top: 15),
                          child: const buttonWidget(
                            title: "Login",
                          ),
                        ),
                        onTap: () {
                          if (_signInFormKey.currentState!.validate()) {
                            _select();
                          }
                        }),
                    InkWell(
                      onTap: (() {
                        Navigator.pop(context);
                        activateCodeBottomSheet(context, size, textTheme);
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        margin: const EdgeInsets.only(top: 15, bottom: 20),
                        child: const buttonWidget(
                          title: "Sign Up",
                          hasBorder: true,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }));
  }

  Future<dynamic> activateCodeBottomSheet(
      BuildContext context, Size size, TextTheme textTheme) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: ((context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: size.height / 1.4,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(160, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )),
              child: ListView(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Form(
                            key: _signUpFormKey,
                            // autovalidateMode:
                            //     AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                imageProfile(),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: TextFieldWidget(
                                      controller: firstNameController,
                                      labelText: "First name",
                                      icon: CupertinoIcons.person_alt,
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return "Enter firstName";
                                        }
                                        return null;
                                      },
                                    )),
                                Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: TextFieldWidget(
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return "Enter lastName";
                                        }
                                        return null;
                                      },
                                      controller: lastNameController,
                                      labelText: "Last name",
                                      icon: CupertinoIcons.person,
                                    )),
                                Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: TextFieldWidget(
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return "Email";
                                        } else if (!isEmail(value)) {
                                          return "Enter correct email";
                                        } else {
                                          return null;
                                        }
                                      },
                                      controller: emailController,
                                      labelText: "Email",
                                      icon: Icons.email_outlined,
                                    )),
                                Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: TextFieldWidget(
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Enter password";
                                        } else if (value.length < 6) {
                                          return "Enter correct password";
                                        } else {
                                          return null;
                                        }
                                      },
                                      controller: passwordController,
                                      labelText: "password",
                                      icon: Icons.lock_outline,
                                      obscureText: true,
                                      //   suffixIcon: Icons.visibility_off,
                                    )),
                                Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: TextFieldWidget(
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Enter password";
                                        } else if (value.length < 6) {
                                          return "Enter correct password";
                                        }
                                        if (value != passwordController.text) {
                                          return "correct password not equal";
                                        } else {
                                          return null;
                                        }
                                      },
                                      controller: confirmPasswordController,
                                      labelText: "Confirm password",
                                      icon: Icons.lock_outline,
                                      obscureText: true,
                                      //   suffixIcon: Icons.visibility_off,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          margin: const EdgeInsets.only(top: 15),
                          child: GestureDetector(
                              child: const buttonWidget(
                                title: "Create",
                              ),
                              onTap: () {
                                if (_signUpFormKey.currentState!.validate()) {
                                  _insert();
                                }
                              }),
                        ),
                        InkWell(onTap: (() {
                            Navigator.pop(context);
                            showEmailModalBottomSheet(context, size, textTheme);
                          }),
                          child: Container(
                            padding:  const EdgeInsets.symmetric(horizontal: 40),
                            margin:  const EdgeInsets.only(top: 15, bottom: 20),
                            child:  const buttonWidget(
                              title: "Sign in",
                              hasBorder: true,
                            ),
                          ),
                          
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
  }

  void _insert() async {
    var isEmailExist = await dbHelper.emailExist(emailController.text);
    if (isEmailExist) {
      Alert(
        context: context,
        title: "Duplicate email",
        desc: "A user has already created an account with this email.",
      ).show();
    } else {
      // row to insert
      Map<String, dynamic> row = {
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'image': _imageFile,
        'email': emailController.text,
        'password': passwordController.text,
        'loggedIn': 1
      };
      final id = await dbHelper.insert(tableName: 'users', record: row);
      Navigator.popAndPushNamed(context, "/home");
      dbHelper.setCurrentUser(emailController.text, context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Account created successfully"),
      ));
    }
  }

  void _select() async {
    var user = await dbHelper.select(
        loginEmailController.text, loginPasswordController.text);
    print(user);
    if (user == null) {
      Alert(
              context: context,
              title: "Not found",
              desc: "Please enter your email and password correctly")
          .show();
    } else {
      Navigator.popAndPushNamed(context, "/home");
      dbHelper.setCurrentUser(emailController.text, context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Login completed successfully"),
      ));
    }
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
          Positioned(
            bottom: 20,
            right: 20,
            child: InkWell(
              child: const Icon(
                CupertinoIcons.camera_fill,
                color: Colors.teal,
                size: 28,
              ),
              onTap: () {
                showModalBottomSheet(
                    context: context, builder: ((builder) => bottomSheet()));
              },
            ),
          )
        ],
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: [
          const Text(
            "choose profile photo",
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      _imageFile = null;
                    });
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.delete),
                      SizedBox(
                        width: 4,
                      ),
                      Text("Delet")
                    ],
                  )),
              TextButton.icon(
                icon: const Icon(Icons.camera),
                onPressed: () async {
                  await takePhoto(ImageSource.camera);
                },
                label: const Text("camera"),
              ),
              TextButton.icon(
                icon: const Icon(Icons.image),
                onPressed: () async {
                  await takePhoto(ImageSource.gallery);
                },
                label: const Text("gallery"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      _imageFile = pickedFile!.path;
    });
  }
}
