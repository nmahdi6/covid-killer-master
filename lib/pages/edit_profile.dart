import 'dart:io' as io;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/levelScreenBackGround.dart';
import '../db/database_helper.dart';
import '../widget/TextFieldwidget.dart';
import '../widget/buttonWidget.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String? _imageFile;
  final ImagePicker _picker = ImagePicker();
  var dbHelper = DatabaseHelper.instance;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();
  var text_textfield;

  @override
  Widget build(BuildContext context) {
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
              firstNameController.text =
                  snapshot.data!['firstName'];
              lastNameController.text =
                  snapshot.data!['lastName'];
              emailController.text = snapshot.data!['email'];
              passwordController.text =
                  snapshot.data!['password'];
              _imageFile = snapshot.data!['image'];
              return Container(
                decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.cyanAccent,
                    Colors.orangeAccent,
                    Colors.lightGreen,
                    Colors.lightGreen
                  ]),
            ),
                child: Stack(
                  children: [
                    const LevelBackGround(),
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color.fromARGB(190, 0, 0, 0),
                    ),
                    
                    // main
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          bodyMargin, size.height / 11, bodyMargin, 0),
                      child: ListView(
                        children: [
                          const SizedBox(
                            height: 80,
                          ),
                          imageProfile(),
                          // Image.asset(Assets.images.profileAvatar.path,scale: 6.6,),
                          const SizedBox(
                            height: 100,
                          ),
                          //const Divider(color: Colors.red,height: 2,),
                          InkWell(
                            onTap: () {
                              showFirstNameBottomSheet(context, size);
                            },
                            child: Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: TextFieldWidget(
                                  labelText: "First name",
                                  icon: CupertinoIcons.person_alt,
                                  controller: firstNameController,
                                  enabled: false,
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return "Enter firstName";
                                    }
                                    return null;
                                  },
                                  // onChanged: (value) async {
                                  //   await _update();
                                  // },
                                )),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () {
                              showLastNameBottomSheet(context, size);
                            },
                            child: Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: TextFieldWidget(
                                  labelText: "Last name",
                                  icon: CupertinoIcons.person,
                                  controller: lastNameController,
                                  enabled: false,
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return "Enter lastName";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) async {
                                    await _update();
                                  },
                                )),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: TextFieldWidget(
                                labelText: "Email",
                                icon: Icons.email_outlined,
                                controller: emailController,
                                enabled: false,
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return "Enter Email";
                                  }
                                  return null;
                                },
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () {
                              showPasswordBottomSheet(context, size);
                            },
                            child: Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: TextFieldWidget(
                                  labelText: "Password",
                                  icon: Icons.lock_outline,
                                  controller: passwordController,
                                  enabled: false,
                                  obscureText: true,
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
                                )),
                          ),
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
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
        }
      },
    )));
  }

  Future<Map> _select() async {
    var user = await dbHelper.selectUserByEmail(DatabaseHelper.currentLoggedInEmail!);
    print(user);
    return user!;
  }

  Future _update() async {
    // row to insert
    Map<String, dynamic> row = {
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'image': _imageFile,
      'email': emailController.text,
      'password': passwordController.text
    };
    final id = await dbHelper.update(row);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'password', passwordController.text);
    // Navigator.pop(context);
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
                      _update();
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
      _update();
    });
  }

  Future<dynamic> showFirstNameBottomSheet(
      BuildContext context, Size size) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: ((context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: size.height / 3,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 40, 40, 40),
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
                        key: _passwordFormKey,
                        //  autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: TextFieldWidget(
                                  validator: (value) {
                                    if (value!.isEmpty) return null;
                                  },
                                  // onSaved: (String? value) {
                                  //   text_textfield = value;
                                  // },
                                  onChanged: (String? value){
                                    text_textfield = value;
                                  },
                                   labelText: "change first name",
                                   icon: Icons.person,
                                )
                                ),
                          ],
                        ),
                      ),
                    ),
                    
                    
                    InkWell(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          margin: const EdgeInsets.only(top: 15),
                          child: const buttonWidget(
                            title: "Edite",
                          ),
                        ),
                        onTap: () {
                          firstNameController.text = text_textfield.toString();
                          _update();
                          Navigator.pop(context);
                          
                        }),
                  
                  ],
                ),
              ),
            ),
          );
        }));
  }
  Future<dynamic> showLastNameBottomSheet(
      BuildContext context, Size size) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: ((context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: size.height / 3,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 40, 40, 40),
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
                        key: _passwordFormKey,
                        //  autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: TextFieldWidget(
                                  validator: (value) {
                                    if (value!.isEmpty) return null;
                                    return null;
                                  },
                                  onChanged: (String? value){
                                    text_textfield = value;
                                  },
                                   labelText: "change last name",
                                   icon: Icons.person_outline,
                                )
                                ),
                          ],
                        ),
                      ),
                    ),
                    
                    
                    InkWell(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          margin: const EdgeInsets.only(top: 15),
                          child: const buttonWidget(
                            title: "Edite",
                          ),
                        ),
                        onTap: () {
                          lastNameController.text = text_textfield.toString();
                          _update();
                          Navigator.pop(context);
                          
                        }),
                  
                  ],
                ),
              ),
            ),
          );
        }));
  }
  Future<dynamic> showPasswordBottomSheet(
      BuildContext context, Size size) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: ((context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: size.height / 3,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 40, 40, 40),
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
                        key: _passwordFormKey,
                        //  autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
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
                                  onChanged: (String? value){
                                    text_textfield = value;
                                  },
                                  icon: Icons.lock_outline,
                                   labelText: "change password",
                                  // icon: Icons.person,
                                )
                                ),
                          ],
                        ),
                      ),
                    ),
                    
                    
                    InkWell(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          margin: const EdgeInsets.only(top: 15),
                          child: const buttonWidget(
                            title: "Edite",
                          ),
                        ),
                        onTap: () {
                            if (_passwordFormKey.currentState!.validate()) {
                               passwordController.text = text_textfield.toString();
                                 _update();
                               Navigator.pop(context);
                          }
                        }),
                  
                  ],
                ),
              ),
            ),
          );
        }));
  }



}
