import 'package:covid/models/levels_manager.dart';
import 'package:covid/models/settings_manager.dart';
import 'package:covid/pages/register_intro.dart';
import 'package:covid/screens/home.dart';
import 'package:covid/screens/levels.dart';
import 'package:covid/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => SettingsManager()),
          ChangeNotifierProvider(create: (context) => LevelsManager()),
        ],
      child: MaterialApp(
          builder: (context, widget) => ResponsiveWrapper.builder(
            BouncingScrollWrapper.builder(context, widget!),
            defaultScale: true,
            breakpoints: const [
              ResponsiveBreakpoint.resize(350, name: MOBILE),
              ResponsiveBreakpoint.autoScale(800, name: TABLET),
              ResponsiveBreakpoint.resize(1000, name: DESKTOP),
              ResponsiveBreakpoint.autoScale(2460, name: '4K'),
              /*
              * below 350: resize on small screens to avoid cramp and overflow errors.
              * 350-800: resize on phones for native widget sizes.
              * 800-1000: scale on tablets to avoid elements appearing too small.
              * 1000+: resize on desktops to use available space.
              * 2460+: scale on extra large 4K displays so text is still legible and widgets are not spaced too far apart.*/
            ],
          ),
        title: 'Covid Kill',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/level': (context) => const LevelsScreen(),
          '/register': (context) => const RegisterIntro()
        }
      ),
    );
  }
}